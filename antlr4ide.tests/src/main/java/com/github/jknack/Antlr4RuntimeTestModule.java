package com.github.jknack;

import com.github.jknack.Antlr4RuntimeModule;
import com.google.inject.Binder;
import org.eclipse.core.resources.IWorkspaceRoot;
import org.easymock.EasyMock;
import com.github.jknack.generator.ToolOptionsProvider;
import com.github.jknack.console.Console;

public class Antlr4RuntimeTestModule extends Antlr4RuntimeModule {

  public static IWorkspaceRoot workspaceRoot = EasyMock.createMock(IWorkspaceRoot.class);

  public static ToolOptionsProvider optionsProvider = EasyMock.createMock(ToolOptionsProvider.class);

  public static Console console = EasyMock.createMock(Console.class);

  public void configure(Binder binder) {
    super.configure(binder);
    binder.bind(IWorkspaceRoot.class).toInstance(workspaceRoot);

    binder.bind(ToolOptionsProvider.class).toInstance(optionsProvider);

    binder.bind(Console.class).toInstance(console);
  }

}
