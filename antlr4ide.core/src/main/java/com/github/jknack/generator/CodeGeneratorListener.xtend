package com.github.jknack.generator

import org.eclipse.core.resources.IFile

interface CodeGeneratorListener {
  def void beforeProcess(IFile file, ToolOptions options)

  def void afterProcess(IFile file, ToolOptions options)
}