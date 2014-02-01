package com.github.jknack;

import org.eclipse.core.runtime.Plugin;
import org.osgi.framework.BundleContext;
import java.io.File
import java.io.BufferedOutputStream
import java.io.FileOutputStream
import java.io.InputStream
import java.io.OutputStream
import com.github.jknack.generator.ToolOptionsProvider
import com.github.jknack.generator.Distributions

/**
 * The plugin activator.
 *
 * @author edgar
 */
class Activator extends Plugin {

  override start(BundleContext context) {
    super.start(context)

    val jar = new File(Distributions.defaultDistribution.value)

    if (!jar.exists) {
      val url = bundle.getResource("lib/" + ToolOptionsProvider.DEFAULT_TOOL)
      copy(url.openStream, new BufferedOutputStream(new FileOutputStream(jar)))
    }
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
