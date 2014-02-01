package com.github.jknack.generator

import java.io.File
import java.util.Map
import java.util.concurrent.ConcurrentHashMap
import java.util.jar.JarInputStream
import java.io.FileInputStream
import java.util.jar.Attributes

class Distributions {

  /** Cache ANTLR distributions. */
  private static val Map<File, Pair<String, String>> distributions = new ConcurrentHashMap<File, Pair<String, String>>()

  def static Pair<String, String> defaultDistribution() {
    val tmpdir = new File(System.properties.getProperty("java.io.tmpdir"))
    val jar = new File(tmpdir, ToolOptionsProvider.DEFAULT_TOOL)
    return ToolOptionsProvider.VERSION -> jar.absolutePath
  }

  def static get(File jar) {
    var distribution = distributions.get(jar)
    if (distribution == null) {
      if (jar.exists && jar.name.endsWith(".jar")) {
        val jarJar = new JarInputStream(new FileInputStream(jar))
        val attributes = jarJar.manifest.mainAttributes
        val version = attributes.get(new Attributes.Name("Implementation-Version")) + ""
        val mainClass = attributes.get(new Attributes.Name("Main-Class")) + ""
        if (mainClass == ToolOptionsProvider.TOOL) {
          distribution = mainClass -> version
        } else {
          distribution = "" -> ""
        }
        jarJar.close
      } else {
        distribution = "" -> ""
      }
      distributions.put(jar, distribution)
    }
    return distribution
  }

  def static clear() {
    distributions.clear
  }

  def static toString(Pair<String, String>... distributions) '''
    «FOR distribution : distributions»
      «distribution.key»@«distribution.value»:
    «ENDFOR»
  '''

  def static fromString(String string) {
    return string.split(":").filter[it.trim.length > 0].map [
      val distri = it.trim.split("@")
      return distri.get(0) -> distri.get(1)
    ].toList
  }

}
