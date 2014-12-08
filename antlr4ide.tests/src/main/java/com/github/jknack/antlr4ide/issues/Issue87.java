package com.github.jknack.antlr4ide.issues;

import static org.easymock.EasyMock.createMock;
import static org.easymock.EasyMock.expect;
import static org.easymock.EasyMock.replay;
import static org.easymock.EasyMock.verify;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.runtime.IPath;
import org.eclipse.core.runtime.Path;
import org.junit.Test;

import com.github.jknack.antlr4ide.generator.OutputOption;
import com.github.jknack.antlr4ide.generator.ToolOptions;

public class Issue87 {

  @Test
  public void guessPackageNameFromAntlrSrc() {
    IProject project = createMock(IProject.class);
    IPath projectPath = Path.fromOSString("home").append("project");
    IFile file = createMock(IFile.class);
    IPath filePath = Path.fromOSString("home").append("project").append("antlr-src")
        .append("org").append("demo").append("Hello.g4");
    IPath outputPath = Path.fromOSString("target").append("generated-sources").append("antlr4");

    expect(file.getProject()).andReturn(project);
    expect(file.getLocation()).andReturn(filePath);

    expect(project.getLocation()).andReturn(projectPath);

    Object[] mocks = {file, project };

    replay(mocks);

    ToolOptions options = new ToolOptions();
    options.setOutputDirectory(outputPath.toOSString());

    OutputOption output = options.output(file);
    assertNotNull(output);

    assertPath(projectPath.append(outputPath).append("org").append("demo"), output.getAbsolute());

    assertPath(Path.fromPortableString("/").append(outputPath).append("org").append("demo"),
        output.getRelative());

    assertEquals("org.demo", output.getPackageName());

    verify(mocks);
  }

  @Test
  public void guessPackageNameFromAntlrSource() {
    IProject project = createMock(IProject.class);
    IPath projectPath = Path.fromOSString("home").append("project");
    IFile file = createMock(IFile.class);
    IPath filePath = Path.fromOSString("home").append("project").append("antlr-source")
        .append("org").append("demo").append("Hello.g4");
    IPath outputPath = Path.fromOSString("target").append("generated-sources").append("antlr4");

    expect(file.getProject()).andReturn(project);
    expect(file.getLocation()).andReturn(filePath);

    expect(project.getLocation()).andReturn(projectPath);

    Object[] mocks = {file, project };

    replay(mocks);

    ToolOptions options = new ToolOptions();
    options.setOutputDirectory(outputPath.toOSString());

    OutputOption output = options.output(file);
    assertNotNull(output);

    assertPath(projectPath.append(outputPath).append("org").append("demo"), output.getAbsolute());

    assertPath(Path.fromPortableString("/").append(outputPath).append("org").append("demo"),
        output.getRelative());

    assertEquals("org.demo", output.getPackageName());

    verify(mocks);
  }

  private void assertPath(final IPath expected, final IPath path) {
    assertEquals(normalize(expected), normalize(path));
  }

  private String normalize(final IPath path) {
    return path.toPortableString().replace("\\", "/");
  }

}
