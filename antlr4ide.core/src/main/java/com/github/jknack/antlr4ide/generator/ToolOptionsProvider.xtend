package com.github.jknack.antlr4ide.generator

import org.eclipse.core.resources.IFile
import java.io.File

/**
 * Provide ANTLR Tool options.
 */
interface ToolOptionsProvider {

  /** Included ANTLR-4.x version.*/
  val VERSION = "4.4"

  /** Name of the included distribution. */
  val DEFAULT_TOOL = "antlr-" + VERSION + "-complete.jar"

  /** Name of the antlr4ide runtime jar. */ 
  val RUNTIME_JAR = new File(System.getProperty("java.io.tmpdir"), "antlr4ide.runtime.jar")

  /** The name of the ANTLR Tool class. */
  val TOOL = "org.antlr.v4.Tool"

  /**
   * Generate options for the given grammar file.
   *
   * @param file An ANTLR grammar file.
   */
  def ToolOptions options(IFile file)
}
