package com.github.jknack.generator

import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.IGenerator
import org.eclipse.xtext.generator.IFileSystemAccess
import org.eclipse.core.runtime.Path
import com.google.inject.Inject
import org.eclipse.core.resources.IWorkspaceRoot
import org.eclipse.core.runtime.NullProgressMonitor
import org.eclipse.core.resources.IResource
import org.eclipse.core.resources.IFile
import org.eclipse.core.runtime.Status
import com.github.jknack.console.Console
import static com.google.common.base.Preconditions.*
import org.eclipse.debug.core.DebugPlugin
import com.github.jknack.launch.AntlrToolLaunchConstants

/**
 * Generate code by executing ANTLR Tool. The code is generated on saved for valid grammars.
 * The code generator can be executed manually from a custom launch configuration.
 * 
 * see http://www.eclipse.org/Xtext/documentation.html#TutorialCodeGeneration
 */
class Antlr4Generator implements IGenerator {

  /** The tool runner. */
  @Inject
  ToolRunner tool

  /** The tools option provider. */
  @Inject
  ToolOptionsProvider optionsProvider

  /** Console. */
  @Inject
  Console console

  /** Workspace root. */
  @Inject(optional = true)
  IWorkspaceRoot workspaceRoot

  /**
   * Executed by Xtext when the ANTLR Tool is activated and the underlying resource is valid.
   * This method call ANTLR Tool for generated the code.
   *
   * @param resource The underlying resource.
   * @param fsa The Xtext file system access (not used).
   */
  override void doGenerate(Resource resource, IFileSystemAccess fsa) {
    checkNotNull(resource)
    val file = workspaceRoot.getFile(new Path(resource.getURI().toPlatformString(true)))
    doGenerate(file, options(file, optionsProvider.options(file)))
  }

  /**
   * Find a launch configuration and create tool options from there. If no launch configuration
   * exists, the defaults options will be used it.
   */
  private def options(IFile file, ToolOptions defaults) {
    val manager = DebugPlugin.^default.launchManager
    val grammar = file.fullPath.toOSString
    val configType = manager.getLaunchConfigurationType(AntlrToolLaunchConstants.ID)
    var configurations = manager.getLaunchConfigurations(configType)

    val existing = configurations.filter [ launch |
      if (grammar == launch.getAttribute(AntlrToolLaunchConstants.GRAMMAR, "")) {
        return true
      }
      return false
    ]

    if (existing.size > 0) {

      // launch existing
      val config = existing.head
      val args = config.getAttribute(AntlrToolLaunchConstants.ARGUMENTS, "")
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

    val project = file.project
    val monitor = new NullProgressMonitor()

    tool.run(file, options, console)

    project.refreshLocal(IResource.DEPTH_INFINITE, monitor)
    val output = options.output(file)
    if (project.exists(output.relative)) {
      val folder = project.getFolder(output.relative)

      /**
       * Mark files as derived
       */
      folder.accept [ generated |
        generated.setDerived(options.derived, monitor)
        return true
      ]
    }
  }

}
