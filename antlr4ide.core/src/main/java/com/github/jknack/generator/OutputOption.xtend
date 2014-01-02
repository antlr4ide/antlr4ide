package com.github.jknack.generator

import org.eclipse.core.runtime.IPath

/**
 * Hold output variables required by ANTLR and/or Eclipse.
 */
@Data
class OutputOption {
  /** The absolute OS path for the output directory. */
  IPath absolute

  /** The Eclipse relative path for the output directory. */
  IPath relative

  /** The package's name. */
  String packageName
}