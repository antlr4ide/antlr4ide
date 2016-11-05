package com.github.jknack.antlr4ide.generator

import org.eclipse.core.resources.IFile
import java.io.File
import java.io.InputStream
import java.io.BufferedReader
import java.io.InputStreamReader
import java.util.concurrent.TimeUnit
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1
import org.eclipse.core.runtime.QualifiedName
import java.util.Set
import com.github.jknack.antlr4ide.console.Console
import com.google.inject.Singleton
import java.util.List
import com.google.inject.Inject
import com.github.jknack.antlr4ide.services.GrammarResource
import static extension com.github.jknack.antlr4ide.services.ModelExtensions.*

/**
 * Execute ANTLR Tool and generated the code.
 */
@Singleton
class ToolRunner {

  /** The generated files property. */
  static val GENERATED_FILES = new QualifiedName("antlr4ide", "generatedFiles")

  /** The resource set provider. */
  @Inject
  GrammarResource grammarResource

  /**
   * Generate code by executing the ANTLR Tool. If the output directory lives inside the workspace,
   * the parent project will be refreshed.
   *
   * Optional, generated files will be marked as derived.
   *
   * The embedded jar will be used unless options#antlrTool path is set to something else.
   */
  def run(IFile file, ToolOptions options, Console console) {
    val ex=new Exception()
    System::out.println("---\n--- ToolRunner run file>"+file+"<")
    for(StackTraceElement s: ex.stackTrace) System::out.println("    "+s.toString)


    val startBuild = System.currentTimeMillis();

    val fileName = file.name
    val parentPath = file.parent.location.toOSString + File.separator

    // classpath
    val cp = classpath(options.antlrTool, console)

    // boot args
    val List<String> bootArgs = newArrayList("java")
    bootArgs.addAll(options.vmArguments)
    bootArgs.addAll("-cp", cp.join(File.pathSeparator), ToolOptionsProvider.TOOL, fileName)

    // set -lib when is empty
    val lib = options.libDirectory
    if (lib == null || lib.empty) {
      val grammar = grammarResource.grammarFrom(file)
      val libs = grammar.imports.map[
        grammarResource.fileFrom(it.importURI).parent
      ].toSet
      if (libs.size > 0) {
        options.libDirectory = libs.iterator.next.location.toOSString
      }
    }

    // tool args
    val toolArgs = options.command(file)

    // full command
    val String[] command = bootArgs + toolArgs

    console.info("%s %s", fileName, toolArgs.join(" "))

    // clean up derived resources?
    if (options.cleanUpDerivedResources) {
      cleanupResources(file)
    }

    val process = new ProcessBuilder(command).directory(file.parent.location.toFile).start

    /**
     * generate code
     */
    val stats = processOutput(parentPath, process.errorStream,
      [ message |
        console.info(message)
      ],
      [ message |
        console.error(message)
      ])
    val errors = stats.key
    val warnings = stats.value

    process.waitFor
    process.destroy

    val endBuild = System.currentTimeMillis();
    val buildTime = endBuild - startBuild;

    val seconds = TimeUnit.MILLISECONDS.toSeconds(buildTime)
    if (warnings > 0) {
      console.error("\n%s warning(s)\n", warnings)
    }
    if (errors == 0) {
      console.info("\nBUILD SUCCESSFUL")
    } else {
      console.error("%s error(s)\n", errors)
      console.error("BUILD FAIL")
    }
    var time = seconds
    var timeunit = "second"
    if (time <= 0) {
      time = buildTime
      timeunit = "millisecond"
    }
    console.info("Total time: %s %s(s)\n", time, timeunit)

    // find out dependencies
    postProcess(file, bootArgs + #["-depend"] + toolArgs, console)
  }

  /** Validate an ANTLR distribution. */
  def private validate(File jar, Console console) {
    val distribution = Distributions.get(jar)
    val version = distribution.key

    System::out.println("    ToolRunner validate file>"+jar+"< version>"+version+"<")

    if (version != "") {
      console.info("ANTLR Tool v%s (%s)", version, jar)
      return true
    } else {
      if (jar.exists) {
        console.error("error: couldn't load '%s' from '%s'", ToolOptionsProvider.TOOL, jar)
      } else {
        console.error("error: file not found '%s'", jar)
      }
      console.error("warning: fallback to default distribution: '%s' ", version)
      return false
    }
  }

  /**
   * Ask ANTLR for dependencies and save them in the file persistence storage.
   * TODO: Ask Terence to generate -depend at the code generation phase.
   */
  private def postProcess(IFile file, String[] command, Console console) {
    val process = new ProcessBuilder(command).directory(file.parent.location.toFile).start

    val Set<String> generatedFiles = newHashSet()

    /** Capture output of -depend */
    processOutput("", process.inputStream,
      [ message |
        val parts = message.split(":")
        if (parts.length == 2) {
          val generatedFile = new File(parts.get(0).trim)
          if(generatedFile.exists) generatedFiles.add(generatedFile.absolutePath)
        }
      ],
      [ message |
        console.error(message)
      ])

    process.waitFor
    process.destroy

    // save generated files
    if (generatedFiles.size > 0) {
      file.setPersistentProperty(GENERATED_FILES, generatedFiles.join(File.pathSeparator))
    } else {
      file.setPersistentProperty(GENERATED_FILES, null)
    }
  }

  /**
   * Delete previously generated files.
   */
  private def cleanupResources(IFile file) {
    val stored = file.getPersistentProperty(GENERATED_FILES)
    if(stored == null) return

    val generatedFiles = stored.split(File.pathSeparator)
    var File parentFolder = null
    for (generatedFile : generatedFiles) {
      val candidate = new File(generatedFile)
      parentFolder = candidate.parentFile
      candidate.delete
    }
    if (parentFolder != null) {
      val children = parentFolder.listFiles
      if (children == null || children.length == 0) {

        // delete parent folder if empty
        parentFolder.delete
      }
    }
  }

  /**
   * Read output from a runtime process.
   */
  private def processOutput(String parentPath, InputStream stream, Procedure1<String> info,
    Procedure1<String> error) {
    val in = new BufferedReader(new InputStreamReader(stream))
    var line = ""
    var warnings = 0
    var errors = 0
    try {
      while ((line = in.readLine()) != null) {
        line = line.replace(parentPath, "")
        if (line.startsWith("error")) {
          errors = errors + 1
          error.apply(line)
        } else {
          if (line.startsWith("warning")) {
            warnings = warnings + 1
          }
          info.apply(line)
        }
      }
    } finally {
      in.close
    }
    return errors -> warnings
  }

  /**
   * Creates the ANTLR Tool classpath.
   */
  private def classpath(String path, Console console) {
    var jar = new File(path)

    if (!jar.exists || !validate(jar, console)) {
      val fallback = Distributions.defaultDistribution
      jar = new File(fallback.value)

      // revalidate
      validate(jar, console)
    }
    return #[jar.absolutePath, jar.parentFile.absolutePath]
  }

}
