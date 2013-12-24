package com.github.jknack.event

interface ConsoleListener {
  def void info(String message, Object...args)

  def void error(String message, Object...args)
}