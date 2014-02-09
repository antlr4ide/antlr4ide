package com.github.jknack.generator

import java.io.File
import org.eclipse.core.runtime.Path
import org.eclipse.core.resources.IFile
import org.eclipse.core.runtime.IPath
import java.util.Set
import java.util.List
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1
import com.google.common.base.Preconditions

/**
 * ANTLR Tool options.
 *
 * @Statefull
 * @NotThreadSafe
 */
class ToolOptions {

  public static val BUILD_LISTENER = "antlr4.listener"

  public static val BUILD_VISITOR = "antlr4.visitor"

  public static val BUILD_TOOL_PATH = "antlr4.antlrToolPath"

  public static val BUILD_ANTLR_TOOLS = "antlr4.antlrRegisteredTools"

  public static val BUILD_ENCODING = "antlr4.encoding"

  public static val VM_ARGS = "antlr4.vmArgs"

  @Property
  String antlrTool

  @Property
  String outputDirectory

  @Property
  boolean listener = true

  @Property
  boolean visitor

  @Property
  boolean derived = true

  @Property
  String encoding = "UTF-8"

  @Property
  String messageFormat

  @Property
  boolean atn

  @Property
  String libDirectory

  @Property
  String packageName

  @Property
  Set<String> extras = newLinkedHashSet()

  @Property
  String vmArgs

  boolean outputSet = false

  /**
   * Produces output options like absolute, workspace relative output directory and package name.
   * It tries to detect/guess a package's name for files under <code>src/main/antlr4</code>,
   * <code>src/main/java</code> or <code>src</code>. Any sub-directory under those paths will be
   * append them to the package's name and output folder. This more ore less mimics what the
   * antlr4-maven-plugin does Java.
   *
   * @return Absolute, workspace relative output folders and package's name for file. 
   */
  def output(IFile file) {
    val project = file.project
    val projectPath = project.location

    // device = null is required on Windows, see https://github.com/jknack/antlr4ide/issues/1
    val prefix = file.location.setDevice(null).removeFirstSegments(projectPath.segmentCount)
    var pkg = if (outputSet)
        // Output folder was set by user, just follow what user say and don't find a
        // default package see: https://github.com/jknack/antlr4ide/issues/5
        Path.fromPortableString("")
      else
        removeSegment(
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

    // if output was set by user, over
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
      Path.fromPortableString(projectPath.toOSString).append(output).append(pkg),
      Path.fromPortableString(output).append(pkg),
      pkg.toString.replace("/", ".")
    )
  }

  def defaults() {
    var listener = "-listener"
    if (!this.listener) {
      listener = "-no-listener"
    }
    var visitor = "-no-visitor"
    if (this.visitor) {
      visitor = "-visitor"
    }
    val List<String> options = newArrayList(
      listener,
      visitor
    )

    // encoding
    if (encoding != null) {
      options.addAll("-encoding", encoding)
    }
    return options
  }

  /**
   * See https://theantlrguy.atlassian.net/wiki/display/ANTLR4/ANTLR+Tool+Command+Line+Options
   *
   * @param file A *.g4 file. Can't be null.
   * @return ANTLR Tool commands.
   */
  def command(IFile file) {
    Preconditions.checkNotNull(file)

    var listener = "-listener"
    if (!this.listener) {
      listener = "-no-listener"
    }
    var visitor = "-no-visitor"
    if (this.visitor) {
      visitor = "-visitor"
    }
    val out = output(file)
    val List<String> options = newArrayList(
      "-o",
      out.absolute.toOSString,
      listener,
      visitor
    )

    // libDirectory
    if (libDirectory != null) {
      options.addAll("-lib", libDirectory)
    }

    // package
    if (packageName != null) {
      options.addAll("-package", packageName)
    } else if (out.packageName.length > 0) {
      options.addAll("-package", out.packageName)
    }

    // message-format
    if (messageFormat != null) {
      options.addAll("-message-format", messageFormat)
    }

    // atn
    if (atn) {
      options.add("-atn")
    }

    // encoding
    if (encoding != null) {
      options.addAll("-encoding", encoding)
    }

    // extras
    extras.forEach [ option |
      options.add(option)
    ]
    return options
  }

  /**
   * Parse arguments and creates a new ToolOptions instance.
   * See https://theantlrguy.atlassian.net/wiki/display/ANTLR4/ANTLR+Tool+Command+Line+Options
   */
  def static parse(String args, Procedure1<String> err) {
    val options = args.split("\\s+")
    val optionsWithValue = newHashSet("-o", "-lib", "-encoding", "-message-format", "-package")
    val defaults = new ToolOptions
    val iterator = options.iterator

    while (iterator.hasNext) {
      val option = iterator.next
      var String value = null
      if (optionsWithValue.contains(option)) {
        value = if(iterator.hasNext) iterator.next
      }

      // set options
      switch (option) {
        case "-o": {
          if (value != null) {
            defaults.outputSet = true
            defaults.outputDirectory = value
          } else {
            err.apply("Bad command-line option: '" + option + "'")
          }
        }
        case "-lib": {
          if (value != null) {
            defaults.libDirectory = value
          } else {
            err.apply("Bad command-line option: '" + option + "'")
          }
        }
        case "-encoding": {
          if (value != null) {
            defaults.encoding = value
          } else {
            err.apply("Bad command-line option: '" + option + "'")
          }
        }
        case "-message-format": {
          if (value != null) {
            defaults.messageFormat = value
          } else {
            err.apply("Bad command-line option: '" + option + "'")
          }
        }
        case "-package": {
          if (value != null) {
            defaults.packageName = value
          } else {
            err.apply("Bad command-line option: '" + option + "'")
          }
        }
        case "-atn": {
          defaults.atn = true
        }
        case "-depend": {
          err.apply("Unsupported command-line option: '" + option + "'")
        }
        case "-listener": {
          defaults.listener = true
        }
        case "-no-listener": {
          defaults.listener = false
        }
        case "-visitor": {
          defaults.visitor = true
        }
        case "-no-visitor": {
          defaults.visitor = false
        }
        case option.startsWith("-D"): {
          defaults.extras += option
        }
        case "-Werror": {
          defaults.extras += option
        }
        case "-Xsave-lexer": {
          defaults.extras += option
        }
        case "-XdbgST": {
          defaults.extras += option
        }
        case "-Xforce-atn": {
          defaults.extras += option
        }
        case "-Xlog": {
          defaults.extras += option
        }
        case "-XdbgSTWait": {
          defaults.extras += option
        }
        default: {
          err.apply("Unknown command-line option: '" + option + "'")
        }
      }
    }
    return defaults
  }

  def String[] vmArguments() {
    if(vmArgs == null || vmArgs.length == 0) #[] else vmArgs.split("\\s+")
  }

  private def removeSegment(IPath path, String... names) {
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
