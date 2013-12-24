package com.github.jknack.generator

import org.eclipse.core.resources.IFile
import java.io.File
import org.osgi.framework.Bundle
import java.io.BufferedOutputStream
import java.io.InputStream
import java.io.OutputStream
import java.io.FileOutputStream
import com.github.jknack.event.ConsoleListener
import java.io.BufferedReader
import java.io.InputStreamReader
import java.util.concurrent.TimeUnit

class ToolRunner {
  private Bundle bundle

  new (Bundle bundle) {
    this.bundle = bundle
  }

  def run(IFile file, ToolOptions options, ConsoleListener console) {
    val startBuild = System.currentTimeMillis();

    val project = file.project
    val parentPath = file.parent + File.separator
    val jar = copy(options.antlrTool, "antlr-4.1-complete.jar")
    val cp = #[jar.absolutePath, jar.parentFile.absolutePath].join(File.pathSeparator)
    val tool = "org.antlr.v4.Tool"
    val String[] args = #["java", "-cp", cp, tool, file.name] + options.get(project)

    console.info(args.join(" "))
    val builder = new ProcessBuilder(args)
    builder.directory(file.parent.location.toFile)

    var process = builder.start
    val in = new BufferedReader(new InputStreamReader(process.errorStream))
    var line = ""
    var errors = 0
    var warnings = 0

    while ((line = in.readLine()) != null) {
      line = line.replace(parentPath, "")
      if (line.startsWith("error")) {
        errors = errors + 1
        console.error(line)
      } else {
        if (line.startsWith("warning")) {
          warnings = warnings + 1
        }
        console.info(line)
      }
    }
    process.waitFor
    in.close
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
  }

  private def copy(String path, String name) {
    var jar = new File(path)
    if (jar.exists) {
      return jar
    }
    jar = new File(System.properties.getProperty("java.io.tmpdir"), name);
    if (!jar.exists) {
      val url = bundle.getResource("lib/" + name);
      copy(url.openStream, new BufferedOutputStream(new FileOutputStream(jar)))
    }
    return jar
  }

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
