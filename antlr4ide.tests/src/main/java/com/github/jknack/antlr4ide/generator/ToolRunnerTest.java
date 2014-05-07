package com.github.jknack.antlr4ide.generator;

import static org.easymock.EasyMock.createMock;
import static org.easymock.EasyMock.eq;
import static org.easymock.EasyMock.expect;
import static org.easymock.EasyMock.isA;
import static org.easymock.EasyMock.replay;
import static org.easymock.EasyMock.verify;

import java.io.File;
import java.io.InputStream;
import java.util.List;

import org.eclipse.core.resources.IContainer;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.runtime.IPath;
import org.eclipse.core.runtime.Path;
import org.eclipse.core.runtime.QualifiedName;
import org.eclipse.xtext.util.StringInputStream;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.powermock.api.easymock.PowerMock;
import org.powermock.core.classloader.annotations.PrepareForTest;
import org.powermock.modules.junit4.PowerMockRunner;

import com.github.jknack.antlr4ide.console.Console;
import com.google.common.base.Joiner;
import com.google.common.collect.Lists;

@RunWith(PowerMockRunner.class)
@PrepareForTest({ToolRunner.class, ProcessBuilder.class })
public class ToolRunnerTest {

  @Test
  public void run() throws Exception {
    String[] vmArgs = {};
    String fileName = "Hello.g4";
    InputStream toolStream = new StringInputStream(
        "warning: warning message\nerror: undefined rule: 'x'");
    InputStream dependStream = new StringInputStream("");

    QualifiedName generatedFiles = new QualifiedName("antlr4ide", "generatedFiles");

    IPath fileFullPath = Path.fromOSString("home").append("demo").append("project")
        .append(fileName);
    IPath fileParentPath = fileFullPath.removeLastSegments(1);
    IPath toolPath = Path.fromOSString("..").append("antlr4ide.core").append("lib")
        .append(ToolOptionsProvider.DEFAULT_TOOL);

    IPath lexerPath = fileFullPath.removeLastSegments(1).append("HelloLexer.java");
    IPath parserPath = fileFullPath.removeLastSegments(1).append("HelloParser.java");

    List<String> command = Lists.newArrayList("-o", ".", "-listener", "-no-visitor");
    List<String> toolCommand = Lists.newArrayList(
        "java",
        "-cp",
        toolPath.toFile().getAbsolutePath() + File.pathSeparator
            + toolPath.removeLastSegments(1).toFile().getAbsolutePath(),
        ToolOptionsProvider.TOOL,
        fileName);
    toolCommand.addAll(command);

    List<String> dependCommand = Lists.newArrayList(
        "java",
        "-cp",
        toolPath.toFile().getAbsolutePath() + File.pathSeparator
            + toolPath.removeLastSegments(1).toFile().getAbsolutePath(),
        ToolOptionsProvider.TOOL,
        fileName);
    dependCommand.add("-depend");
    dependCommand.addAll(command);

    IFile file = createMock(IFile.class);
    IContainer fileParent = createMock(IContainer.class);
    ToolOptions options = createMock(ToolOptions.class);
    ProcessBuilder toolPb = PowerMock.createMock(ProcessBuilder.class);
    Process toolProcess = createMock(Process.class);
    ProcessBuilder dependPb = PowerMock.createMock(ProcessBuilder.class);
    Process dependProcess = createMock(Process.class);

    Console console = createMock(Console.class);

    console.info("ANTLR Tool v%s (%s)", ToolOptionsProvider.VERSION, toolPath.toFile());
    console.info("%s %s", fileName, Joiner.on(" ").join(command));
    console.info("warning: warning message");
    console.error("error: undefined rule: 'x'");

    console.error("\n%s warning(s)\n", 1);
    console.error("%s error(s)\n", 1);

    console.error("BUILD FAIL");

    console.info(eq("Total time: %s %s(s)\n"), isA(Number.class), eq("millisecond"));

    expect(file.getName()).andReturn(fileName);
    expect(file.getPersistentProperty(generatedFiles)).andReturn(
        lexerPath.toOSString() + File.separator + parserPath.toOSString());
    expect(file.getParent()).andReturn(fileParent).times(3);
    expect(fileParent.getLocation()).andReturn(fileParentPath).times(3);

    expect(options.getAntlrTool()).andReturn(toolPath.toOSString());
    expect(options.isCleanUpDerivedResources()).andReturn(true);
    expect(options.vmArguments()).andReturn(vmArgs);
    expect(options.getLibDirectory()).andReturn("libdir");
    expect(options.command(file)).andReturn(command);

    PowerMock.expectNew(ProcessBuilder.class, (Object[]) toolCommand.toArray(new String[0]))
        .andReturn(toolPb);
    expect(toolPb.directory(fileParentPath.toFile())).andReturn(toolPb);
    expect(toolPb.start()).andReturn(toolProcess);

    expect(toolProcess.getErrorStream()).andReturn(toolStream);
    expect(toolProcess.waitFor()).andReturn(0);
    toolProcess.destroy();

    PowerMock.expectNew(ProcessBuilder.class, (Object[]) dependCommand.toArray(new String[0]))
        .andReturn(dependPb);
    expect(dependPb.directory(fileParentPath.toFile())).andReturn(dependPb);
    expect(dependPb.start()).andReturn(dependProcess);

    expect(dependProcess.getInputStream()).andReturn(dependStream);
    expect(dependProcess.waitFor()).andReturn(0);
    dependProcess.destroy();

    file.setPersistentProperty(generatedFiles, null);

    Object[] mocks = {file, options, console, fileParent, toolProcess, dependProcess };

    replay(mocks);
    PowerMock.replay(toolPb, dependPb, ProcessBuilder.class);

    new ToolRunner().run(file, options, console);

    verify(mocks);
    PowerMock.verify(toolPb, dependPb, ProcessBuilder.class);
  }
}
