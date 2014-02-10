package com.github.jknack.antlr4ide.generator

import org.eclipse.core.resources.IFile

interface CodeGeneratorListener {
  def void beforeProcess(IFile file, ToolOptions options)

  def void afterProcess(IFile file, ToolOptions options)
}