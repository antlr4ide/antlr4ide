package com.github.jknack.antlr4ide;

import java.util.Set;

import org.easymock.EasyMock;
import org.eclipse.core.resources.IWorkspaceRoot;
import org.eclipse.debug.core.ILaunchManager;

import com.github.jknack.antlr4ide.console.Console;
import com.github.jknack.antlr4ide.generator.CodeGeneratorListener;
import com.github.jknack.antlr4ide.generator.ToolOptionsProvider;
import com.github.jknack.antlr4ide.services.GrammarResource;
import com.google.common.collect.Sets;
import com.google.inject.Binder;
import com.google.inject.Provides;

public class Antlr4RuntimeTestModule extends Antlr4RuntimeModule {

  public static IWorkspaceRoot workspaceRoot = EasyMock.createMock(IWorkspaceRoot.class);

  public static ToolOptionsProvider optionsProvider = EasyMock.createMock(ToolOptionsProvider.class);

  public static Console console = EasyMock.createMock(Console.class);

  public static GrammarResource grammarResource = EasyMock.createMock(GrammarResource.class);

  public static ILaunchManager launchManager = EasyMock.createMock(ILaunchManager.class);

  @Override
  public void configure(final Binder binder) {
    super.configure(binder);
    binder.bind(IWorkspaceRoot.class).toInstance(workspaceRoot);

    binder.bind(ToolOptionsProvider.class).toInstance(optionsProvider);

    binder.bind(Console.class).toInstance(console);

    binder.bind(GrammarResource.class).toInstance(grammarResource);
  }

  @Provides
  public Set<CodeGeneratorListener> codeGeneratorListeners() {
    return Sets.<CodeGeneratorListener> newHashSet();
  }

  @Override
  protected ILaunchManager getLaunchManager() {
    return launchManager;
  }
}
