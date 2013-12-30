package com.github.jknack.console

interface ConsoleListener {
  def void info(String message, Object...args)

  def void error(String message, Object...args)
}