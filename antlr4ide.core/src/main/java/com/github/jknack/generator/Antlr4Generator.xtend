package com.github.jknack.generator

import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.IGenerator
import org.eclipse.xtext.generator.IFileSystemAccess
import org.eclipse.core.runtime.Path
import com.google.inject.Inject
import org.osgi.framework.Bundle
import org.eclipse.core.resources.IWorkspaceRoot
import org.eclipse.core.runtime.NullProgressMonitor
import org.eclipse.core.resources.IResource
import org.eclipse.core.resources.IFile
import org.eclipse.core.runtime.Status
import com.github.jknack.console.Console
import static com.google.common.base.Preconditions.*

/**
 * Generate code by executing ANTLR Tool. The code is generated on saved for valid grammars.
 * The code generator can be executed manually from a custom launch configuration.
 * 
 * see http://www.eclipse.org/Xtext/documentation.html#TutorialCodeGeneration
 */
class Antlr4Generator implements IGenerator {

  /** The core bundle. */
  @Inject
  Bundle bundle

  /** The tools option provider. */
  @Inject
  ToolOptionsProvider optionsProvider

  /** Console. */
  @Inject
  Console console

  /** Workspace root. */
  @Inject
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
    doGenerate(file, optionsProvider.options(file))
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

    new ToolRunner(bundle).run(file, options, console)

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
