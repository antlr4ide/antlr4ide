package com.github.jknack.generator;

import static com.google.common.collect.Sets.newHashSet;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;

import java.io.File;

import org.eclipse.core.runtime.Path;
import org.eclipse.xtext.xbase.lib.Pair;
import org.junit.Test;

public class DistributionsTest {

  @Test
  public void defaultDistribution() {
    File jar = new File(System.getProperty("java.io.tmpdir"), ToolOptionsProvider.DEFAULT_TOOL);

    Pair<String, String> distribution = Distributions.defaultDistribution();
    assertNotNull(distribution);

    assertEquals(ToolOptionsProvider.VERSION, distribution.getKey());
    assertEquals(jar.toString(), distribution.getValue());
  }

  @Test
  public void goodDistribution() {
    File jar = Path.fromOSString("..").append("antlr4ide.core").append("lib")
        .append("antlr-" + ToolOptionsProvider.VERSION + "-complete.jar").toFile();

    Pair<String, String> distribution = Distributions.get(jar);
    assertNotNull(distribution);

    assertEquals(ToolOptionsProvider.VERSION, distribution.getKey());
    assertEquals(jar.getAbsolutePath(), distribution.getValue());
  }

  @Test
  public void badDistribution() {
    File jar = Path.fromOSString("lib").append("junit-4.11.jar").toFile();

    Pair<String, String> distribution = Distributions.get(jar);
    assertNotNull(distribution);

    assertEquals("", distribution.getKey());
    assertEquals("", distribution.getValue());
  }

  @SuppressWarnings("unchecked")
  @Test
  public void distributionToString() {
    assertEquals("4.1@/temp/antlr-4.1.jar",
        Distributions.toString(distro("4.1", "/temp/antlr-4.1.jar")));

    assertEquals("4.1@/temp/antlr-4.1.jar:4.2@/temp/antlr-4.2.jar",
        Distributions.toString(distro("4.1", "/temp/antlr-4.1.jar"),
            distro("4.2", "/temp/antlr-4.2.jar")));
  }

  @SuppressWarnings("unchecked")
  @Test
  public void distributionFromString() {
    assertEquals(
        newHashSet(distro("4.1", "/temp/antlr-4.1.jar")),
        Distributions.fromString("4.1@/temp/antlr-4.1.jar"));

    assertEquals(
        newHashSet(
            distro("4.1", "/temp/antlr-4.1.jar"),
            distro("4.2", "/temp/antlr-4.2.jar")
        ),
        Distributions.fromString("4.1@/temp/antlr-4.1.jar:4.2@/temp/antlr-4.2.jar"));
  }

  public Pair<String, String> distro(final String version, final String path) {
    return new Pair<String, String>(version, path);
  }
}
