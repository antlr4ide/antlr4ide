package com.github.jknack.generator

import java.io.File
import org.eclipse.core.runtime.Path
import org.eclipse.core.resources.IFile
import org.eclipse.core.runtime.IPath

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

  def output(IFile file) {
    val project = file.project
    val projectPath = project.location
    val prefix = file.location.removeFirstSegments(projectPath.segmentCount)
    var pkg = removeSegment(
      removeSegment(
        removeSegment(removeSegment(prefix, "src", "main", "antlr4"), "src", "main", "java"),
        "src",
        "main",
        "resources"
      ),
      "src"
    )
    val dir = new File(outputDirectory)

    if (pkg == prefix) {
      pkg = pkg.removeFirstSegments(prefix.segmentCount)
    }

    if (dir.absolute || dir.exists) {
      return new OutputOption(
        Path.fromOSString(outputDirectory).append(pkg),
        Path.fromOSString(outputDirectory).append(pkg).makeRelative,
        pkg.toString.replace("/", ".")
      )
    }
    var output = outputDirectory
    if (!output.startsWith("/")) {
      output = "/" + output
    }
    val candidate = output.replace(projectPath.toOSString, "")
    if (candidate != output) {
      return new OutputOption(
        Path.fromOSString(output).append(pkg),
        Path.fromOSString(candidate).append(pkg).makeRelative,
        pkg.toString.replace("/", ".")
      )
    }

    // make it project relative
    return new OutputOption(
      Path.fromPortableString(project.location.toOSString).append(output).append(pkg),
      Path.fromPortableString(output).append(pkg),
      pkg.toString.replace("/", ".")
    )
  }

  def get(IFile file) {
    var listener = "-listener"
    if (!this.listener) {
      listener = "-no-listener"
    }
    var visitor = "-no-visitor"
    if (this.visitor) {
      visitor = "-visitor"
    }
    val out = output(file)
    val options = #[file.name, "-o", out.absolute.toOSString, listener, visitor, "-encoding", encoding]
    return options + if (out.packageName.length > 0) #["-package", out.packageName] else #[]
  }

  def removeSegment(IPath path, String... names) {
    var result = path
    var count = 0
    for (name : names) {
      if (result.segments.get(0) == name) {
        result = result.removeFirstSegments(1)
        count = count + 1
      }
    }
    return if(count == names.length) result.removeLastSegments(1) else path
  }
}
