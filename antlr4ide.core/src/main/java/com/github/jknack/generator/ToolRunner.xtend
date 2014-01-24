package com.github.jknack.generator

import org.eclipse.core.resources.IFile
import java.io.File
import org.osgi.framework.Bundle
import java.io.BufferedOutputStream
import java.io.InputStream
import java.io.OutputStream
import java.io.FileOutputStream
import java.io.BufferedReader
import java.io.InputStreamReader
import java.util.concurrent.TimeUnit
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1
import org.eclipse.core.runtime.QualifiedName
import java.util.Set
import com.github.jknack.console.Console
import java.util.jar.JarInputStream
import java.io.FileInputStream
import java.util.jar.Attributes
import com.google.inject.Singleton
import java.util.Map
import java.util.concurrent.ConcurrentHashMap

/**
 * Execute ANTLR Tool and generated the code.
 */
@Singleton
class ToolRunner {

  /** The core bundle. */
  Bundle bundle

  /** The generated files property. */
  private static val GENERATED_FILES = new QualifiedName("antlr4ide", "generatedFiles")

  /** The name of the ANTLR Tool class. */
  private static val TOOL = "org.antlr.v4.Tool"

  /** Cache ANTLR distributions. */
  private static val Map<File, Pair<String, String>> distributions = new ConcurrentHashMap<File, Pair<String, String>>()

  /**
   * Creates a new ToolRunner.
   *
   * @param bundle A core bundle.
   */
  new(Bundle bundle) {
    this.bundle = bundle
  }

  /**
   * Generate code by executing the ANTLR Tool. If the output directory lives inside the workspace,
   * the parent project will be refreshed.
   *
   * Optional, generated files will be marked as derived.
   *
   * The embedded jar will be used unless options#antlrTool path is set to something else.
   */
  def run(IFile file, ToolOptions options, Console console) {
    val startBuild = System.currentTimeMillis();

    val parentPath = file.parent + File.separator

    // classpath
    val cp = classpath(options.antlrTool, "antlr-4.1-complete.jar", console)

    // boot args
    val Set<String> bootArgs = newLinkedHashSet("java")
    bootArgs.addAll(options.vmArguments)
    bootArgs.addAll("-cp", cp.join(File.pathSeparator), TOOL, file.name)

    // tool args
    val localOptions = options.command(file)

    // full command
    val String[] command = bootArgs + localOptions

    console.info(file.name + " " + localOptions.join(" "))
    cleanupResources(file)
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
    postProcess(file, bootArgs + #["-depend"] + localOptions, console)
  }

  def static private version(File jar) {
    var distribution = distributions.get(jar)
    if (distribution == null) {
      if (jar.exists && jar.name.endsWith(".jar")) {
        val jarJar = new JarInputStream(new FileInputStream(jar))
        val attributes = jarJar.manifest.mainAttributes
        val version = attributes.get(new Attributes.Name("Implementation-Version")) + ""
        val mainClass = attributes.get(new Attributes.Name("Main-Class")) + ""
        jarJar.close
        distribution = mainClass -> version
      } else {
        distribution = "" -> ""
      }
      distributions.put(jar, distribution)
    }
    return distribution
  }

  /** Validate an ANTLR distribution. */
  def private validate(File jar, Console console) {
    val distribution = version(jar)
    val mainClass = distribution.key
    val version = distribution.value

    if (mainClass == TOOL) {
      console.info("ANTLR Tool v" + version + " (" + jar + ")")
      return true
    } else {
      console.error("error: Couldn't load '%s' from '%s'", TOOL, jar)
      console.error(
        "error: Please visit http://www.antlr.org/download.html and download " +
          "'antlr-4.x-complete.jar'")
      console.error("warning: falling back to 'embedded'")
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
    file.setPersistentProperty(GENERATED_FILES, generatedFiles.join(File.pathSeparator))
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
  private def classpath(String path, String name, Console console) {
    val tmpdir = new File(System.properties.getProperty("java.io.tmpdir"))
    var jar = new File(path)
    if (!jar.exists) {
      if (path != "embedded") {
        console.error(
          "error: File not found %s, please go to Window > Preferences > ANTLR 4 > Tool and " +
            "review the JAR path", path)
        console.error("warning: falling back to 'embedded'")
      }
    }

    if (!jar.exists || !validate(jar, console)) {
      jar = new File(tmpdir, name)
      val url = bundle.getResource("lib/" + name);
      copy(url.openStream, new BufferedOutputStream(new FileOutputStream(jar)))

      // revalidate
      validate(jar, console)
    }
    return #[jar.absolutePath] + if(jar.parentFile == tmpdir) #[] else #[jar.parentFile.absolutePath]
  }

  /**
   * Copy file function.
   */
  private def copy(InputStream in, OutputStream out) {
    try {
      val buffer = newByteArrayOfSize(1024)
      var length = 0;
      while ((length = in.read(buffer)) > 0) {
        out.write(buffer, 0, length);
      }
    } finally {
      in.close();
      out.close();
    }
  }
}
