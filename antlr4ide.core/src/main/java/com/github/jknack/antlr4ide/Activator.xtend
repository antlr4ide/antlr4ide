package com.github.jknack.antlr4ide;

import org.eclipse.core.runtime.Plugin;
import org.osgi.framework.BundleContext;
import java.io.File
import java.io.BufferedOutputStream
import java.io.FileOutputStream
import java.io.InputStream
import java.io.OutputStream
import com.github.jknack.antlr4ide.generator.ToolOptionsProvider
import com.github.jknack.antlr4ide.generator.Distributions

/**
 * The plugin activator.
 *
 * @author edgar
 */
class Activator extends Plugin {

  override start(BundleContext context) {
    super.start(context)

    val bundle = context.bundle
    // setup antlr4ide runtime.
    val rjar = "antlr4ide.runtime-" + bundle.headers.get("Bundle-Version")
      .replace(".qualifier", "-SNAPSHOT").replaceAll("\\.\\d{12}", "-SNAPSHOT") + ".jar";

    System.setProperty("antlr4ide.runtime.jar",
      new File(System.getProperty("java.io.tmpdir"), rjar).absolutePath
    );

    val jars = #[
      new File(Distributions.defaultDistribution.value),
      ToolOptionsProvider.RUNTIME_JAR
    ]

    jars.forEach[
      if (!it.exists) {
        val toolUrl = bundle.getResource("lib/" + it.name)
        copy(toolUrl.openStream, new BufferedOutputStream(new FileOutputStream(it)))
      }
    ]
  }

  /**
   * Copy file function.
   */
  private static def copy(InputStream in, OutputStream out) {
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
