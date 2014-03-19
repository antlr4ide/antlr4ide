package com.github.jknack.antlr4ide.generator;

import static org.easymock.EasyMock.createMock;
import static org.easymock.EasyMock.expect;
import static org.easymock.EasyMock.replay;
import static org.easymock.EasyMock.verify;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;

import java.util.Set;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.runtime.IPath;
import org.eclipse.core.runtime.Path;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1;
import org.junit.Test;

import com.google.common.base.Joiner;
import com.google.common.collect.Lists;
import com.google.common.collect.Sets;

public class ToolOptionsTest {

  @Test
  public void defaultCommand() {
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
    options.setOutputDirectory(outputPath.toOSString());
    assertEquals(Lists
        .newArrayList("-o", projectPath.append(outputPath).toOSString(), "-listener",
            "-no-visitor", "-encoding", "UTF-8"), options.command(file));

    verify(mocks);
  }

  @Test
  public void commandWithAtn() {
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
    options.setAtn(true);
    options.setOutputDirectory(outputPath.toOSString());
    assertEquals(Lists
        .newArrayList("-o", projectPath.append(outputPath).toOSString(), "-listener",
            "-no-visitor", "-atn", "-encoding", "UTF-8"), options.command(file));

    verify(mocks);
  }

  @Test
  public void commandWithEncoding() {
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
    options.setEncoding("UTF-16");
    options.setOutputDirectory(outputPath.toOSString());
    assertEquals(Lists
        .newArrayList("-o", projectPath.append(outputPath).toOSString(), "-listener",
            "-no-visitor", "-encoding", "UTF-16"), options.command(file));

    verify(mocks);
  }

  @Test
  public void commandWithExtras() {
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
    options.setExtras(Sets.newHashSet("-D"));
    options.setOutputDirectory(outputPath.toOSString());
    assertEquals(Lists
        .newArrayList("-o", projectPath.append(outputPath).toOSString(), "-listener",
            "-no-visitor", "-encoding", "UTF-8", "-D"), options.command(file));

    verify(mocks);
  }

  @Test
  public void commandWithLib() {
    IProject project = createMock(IProject.class);
    IPath projectPath = Path.fromOSString("home").append("project");
    IFile file = createMock(IFile.class);
    IPath filePath = Path.fromOSString("home").append("project").append("Hello.g4");
    IPath outputPath = Path.fromOSString("target").append("generated-sources").append("antlr4");
    IPath libPath = Path.fromOSString("home").append("project").append("lib");

    expect(file.getProject()).andReturn(project);
    expect(file.getLocation()).andReturn(filePath);

    expect(project.getLocation()).andReturn(projectPath);

    Object[] mocks = {file, project };

    replay(mocks);

    ToolOptions options = new ToolOptions();
    options.setLibDirectory(libPath.toOSString());
    options.setOutputDirectory(outputPath.toOSString());
    assertEquals(Lists
        .newArrayList("-o", projectPath.append(outputPath).toOSString(), "-listener",
            "-no-visitor", "-lib", libPath.toOSString(), "-encoding", "UTF-8"),
        options.command(file));

    verify(mocks);
  }

  @Test
  public void commandWithListener() {
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
    options.setListener(true);
    options.setOutputDirectory(outputPath.toOSString());
    assertEquals(Lists
        .newArrayList("-o", projectPath.append(outputPath).toOSString(), "-listener",
            "-no-visitor", "-encoding", "UTF-8"),
        options.command(file));

    verify(mocks);
  }

  @Test
  public void commandWithoutListener() {
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
    options.setListener(false);
    options.setOutputDirectory(outputPath.toOSString());
    assertEquals(Lists
        .newArrayList("-o", projectPath.append(outputPath).toOSString(), "-no-listener",
            "-no-visitor", "-encoding", "UTF-8"),
        options.command(file));

    verify(mocks);
  }

  @Test
  public void commandWithVisitor() {
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
    options.setVisitor(true);
    options.setOutputDirectory(outputPath.toOSString());
    assertEquals(Lists
        .newArrayList("-o", projectPath.append(outputPath).toOSString(), "-listener",
            "-visitor", "-encoding", "UTF-8"),
        options.command(file));

    verify(mocks);
  }

  @Test
  public void commandWithoutVisitor() {
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
    options.setVisitor(false);
    options.setOutputDirectory(outputPath.toOSString());
    assertEquals(Lists
        .newArrayList("-o", projectPath.append(outputPath).toOSString(), "-listener",
            "-no-visitor", "-encoding", "UTF-8"),
        options.command(file));

    verify(mocks);
  }

  @Test
  public void commandWithMessageFormat() {
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
    options.setMessageFormat("custom");
    options.setOutputDirectory(outputPath.toOSString());
    assertEquals(Lists
        .newArrayList("-o", projectPath.append(outputPath).toOSString(), "-listener",
            "-no-visitor", "-message-format", "custom", "-encoding", "UTF-8"),
        options.command(file));

    verify(mocks);
  }

  @Test
  public void commandWithPackageName() {
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
    options.setOutputDirectory(outputPath.toOSString());
    assertEquals(Lists
        .newArrayList("-o", projectPath.append(outputPath).append("org").append("package")
            .toOSString(), "-listener", "-no-visitor", "-package", "org.package", "-encoding",
            "UTF-8"),
        options.command(file));

    verify(mocks);
  }

  @Test
  public void defaults() {
    ToolOptions options = new ToolOptions();
    options.setPackageName("org.package");
    assertEquals(Lists.newArrayList("-listener", "-no-visitor", "-encoding", "UTF-8"),
        options.defaults());
  }

  @Test
  public void defaultOutput() {
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
    options.setOutputDirectory(outputPath.toOSString());

    OutputOption output = options.output(file);
    assertNotNull(output);
    assertEquals(projectPath.append(outputPath).toPortableString(), output.getAbsolute()
        .toPortableString());
    assertEquals(Path.fromPortableString("/").append(outputPath).toPortableString(), output
        .getRelative()
        .toPortableString());
    assertEquals("", output.getPackageName());

    verify(mocks);
  }

  @Test
  public void guessPackageNameFromMavenFolder() {
    IProject project = createMock(IProject.class);
    IPath projectPath = Path.fromOSString("home").append("project");
    IFile file = createMock(IFile.class);
    IPath filePath = Path.fromOSString("home").append("project").append("src").append("main")
        .append("antlr4").append("org").append("demo").append("Hello.g4");
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
  public void guessPackageNameFromSrcMainJava() {
    IProject project = createMock(IProject.class);
    IPath projectPath = Path.fromOSString("home").append("project");
    IFile file = createMock(IFile.class);
    IPath filePath = Path.fromOSString("home").append("project").append("src").append("main")
        .append("java").append("org").append("demo").append("Hello.g4");
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
  public void guessPackageNameFromSrc() {
    IProject project = createMock(IProject.class);
    IPath projectPath = Path.fromOSString("home").append("project");
    IFile file = createMock(IFile.class);
    IPath filePath = Path.fromOSString("home").append("project").append("src").append("org")
        .append("demo").append("Hello.g4");
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
  public void outputAbsolutePath() {
    IProject project = createMock(IProject.class);
    IPath projectPath = Path.fromOSString("home").append("project");
    IFile file = createMock(IFile.class);
    IPath filePath = Path.fromOSString("home").append("project").append("Hello.g4");
    IPath outputPath = Path.fromOSString("target");

    expect(file.getProject()).andReturn(project);
    expect(file.getLocation()).andReturn(filePath);

    expect(project.getLocation()).andReturn(projectPath);

    Object[] mocks = {file, project };

    replay(mocks);

    ToolOptions options = new ToolOptions();
    options.setOutputDirectory(outputPath.toOSString());

    OutputOption output = options.output(file);
    assertNotNull(output);
    assertEquals(outputPath, output.getAbsolute());
    assertEquals(outputPath, output.getRelative());
    assertEquals("", output.getPackageName());

    verify(mocks);
  }

  @Test
  public void outputProjectRoot() {
    IProject project = createMock(IProject.class);
    IPath projectPath = Path.fromOSString("home").append("project");
    IFile file = createMock(IFile.class);
    IPath filePath = Path.fromOSString("home").append("project").append("Hello.g4");
    IPath outputPath = Path.fromOSString("home").append("project");

    expect(file.getProject()).andReturn(project);
    expect(file.getLocation()).andReturn(filePath);

    expect(project.getLocation()).andReturn(projectPath);

    Object[] mocks = {file, project };

    replay(mocks);

    ToolOptions options = new ToolOptions();
    options.setOutputDirectory(outputPath.toOSString());

    OutputOption output = options.output(file);
    assertNotNull(output);
    assertEquals(Path.fromPortableString("/").append(outputPath), output.getAbsolute());
    assertEquals(Path.fromPortableString(""), output.getRelative());
    assertEquals("", output.getPackageName());

    verify(mocks);
  }

  @SuppressWarnings("unchecked")
  @Test
  public void parseCommonArgs() {
    Procedure1<String> err = createMock(Procedure1.class);

    Object[] mocks = {err };

    replay(mocks);

    ToolOptions options = ToolOptions
        .parse(
            "-o . -lib lib -encoding UTF-16 -message-format eclipse -listener -visitor -package org.demo",
            err);
    assertNotNull(options);
    assertEquals(".", options.getOutputDirectory());
    assertEquals("lib", options.getLibDirectory());
    assertEquals("UTF-16", options.getEncoding());
    assertEquals("eclipse", options.getMessageFormat());
    assertEquals(true, options.isListener());
    assertEquals(true, options.isVisitor());
    assertEquals("org.demo", options.getPackageName());

    verify(mocks);
  }

  @SuppressWarnings("unchecked")
  @Test
  public void parseNoVisitorNoListener() {
    Procedure1<String> err = createMock(Procedure1.class);

    Object[] mocks = {err };

    replay(mocks);

    ToolOptions options = ToolOptions.parse("-no-listener -no-visitor", err);
    assertNotNull(options);
    assertEquals(false, options.isListener());
    assertEquals(false, options.isVisitor());

    verify(mocks);
  }

  @SuppressWarnings("unchecked")
  @Test
  public void parseExtraArgs() {
    Procedure1<String> err = createMock(Procedure1.class);

    Object[] mocks = {err };

    replay(mocks);

    Set<String> extras = Sets.newHashSet("-Dlanguage=Xxx", "-Werror",
        "-Xsave-lexer", "-XdbgST", "-Xforce-atn", "-Xlog", "-XdbgSTWait");
    ToolOptions options = ToolOptions.parse("-atn " + Joiner.on(" ").join(extras), err);
    assertNotNull(options);
    assertEquals(extras, options.getExtras());
    assertEquals(true, options.isAtn());

    verify(mocks);
  }

  @SuppressWarnings("unchecked")
  @Test
  public void parseBadOption() {
    Procedure1<String> err = createMock(Procedure1.class);

    err.apply("Unknown command-line option: '-bad'");

    Object[] mocks = {err };

    replay(mocks);

    ToolOptions options = ToolOptions.parse("-bad", err);
    assertNotNull(options);

    verify(mocks);
  }

  @SuppressWarnings("unchecked")
  @Test
  public void parseBadOutput() {
    Procedure1<String> err = createMock(Procedure1.class);

    err.apply("Bad command-line option: '-o'");

    Object[] mocks = {err };

    replay(mocks);

    ToolOptions options = ToolOptions.parse("-o", err);
    assertNotNull(options);

    verify(mocks);
  }

  @SuppressWarnings("unchecked")
  @Test
  public void parseBadLib() {
    Procedure1<String> err = createMock(Procedure1.class);

    err.apply("Bad command-line option: '-lib'");

    Object[] mocks = {err };

    replay(mocks);

    ToolOptions options = ToolOptions.parse("-lib ", err);
    assertNotNull(options);

    verify(mocks);
  }

  @SuppressWarnings("unchecked")
  @Test
  public void parseBadEncoding() {
    Procedure1<String> err = createMock(Procedure1.class);

    err.apply("Bad command-line option: '-encoding'");

    Object[] mocks = {err };

    replay(mocks);

    ToolOptions options = ToolOptions.parse("-encoding ", err);
    assertNotNull(options);

    verify(mocks);
  }

  @SuppressWarnings("unchecked")
  @Test
  public void parseBadMessageFormat() {
    Procedure1<String> err = createMock(Procedure1.class);

    err.apply("Bad command-line option: '-message-format'");

    Object[] mocks = {err };

    replay(mocks);

    ToolOptions options = ToolOptions.parse("-message-format ", err);
    assertNotNull(options);

    verify(mocks);
  }

  private void assertPath(final IPath expected, final IPath path) {
    assertEquals(normalize(expected), normalize(path));
  }

  private String normalize(final IPath path) {
    return path.toPortableString().replace("\\", "/");
  }
}
