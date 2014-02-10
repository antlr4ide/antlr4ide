package com.github.jknack.antlr4ide.generator;

import static com.google.common.collect.Sets.newHashSet;
import static org.easymock.EasyMock.capture;
import static org.easymock.EasyMock.createMock;
import static org.easymock.EasyMock.eq;
import static org.easymock.EasyMock.expect;
import static org.easymock.EasyMock.isA;
import static org.easymock.EasyMock.replay;
import static org.easymock.EasyMock.verify;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;

import java.util.Set;

import org.easymock.Capture;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IWorkspaceRoot;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IPath;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.NullProgressMonitor;
import org.eclipse.core.runtime.Path;
import org.eclipse.debug.core.ILaunchConfiguration;
import org.eclipse.debug.core.ILaunchConfigurationType;
import org.eclipse.debug.core.ILaunchManager;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.powermock.api.easymock.PowerMock;
import org.powermock.core.classloader.annotations.PrepareForTest;
import org.powermock.modules.junit4.PowerMockRunner;

import com.github.jknack.antlr4ide.console.Console;
import com.google.common.base.Function;

@RunWith(PowerMockRunner.class)
@PrepareForTest({Antlr4Generator.class, Jobs.class })
public class Antlr4GeneratorTest {

  @Test
  public void doGenerate() throws CoreException {
    Resource resource = createMock(Resource.class);
    IFileSystemAccess fsa = createMock(IFileSystemAccess.class);
    IWorkspaceRoot workspaceRoot = createMock(IWorkspaceRoot.class);
    URI resourceURI = createMock(URI.class);
    String path = "/antlr4/Test.g4";
    IFile file = createMock(IFile.class);
    ToolOptionsProvider optionsProvider = createMock(ToolOptionsProvider.class);
    ToolOptions options = createMock(ToolOptions.class);
    ILaunchManager launchManager = createMock(ILaunchManager.class);
    IPath fileFullPath = createMock(IPath.class);
    ILaunchConfigurationType configType = createMock(ILaunchConfigurationType.class);
    ILaunchConfiguration[] configs = {};
    CodeGeneratorListener listener = createMock(CodeGeneratorListener.class);
    Set<CodeGeneratorListener> listeners = newHashSet(listener);
    ToolRunner toolRunner = createMock(ToolRunner.class);
    Console console = createMock(Console.class);

    expect(resource.getURI()).andReturn(resourceURI);
    expect(resourceURI.toPlatformString(true)).andReturn(path);

    expect(workspaceRoot.getFile(Path.fromPortableString(path))).andReturn(file);

    expect(optionsProvider.options(file)).andReturn(options);

    expect(file.getFullPath()).andReturn(fileFullPath);
    expect(fileFullPath.toOSString()).andReturn("/home/demo" + path);

    expect(launchManager.getLaunchConfigurationType("com.github.jknack.Antlr4.tool"))
        .andReturn(configType);
    expect(launchManager.getLaunchConfigurations(configType)).andReturn(configs);

    listener.beforeProcess(file, options);

    toolRunner.run(file, options, console);

    listener.afterProcess(file, options);

    Object[] mocks = {resource, fsa, workspaceRoot, resourceURI, file, optionsProvider, options,
        launchManager, fileFullPath, configType, listener, toolRunner, console };

    replay(mocks);

    Antlr4Generator generator = newAntlr4Generator(console, launchManager, listeners,
        optionsProvider, toolRunner, workspaceRoot);

    generator.doGenerate(resource, fsa);

    verify(mocks);
  }

  public Antlr4Generator newAntlr4Generator(final Console console,
      final ILaunchManager launchManager, final Set<CodeGeneratorListener> listeners,
      final ToolOptionsProvider optionsProvider, final ToolRunner toolRunner,
      final IWorkspaceRoot workspaceRoot) {
    Antlr4Generator generator = new Antlr4Generator();
    generator.setWorkspaceRoot(workspaceRoot);
    generator.setOptionsProvider(optionsProvider);
    generator.setLaunchManager(launchManager);
    generator.setListeners(listeners);
    generator.setToolRunner(toolRunner);
    generator.setConsole(console);

    return generator;
  }

  @Test
  public void doGenerateWithCustomLaunch() throws CoreException {
    Resource resource = createMock(Resource.class);
    IFileSystemAccess fsa = createMock(IFileSystemAccess.class);
    IWorkspaceRoot workspaceRoot = createMock(IWorkspaceRoot.class);
    URI resourceURI = createMock(URI.class);
    String path = "/antlr4/Test.g4";
    String absPath = "/home/demo" + path;
    IFile file = createMock(IFile.class);
    ToolOptionsProvider optionsProvider = createMock(ToolOptionsProvider.class);
    ToolOptions options = createMock(ToolOptions.class);
    ILaunchManager launchManager = createMock(ILaunchManager.class);
    IPath fileFullPath = createMock(IPath.class);
    ILaunchConfigurationType configType = createMock(ILaunchConfigurationType.class);
    ILaunchConfiguration launchConfig = createMock(ILaunchConfiguration.class);
    ILaunchConfiguration[] configs = {launchConfig };
    CodeGeneratorListener listener = createMock(CodeGeneratorListener.class);
    Set<CodeGeneratorListener> listeners = newHashSet(listener);
    ToolRunner toolRunner = createMock(ToolRunner.class);
    Console console = createMock(Console.class);
    String args = "-listener -visitor -o .";
    String toolPath = "/home/demo/antlr/antlr-4.1-complete.jar";

    expect(resource.getURI()).andReturn(resourceURI);
    expect(resourceURI.toPlatformString(true)).andReturn(path);

    expect(workspaceRoot.getFile(Path.fromPortableString(path))).andReturn(file);

    expect(optionsProvider.options(file)).andReturn(options);

    expect(file.getFullPath()).andReturn(fileFullPath);
    expect(fileFullPath.toOSString()).andReturn(absPath);

    expect(launchManager.getLaunchConfigurationType("com.github.jknack.Antlr4.tool"))
        .andReturn(configType);
    expect(launchManager.getLaunchConfigurations(configType)).andReturn(configs);

    expect(launchConfig.getAttribute(LaunchConstants.GRAMMAR, "")).andReturn(absPath)
        .times(2);

    expect(launchConfig.getAttribute(LaunchConstants.ARGUMENTS, "")).andReturn(args);

    expect(options.getAntlrTool()).andReturn(toolPath);

    listener.beforeProcess(eq(file), isA(ToolOptions.class));

    Capture<ToolOptions> customOptions = new Capture<ToolOptions>();
    toolRunner.run(eq(file), capture(customOptions), eq(console));

    listener.afterProcess(eq(file), isA(ToolOptions.class));

    Object[] mocks = {resource, fsa, workspaceRoot, resourceURI, file, optionsProvider, options,
        launchManager, fileFullPath, configType, listener, toolRunner, console, launchConfig };

    replay(mocks);

    Antlr4Generator generator = newAntlr4Generator(console, launchManager, listeners,
        optionsProvider, toolRunner, workspaceRoot);

    generator.doGenerate(resource, fsa);
    assertNotNull(customOptions.getValue());
    assertEquals(true, customOptions.getValue().isListener());
    assertEquals(true, customOptions.getValue().isVisitor());
    assertEquals(".", customOptions.getValue().getOutputDirectory());
    assertEquals(toolPath, customOptions.getValue().getAntlrTool());

    verify(mocks);
  }

  @Test
  public void doGenerateWithoutCustomLaunch() throws CoreException {
    Resource resource = createMock(Resource.class);
    IFileSystemAccess fsa = createMock(IFileSystemAccess.class);
    IWorkspaceRoot workspaceRoot = createMock(IWorkspaceRoot.class);
    URI resourceURI = createMock(URI.class);
    String path = "/antlr4/Test.g4";
    String absPath = "/home/demo" + path;
    IFile file = createMock(IFile.class);
    ToolOptionsProvider optionsProvider = createMock(ToolOptionsProvider.class);
    ToolOptions options = createMock(ToolOptions.class);
    ILaunchManager launchManager = createMock(ILaunchManager.class);
    IPath fileFullPath = createMock(IPath.class);
    ILaunchConfigurationType configType = createMock(ILaunchConfigurationType.class);
    ILaunchConfiguration launchConfig = createMock(ILaunchConfiguration.class);
    ILaunchConfiguration[] configs = {launchConfig };
    CodeGeneratorListener listener = createMock(CodeGeneratorListener.class);
    Set<CodeGeneratorListener> listeners = newHashSet(listener);
    ToolRunner toolRunner = createMock(ToolRunner.class);
    Console console = createMock(Console.class);

    expect(resource.getURI()).andReturn(resourceURI);
    expect(resourceURI.toPlatformString(true)).andReturn(path);

    expect(workspaceRoot.getFile(Path.fromPortableString(path))).andReturn(file);

    expect(optionsProvider.options(file)).andReturn(options);

    expect(file.getFullPath()).andReturn(fileFullPath);
    expect(fileFullPath.toOSString()).andReturn(absPath);

    expect(launchManager.getLaunchConfigurationType("com.github.jknack.Antlr4.tool"))
        .andReturn(configType);
    expect(launchManager.getLaunchConfigurations(configType)).andReturn(configs);

    expect(launchConfig.getAttribute(LaunchConstants.GRAMMAR, "")).andReturn("Hello.g4");

    listener.beforeProcess(file, options);

    toolRunner.run(file, options, console);

    listener.afterProcess(file, options);

    Object[] mocks = {resource, fsa, workspaceRoot, resourceURI, file, optionsProvider, options,
        launchManager, fileFullPath, configType, listener, toolRunner, console, launchConfig };

    replay(mocks);

    Antlr4Generator generator = newAntlr4Generator(console, launchManager, listeners,
        optionsProvider, toolRunner, workspaceRoot);

    generator.doGenerate(resource, fsa);

    verify(mocks);
  }

  @Test
  public void generate() throws CoreException {
    IWorkspaceRoot workspaceRoot = createMock(IWorkspaceRoot.class);
    IFile file = createMock(IFile.class);
    ToolOptionsProvider optionsProvider = createMock(ToolOptionsProvider.class);
    ToolOptions options = createMock(ToolOptions.class);
    ILaunchManager launchManager = createMock(ILaunchManager.class);
    CodeGeneratorListener listener = createMock(CodeGeneratorListener.class);
    Set<CodeGeneratorListener> listeners = newHashSet(listener);
    ToolRunner toolRunner = createMock(ToolRunner.class);
    Console console = createMock(Console.class);

    expect(file.getName()).andReturn("Test.g4");

    listener.beforeProcess(file, options);

    toolRunner.run(file, options, console);

    listener.afterProcess(file, options);

    PowerMock.mockStatic(Jobs.class);

    Capture<Function<IProgressMonitor, IStatus>> fn = new Capture<Function<IProgressMonitor, IStatus>>();

    expect(Jobs.schedule(eq("Generating Test.g4"), capture(fn))).andReturn(null);

    PowerMock.replay(Jobs.class);

    Object[] mocks = {file, optionsProvider, options, launchManager, listener, toolRunner, console };

    replay(mocks);

    Antlr4Generator generator = newAntlr4Generator(console, launchManager, listeners,
        optionsProvider, toolRunner, workspaceRoot);

    generator.generate(file, options);

    assertNotNull(fn.getValue());
    fn.getValue().apply(new NullProgressMonitor());

    verify(mocks);
    PowerMock.verify(Jobs.class);
  }
}
