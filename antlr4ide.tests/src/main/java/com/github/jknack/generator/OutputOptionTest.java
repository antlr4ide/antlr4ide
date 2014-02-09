package com.github.jknack.generator;

import static org.junit.Assert.assertEquals;

import org.eclipse.core.runtime.IPath;
import org.eclipse.core.runtime.Path;
import org.junit.Test;

public class OutputOptionTest {

  @Test
  public void newOutputOption() {
    IPath absolutePath = Path.fromOSString("absolutePath");
    IPath relativePath = Path.fromOSString("relativePath");
    String packageName = "org.demo";

    OutputOption option = new OutputOption(absolutePath, relativePath, packageName);
    assertEquals(absolutePath, option.getAbsolute());
    assertEquals(relativePath, option.getRelative());
    assertEquals(packageName, option.getPackageName());
  }
}
