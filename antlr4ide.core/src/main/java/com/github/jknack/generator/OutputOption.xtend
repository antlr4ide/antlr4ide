package com.github.jknack.generator

import org.eclipse.core.runtime.IPath

@Data
class OutputOption {
  IPath absolute

  IPath relative

  String packageName
}