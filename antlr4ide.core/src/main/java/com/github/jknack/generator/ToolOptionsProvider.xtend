package com.github.jknack.generator

import org.eclipse.core.resources.IFile

/**
 * Provide ANTLR Tool options.
 */
interface ToolOptionsProvider {

  val VERSION = "4.1"

  val DEFAULT_TOOL = "antlr-" + VERSION + "-complete.jar"

  /** The name of the ANTLR Tool class. */
  val TOOL = "org.antlr.v4.Tool"

  /**
   * Generate options for the given grammar file.
   *
   * @param file An ANTLR grammar file.
   */
  def ToolOptions options(IFile file)
}
