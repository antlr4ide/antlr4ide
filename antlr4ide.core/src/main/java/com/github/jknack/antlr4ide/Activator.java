package com.github.jknack.antlr4ide;

import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;

import org.eclipse.core.runtime.Plugin;
import org.eclipse.xtext.xbase.lib.Pair;
import org.osgi.framework.Bundle;
import org.osgi.framework.BundleContext;

import com.github.jknack.antlr4ide.generator.Distributions;
import com.github.jknack.antlr4ide.generator.ToolOptionsProvider;

/**
 * The plugin activator.
 *
 * @author edgar
 * @author Harald A. Weiner
 */
public class Activator extends Plugin {
	
	@Override
	public void start(final BundleContext context) {
		try {
			super.start(context);
			final Bundle bundle = context.getBundle();
			final List<File> jars = this.getJars();
			for (int i = 0; i < jars.size(); i++) {
				final File it = jars.get(i);
				final String fname = "lib/" + it.getName();
				final URL toolUrl = bundle.getResource(fname);
				if (toolUrl == null) {
					throw new FileNotFoundException(fname);
				}
				copy(toolUrl.openStream(),
						new BufferedOutputStream(new FileOutputStream(it)));
			}
		} catch (final Exception ex) {
			ex.printStackTrace();
		}
	}

	private List<File> getJars() {
		final List<File> jars = new ArrayList<File>();
		final Pair<String, String> defaultDist = Distributions
				.defaultDistribution();
		final String path = defaultDist.getValue();
		final File defaultDistFile = new File(path);
		jars.add(defaultDistFile);
		jars.add(ToolOptionsProvider.RUNTIME_JAR);
		return jars;
	}
	
	/**
	 * Copy file function.
	 */
	private static void copy(final InputStream in, final OutputStream out)
			throws IOException {
		try {
			final byte[] buffer = new byte[1024];
			int length = 0;
			while ((length = in.read(buffer)) > 0) {
				out.write(buffer, 0, length);
			}
		} finally {
			in.close();
			out.close();
		}
	}
	
}
