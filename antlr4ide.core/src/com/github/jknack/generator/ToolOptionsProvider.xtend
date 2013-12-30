package com.github.jknack.generator

import org.eclipse.core.resources.IFile

interface ToolOptionsProvider {

  def ToolOptions options(IFile file)
}
