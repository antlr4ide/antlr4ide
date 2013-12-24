package com.github.jknack.generator

import org.eclipse.core.resources.IProject

interface ToolOptionsProvider {
  def ToolOptions options(IProject project)
}