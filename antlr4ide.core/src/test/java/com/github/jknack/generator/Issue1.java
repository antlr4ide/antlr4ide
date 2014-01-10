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

public class Issue1 {

  @Test
  public void outputToSrcWindows() {
    IPath location = Path.fromOSString("D:\\workspace\\project");

    IProject project = createMock(IProject.class);
    expect(project.getLocation()).andReturn(location);

    IPath flocation = location.append("G.g4");
    IFile file = createMock(IFile.class);
    expect(file.getProject()).andReturn(project);
    expect(file.getLocation()).andReturn(flocation);

    Object[] mocks = {file, project };

    replay(mocks);

    ToolOptions options = new ToolOptions();
    IPath outputdir = Path.fromOSString("\\src\\antlr");
    options.setOutputDirectory(outputdir.toString());
    OutputOption output = options.output(file);
    assertNotNull(output);
    assertEquals(location.append(outputdir).toOSString(), output.getAbsolute().toOSString());
    assertEquals(outputdir.makeAbsolute(), output.getRelative());
    assertEquals("", output.getPackageName());

    verify(mocks);
  }
}
