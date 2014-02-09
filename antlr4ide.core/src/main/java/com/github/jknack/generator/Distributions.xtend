package com.github.jknack.generator

import java.io.File
import java.util.Map
import java.util.concurrent.ConcurrentHashMap
import java.util.jar.JarInputStream
import java.io.FileInputStream
import java.util.jar.Attributes

/**
 * Utility methods for read and validate ANTLR distributions.
 */
class Distributions {

  /** Cache ANTLR distributions. */
  private static val Map<File, Pair<String, String>> distributions = new ConcurrentHashMap<File, Pair<String, String>>()

  /** Empty/bad distribution. */
  private static val BAD = "" -> ""

  /**
   * @return The default distribution, where key represent the version number and value the jar path.
   */
  def static Pair<String, String> defaultDistribution() {
    val jar = new File(
      System.getProperty("java.io.tmpdir"),
      ToolOptionsProvider.DEFAULT_TOOL
    )
    return ToolOptionsProvider.VERSION -> jar.absolutePath
  }

  /**
   * @return The distribution associated to the given file, where key represent the version
   *    number and value the jar path. Empty distribution is return for invalid jars.
   */
  def static get(File jar) {
    if (!jar.exists) {
      return BAD
    }

    var distribution = distributions.get(jar)
    if (distribution == null) {
      if (jar.name.endsWith(".jar")) {
        val jarJar = new JarInputStream(new FileInputStream(jar))
        val attributes = jarJar.manifest.mainAttributes
        val version = attributes.get(new Attributes.Name("Implementation-Version")) + ""
        val mainClass = attributes.get(new Attributes.Name("Main-Class")) + ""
        if (mainClass == ToolOptionsProvider.TOOL) {
          distribution = version -> jar.absolutePath
        } else {
          distribution = BAD
        }
        jarJar.close
      } else {
        distribution = BAD
      }
      distributions.put(jar, distribution)
    }
    return distribution
  }

  /** Clear the distribution cache. */
  def static clear() {
    distributions.clear
  }

  /**
   * @return Get a string representation of a set of distributions.
   */
  def static toString(Pair<String, String>... distributions) {
    val buffer = new StringBuilder
    val colon = ":"
    distributions.forEach[buffer.append(it.key).append("@").append(it.value).append(colon)]
    buffer.length = buffer.length - colon.length
    buffer.toString
  }

  /**
   * @param string The distribution in a #toString format.
   * @return Distributions created from the given string.
   */
  def static fromString(String string) {
    return string.split(":").filter[it.trim.length > 0].map [
      val distri = it.trim.split("@")
      return distri.get(0) -> distri.get(1)
    ].toSet
  }

}
