package com.github.jknack.launch

/**
 * Launch attributes.
 */
interface AntlrToolLaunchConstants {

  /**
   * Specify the grammar path. The path must be relative to the workspace root and must be in the OS format.
   */
  val GRAMMAR = "antlr4.grammar"

  /**
   * Specify tool arguments. Arguments are separated by spaces like in a shell console.
   * See http://www.antlr.org/wiki/display/ANTLR4/ANTLR+Tool+Command+Line+Options
   */
  val ARGUMENTS = "antlr4.arguments"

  /** Launch ID. */
  val ID = "com.github.jknack.Antlr4.tool"
}
