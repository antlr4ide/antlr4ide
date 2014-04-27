package com.github.jknack.antlr4ide.generator;

import static com.google.common.collect.Sets.newHashSet;
import static org.easymock.EasyMock.capture;
import static org.easymock.EasyMock.createMock;
import static org.easymock.EasyMock.eq;
import static org.easymock.EasyMock.expect;
import static org.easymock.EasyMock.replay;
import static org.easymock.EasyMock.verify;
import static org.junit.Assert.assertNotNull;

import java.util.Set;

import org.easymock.Capture;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IPath;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.NullProgressMonitor;
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
import com.github.jknack.antlr4ide.services.GrammarResource;
import com.google.common.base.Function;

@RunWith(PowerMockRunner.class)
@PrepareForTest({Antlr4Generator.class, Jobs.class })
public class Antlr4GeneratorTest {

  @Test
  public void doGenerate() throws CoreException {
    Resource resource = createMock(Resource.class);
    IFileSystemAccess fsa = createMock(IFileSystemAccess.class);
    GrammarResource grammarResource = createMock(GrammarResource.class);
    URI resourceURI = createMock(URI.class);
    IFile file = createMock(IFile.class);
    ToolOptionsProvider optionsProvider = createMock(ToolOptionsProvider.class);
    ToolOptions options = createMock(ToolOptions.class);
    ILaunchManager launchManager = createMock(ILaunchManager.class);
    IPath fileFullPath = createMock(IPath.class);
    ILaunchConfigurationType configType = createMock(ILaunchConfigurationType.class);
    CodeGeneratorListener listener = createMock(CodeGeneratorListener.class);
    Set<CodeGeneratorListener> listeners = newHashSet(listener);
    ToolRunner toolRunner = createMock(ToolRunner.class);
    Console console = createMock(Console.class);

    expect(grammarResource.fileFrom(resource)).andReturn(file);

    expect(optionsProvider.options(file)).andReturn(options);

    listener.beforeProcess(file, options);

    toolRunner.run(file, options, console);

    listener.afterProcess(file, options);

    Object[] mocks = {resource, fsa, grammarResource, resourceURI, file, optionsProvider, options,
        fileFullPath, configType, listener, toolRunner, console };

    replay(mocks);

    Antlr4Generator generator = newAntlr4Generator(console, launchManager, listeners,
        optionsProvider, toolRunner, grammarResource);

    generator.doGenerate(resource, fsa);

    verify(mocks);
  }

  public Antlr4Generator newAntlr4Generator(final Console console,
      final ILaunchManager launchManager, final Set<CodeGeneratorListener> listeners,
      final ToolOptionsProvider optionsProvider, final ToolRunner toolRunner,
      final GrammarResource grammarResource) {
    Antlr4Generator generator = new Antlr4Generator();
    generator.setGrammarResource(grammarResource);
    generator.setOptionsProvider(optionsProvider);
    generator.setListeners(listeners);
    generator.setToolRunner(toolRunner);
    generator.setConsole(console);

    return generator;
  }

  @Test
  public void generate() throws CoreException {
    GrammarResource grammarResource = createMock(GrammarResource.class);
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
        optionsProvider, toolRunner, grammarResource);

    generator.generate(file, options);

    assertNotNull(fn.getValue());
    fn.getValue().apply(new NullProgressMonitor());

    verify(mocks);
    PowerMock.verify(Jobs.class);
  }
}
