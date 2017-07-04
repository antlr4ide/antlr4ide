package com.github.jknack.antlr4ide.generator;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import java.util.jar.Attributes;
import java.util.jar.JarInputStream;

import org.eclipse.xtext.xbase.lib.Pair;

/**
 * Utility methods for read and validate ANTLR distributions.
 */
public class Distributions {
	
	/**
	 * Cache ANTLR distributions.
	 */
	private final static Map<File, Pair<String, String>> distributions = new ConcurrentHashMap<File, Pair<String, String>>();

	/**
	 * Empty/bad distribution.
	 */
	private final static Pair<String, String> BAD = new Pair<String, String>("",
			"");

	/**
	 * @return The default distribution, where key represent the version number
	 *         and value the jar path.
	 */
	public static Pair<String, String> defaultDistribution() {
		final File jar = new File(System.getProperty("java.io.tmpdir"),
				ToolOptionsProvider.DEFAULT_TOOL);
		final String key = ToolOptionsProvider.VERSION;
		final String val = jar.getAbsolutePath();
		final Pair<String, String> result = new Pair<String, String>(key, val);
		return result;
	}
	
	/**
	 * @return The distribution associated to the given file, where key
	 *         represent the version
	 *         number and value the jar path. Empty distribution is return for
	 *         invalid jars.
	 */
	public static Pair<String, String> get(final File jar) {
		if (!jar.exists()) {
			return Distributions.BAD;
		}

		Pair<String, String> distribution = Distributions.distributions
				.get(jar);
		if (distribution == null) {
			distribution = getDistributionFromJarFile(jar);
		}
		return distribution;
	}

	private static Pair<String, String> getDistributionFromJarFile(
			final File jar) {
		Pair<String, String> distribution = Distributions.BAD;
		if (jar.getName().endsWith(".jar")) {
			try {
				final JarInputStream jarJar = new JarInputStream(
						new FileInputStream(jar));
				final Attributes attributes = jarJar.getManifest()
						.getMainAttributes();
				final String version = attributes.get(
						new Attributes.Name("Implementation-Version")) + "";
				final String mainClass = attributes
						.get(new Attributes.Name("Main-Class")) + "";
				if (ToolOptionsProvider.TOOL.equals(mainClass)) {
					distribution = new Pair<String, String>(version,
							jar.getAbsolutePath());
				}
				jarJar.close();
			} catch (final IOException ex) {
				ex.printStackTrace();
			}
		}
		Distributions.distributions.put(jar, distribution);
		return distribution;
	}

	/** Clear the distribution cache. */
	public static void clear() {
		Distributions.distributions.clear();
	}
	
	/**
	 * @return Get a string representation of a set of distributions.
	 */
	public static String toString(final Pair<String, String>... distributions) {
		final StringBuilder buffer = new StringBuilder();
		final String colon = ":";
		for (int i = 0; i < distributions.length; i++) {
			final Pair<String, String> it = distributions[i];
			final String key = it.getKey();
			final String value = it.getValue();
			buffer.append(key);
			buffer.append("@");
			buffer.append(value);
			buffer.append(colon);
		}
		buffer.setLength(buffer.length() - colon.length());
		return buffer.toString();
	}

	/**
	 * @param string
	 *            The distribution in a #toString format.
	 * @return Distributions created from the given string.
	 */
	public static Set<Pair<String, String>> fromString(final String string) {
		final Set<Pair<String, String>> result = new HashSet<Pair<String, String>>();
		final String[] split = string.split(".jar:?");
		for (int i = 0; i < split.length; i++) {
			final String it = split[i];
			final String trim = it.trim();
			if (trim.length() > 0) {
				final String[] distri = trim.split("@");
				final String key = distri[0];
				final String value = distri[1] + ".jar";
				final Pair<String, String> pair = new Pair<String, String>(key,
						value);
				result.add(pair);
			}
		}
		return result;
	}
	
}
