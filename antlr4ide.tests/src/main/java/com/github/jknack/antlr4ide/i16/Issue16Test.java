package com.github.jknack.antlr4ide.i16;

import static org.easymock.EasyMock.createMock;
import static org.easymock.EasyMock.expect;
import static org.easymock.EasyMock.replay;
import static org.easymock.EasyMock.verify;
import static org.junit.Assert.assertEquals;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.runtime.IPath;
import org.eclipse.core.runtime.Path;
import org.junit.Test;

import com.github.jknack.antlr4ide.generator.ToolOptions;
import com.google.common.collect.Lists;

public class Issue16Test {

  @Test
  public void commandWithPackageNameFromAction() {
    IProject project = createMock(IProject.class);
    IPath projectPath = Path.fromOSString("home").append("project");
    IFile file = createMock(IFile.class);
    IPath filePath = Path.fromOSString("home").append("project").append("Hello.g4");
    IPath outputPath = Path.fromOSString("target").append("generated-sources").append("antlr4");

    expect(file.getProject()).andReturn(project);
    expect(file.getLocation()).andReturn(filePath);

    expect(project.getLocation()).andReturn(projectPath);

    Object[] mocks = {file, project };

    replay(mocks);

    ToolOptions options = new ToolOptions();
    options.setPackageName("org.package");
    options.setPackageInsideAction(true);
    options.setOutputDirectory(outputPath.toOSString());
    assertEquals(Lists
        .newArrayList("-o", projectPath.append(outputPath).append("org").append("package")
            .toOSString(), "-listener", "-no-visitor", "-encoding",
            "UTF-8"),
        options.command(file));

    verify(mocks);
  }
}
