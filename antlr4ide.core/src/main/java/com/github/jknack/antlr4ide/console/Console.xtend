package com.github.jknack.antlr4ide.console

/**
 * Console for showing feedback to users.
 */
interface Console {
  /**
   * Write an INFO message into the console.
   *
   * @param message The message. Might includes place holder. See String#format
   * @param args Message arguments.
   */
  def void info(String message, Object...args)

  /**
   * Write an ERROR message into the console.
   *
   * @param message The message. Might includes place holder. See String#format
   * @param args Message arguments.
   */
  def void error(String message, Object...args)
}
