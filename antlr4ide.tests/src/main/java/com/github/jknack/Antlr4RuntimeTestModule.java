package com.github.jknack;

import java.util.Set;

import org.easymock.EasyMock;
import org.eclipse.core.resources.IWorkspaceRoot;

import com.github.jknack.console.Console;
import com.github.jknack.generator.CodeGeneratorListener;
import com.github.jknack.generator.ToolOptionsProvider;
import com.google.common.collect.Sets;
import com.google.inject.Binder;
import com.google.inject.Provides;

public class Antlr4RuntimeTestModule extends Antlr4RuntimeModule {

  public static IWorkspaceRoot workspaceRoot = EasyMock.createMock(IWorkspaceRoot.class);

  public static ToolOptionsProvider optionsProvider = EasyMock.createMock(ToolOptionsProvider.class);

  public static Console console = EasyMock.createMock(Console.class);

  @Override
  public void configure(final Binder binder) {
    super.configure(binder);
    binder.bind(IWorkspaceRoot.class).toInstance(workspaceRoot);

    binder.bind(ToolOptionsProvider.class).toInstance(optionsProvider);

    binder.bind(Console.class).toInstance(console);
  }

  @Provides
  public Set<CodeGeneratorListener> codeGeneratorListeners() {
    return Sets.<CodeGeneratorListener> newHashSet();
  }
}
