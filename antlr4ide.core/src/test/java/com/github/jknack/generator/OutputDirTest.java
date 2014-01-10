package com.github.jknack.generator;

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

public class OutputDirTest {

  private IPath rootPath = Path.fromOSString(System.getProperty("java.io.tmpdir"));

  @Test
  public void outsideWorkspace() {
    IPath location = rootPath.append("workspace").append("antlr4");

    IProject project = createMock(IProject.class);
    expect(project.getLocation()).andReturn(location);

    IPath flocation = location.append("G.g4");
    IFile file = createMock(IFile.class);
    expect(file.getProject()).andReturn(project);
    expect(file.getLocation()).andReturn(flocation);

    Object[] mocks = {file, project };

    replay(mocks);

    ToolOptions options = new ToolOptions();
    options.setOutputDirectory(rootPath.toOSString());
    OutputOption output = options.output(file);
    assertNotNull(output);
    assertEquals(rootPath, output.getAbsolute());
    assertEquals(rootPath.lastSegment(), output.getRelative().lastSegment());
    assertEquals("", output.getPackageName());

    verify(mocks);
  }

  @Test
  public void insideWorkspace() {
    IPath location = rootPath.append("workspace").append("antlr4");

    IProject project = createMock(IProject.class);
    expect(project.getLocation()).andReturn(location);

    IPath flocation = location.append("G.g4");
    IFile file = createMock(IFile.class);
    expect(file.getProject()).andReturn(project);
    expect(file.getLocation()).andReturn(flocation);

    Object[] mocks = {file, project };

    replay(mocks);

    ToolOptions options = new ToolOptions();
    IPath outputdir = Path.fromPortableString("target/generated-sources/antlr4");
    options.setOutputDirectory(outputdir.toString());
    OutputOption output = options.output(file);
    assertNotNull(output);
    assertEquals(location.append(outputdir), output.getAbsolute());
    assertEquals(outputdir.makeAbsolute(), output.getRelative());
    assertEquals("", output.getPackageName());

    verify(mocks);
  }

  @Test
  public void srcPackageDirL1Workspace() {
    IPath location = rootPath.append("workspace").append("antlr4");

    IProject project = createMock(IProject.class);
    expect(project.getLocation()).andReturn(location);

    IPath flocation = location.append("src").append("org").append("G.g4");
    IFile file = createMock(IFile.class);
    expect(file.getProject()).andReturn(project);
    expect(file.getLocation()).andReturn(flocation);

    Object[] mocks = {file, project };

    replay(mocks);

    ToolOptions options = new ToolOptions();
    IPath outputdir = Path.fromPortableString("target/generated-sources/antlr4");
    options.setOutputDirectory(outputdir.toString());
    OutputOption output = options.output(file);
    assertNotNull(output);
    assertEquals(location.append(outputdir).append("org"), output.getAbsolute());
    assertEquals(outputdir.append("org").makeAbsolute(), output.getRelative());
    assertEquals("org", output.getPackageName());

    verify(mocks);
  }

  @Test
  public void srcPackageDirL2Workspace() {
    IPath location = rootPath.append("workspace").append("antlr4");

    IProject project = createMock(IProject.class);
    expect(project.getLocation()).andReturn(location);

    IPath flocation = location.append("src").append("org").append("demo").append("G.g4");
    IFile file = createMock(IFile.class);
    expect(file.getProject()).andReturn(project);
    expect(file.getLocation()).andReturn(flocation);

    Object[] mocks = {file, project };

    replay(mocks);

    ToolOptions options = new ToolOptions();
    IPath outputdir = Path.fromPortableString("target/generated-sources/antlr4");
    options.setOutputDirectory(outputdir.toString());
    OutputOption output = options.output(file);
    assertNotNull(output);
    assertEquals(location.append(outputdir).append("org").append("demo"), output.getAbsolute());
    assertEquals(outputdir.append("org").append("demo").makeAbsolute(), output.getRelative());
    assertEquals("org.demo", output.getPackageName());

    verify(mocks);
  }

}
