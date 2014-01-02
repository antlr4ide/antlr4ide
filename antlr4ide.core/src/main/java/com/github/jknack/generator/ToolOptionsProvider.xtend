package com.github.jknack.generator

import org.eclipse.core.resources.IFile

/**
 * Provide ANTLR Tool options.
 */
interface ToolOptionsProvider {

  /**
   * Generate options for the given grammar file.
   *
   * @param file An ANTLR grammar file.
   */
  def ToolOptions options(IFile file)
}
