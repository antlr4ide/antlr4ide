package com.github.jknack.generator

import java.io.File
import org.eclipse.core.resources.IProject
import org.eclipse.core.runtime.Path

/**
 * ANTLR Tool options.
 */
@Data
class ToolOptions {
  String antlrTool

  String outputDirectory

  boolean listener

  boolean visitor

  boolean derived

  String encoding

  def output(IProject project) {
    val dir = new File(outputDirectory)
    if (dir.absolute || dir.exists) {
      return new OutputOption(
        Path.fromOSString(outputDirectory),
        Path.fromOSString(outputDirectory).makeRelative
      )
    }
    var output = outputDirectory
    if (!output.startsWith("/")) {
      output = "/" + output
    }
    val projectPath = project.location.toOSString
    val candidate = output.replace(projectPath, "")
    if (candidate != output) {
      return new OutputOption(
        Path.fromOSString(output),
        Path.fromOSString(candidate).makeRelative
      )
    }
    // make it project relative
    return new OutputOption(
        Path.fromPortableString(project.location.toOSString).append(output),
        Path.fromPortableString(output)
    )
  }

  def get(IProject project) {
    var listener = "-listener"
    if (!this.listener) {
      listener = "-no-listener"
    }
    var visitor = "-no-visitor"
    if (this.visitor) {
      visitor = "-visitor"
    }
    return #["-o", output(project).absolute.toOSString, listener, visitor, "-encoding", encoding]
  }
}