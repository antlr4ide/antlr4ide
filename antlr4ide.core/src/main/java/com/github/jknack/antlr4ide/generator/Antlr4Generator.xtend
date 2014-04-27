package com.github.jknack.antlr4ide.generator

import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.IGenerator
import org.eclipse.xtext.generator.IFileSystemAccess
import com.google.inject.Inject
import org.eclipse.core.resources.IFile
import org.eclipse.core.runtime.Status
import com.github.jknack.antlr4ide.console.Console
import static com.google.common.base.Preconditions.*
import java.util.Set
import com.github.jknack.antlr4ide.services.GrammarResource

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
  GrammarResource grammarResource

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
    checkNotNull(grammarResource)
    val file = grammarResource.fileFrom(resource)
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

    listeners.forEach[it.beforeProcess(file, options)]

    toolRunner.run(file, options, console)

    listeners.forEach[it.afterProcess(file, options)]
  }

}
