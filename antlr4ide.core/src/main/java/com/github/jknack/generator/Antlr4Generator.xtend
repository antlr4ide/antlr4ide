package com.github.jknack.generator

import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.IGenerator
import org.eclipse.xtext.generator.IFileSystemAccess
import org.eclipse.core.runtime.Path
import com.google.inject.Inject
import org.eclipse.core.resources.IWorkspaceRoot
import org.eclipse.core.resources.IFile
import org.eclipse.core.runtime.Status
import com.github.jknack.console.Console
import static com.google.common.base.Preconditions.*
import com.github.jknack.generator.LaunchConstants
import java.util.Set
import org.eclipse.debug.core.ILaunchManager

/**
 * Generate code by executing ANTLR Tool. The code is generated on saved for valid grammars.
 * The code generator can be executed manually from a custom launch configuration.
 * 
 * see http://www.eclipse.org/Xtext/documentation.html#TutorialCodeGeneration
 */
class Antlr4Generator implements IGenerator {

  /** The tool runner. */
  @Inject
  @Property
  ToolRunner toolRunner

  @Inject
  @Property
  Set<CodeGeneratorListener> listeners

  /** The tools option provider. */
  @Inject
  @Property
  ToolOptionsProvider optionsProvider

  /** Console. */
  @Inject
  @Property
  Console console

  /** Workspace root. */
  @Inject
  @Property
  IWorkspaceRoot workspaceRoot

  /** Launch manager. */
  @Inject
  @Property
  ILaunchManager launchManager

  /**
   * Executed by Xtext when the ANTLR Tool is activated and the underlying resource is valid.
   * This method call ANTLR Tool for generated the code.
   *
   * @param resource The underlying resource.
   * @param fsa The Xtext file system access (not used).
   */
  override doGenerate(Resource resource, IFileSystemAccess fsa) {
    checkNotNull(resource)
    checkNotNull(fsa)
    checkNotNull(toolRunner)
    checkNotNull(listeners)
    checkNotNull(optionsProvider)
    checkNotNull(console)
    checkNotNull(workspaceRoot)
    val file = workspaceRoot.getFile(new Path(resource.getURI().toPlatformString(true)))
    doGenerate(file, options(file, optionsProvider.options(file)))
  }

  /**
   * Find a launch configuration and create tool options from there. If no launch configuration
   * exists, the defaults options will be used it.
   */
  private def options(IFile file, ToolOptions defaults) {
    val grammar = file.fullPath.toOSString
    val configType = launchManager.getLaunchConfigurationType(LaunchConstants.LAUNCH_ID)
    var configurations = launchManager.getLaunchConfigurations(configType)

    val existing = configurations.filter [ launch |
      if (grammar == launch.getAttribute(LaunchConstants.GRAMMAR, "")) {
        return true
      }
      return false
    ]

    if (existing.size > 0) {

      // launch existing
      val config = existing.head
      val args = config.getAttribute(LaunchConstants.ARGUMENTS, "")
      val options = ToolOptions.parse(args) [ message |
        console.error(message)
      ]

      // set some defaults if they are missing
      if (options.outputDirectory == null) {
        options.outputDirectory = defaults.outputDirectory
      }
      options.antlrTool = defaults.antlrTool
      return options
    } else {
      return defaults
    }
  }

  /**
   * Generate code by executing the ANTLR Tool.
   *
   * @param file An ANTLR file.
   * @param options The tools options.
   */
  def void generate(IFile file, ToolOptions options) {
    Jobs.schedule("Generating " + file.name) [ monitor |
      doGenerate(file, options)
      return Status.OK_STATUS
    ]
  }

  /**
   * Generate code by executing the ANTLR Tool. If the output directory lives inside the workspace,
   * the parent project will be refreshed.
   *
   * Optional, generated files will be marked as derived.
   *
   * @param file An ANTLR file.
   * @param options The tools options.
   */
  private def void doGenerate(IFile file, ToolOptions options) {
    checkNotNull(file)
    checkNotNull(options)

    listeners.forEach[it.beforeProcess(file, options)]

    toolRunner.run(file, options, console)

    listeners.forEach[it.afterProcess(file, options)]
  }

}
