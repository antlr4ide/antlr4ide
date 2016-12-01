package com.github.jknack.antlr4ide;

import static org.easymock.EasyMock.createMock;
import static org.easymock.EasyMock.createNiceMock;
import static org.easymock.EasyMock.expect;
import static org.easymock.EasyMock.replay;
import static org.easymock.EasyMock.verify;
import static org.junit.Assert.assertEquals;

import org.eclipse.debug.core.ILaunchManager;
import org.eclipse.xtext.linking.ILinkingDiagnosticMessageProvider;
import org.junit.Test;

import com.github.jknack.antlr4ide.console.Console;
import com.github.jknack.antlr4ide.generator.Antlr4OutputConfigurationProvider;
import com.github.jknack.antlr4ide.lang.LangFactory;
import com.github.jknack.antlr4ide.scoping.Antlr4NameProvider;
import com.github.jknack.antlr4ide.validation.Antlr4MissingReferenceMessageProvider;
import com.google.inject.Binder;
import com.google.inject.binder.AnnotatedBindingBuilder;

public class Antlr4RuntimeModuleTest {

  @SuppressWarnings("unchecked")
  @Test
  public void configure() {
    Binder binder = createNiceMock(Binder.class);
    AnnotatedBindingBuilder<LangFactory> bindLangFactory = createMock(AnnotatedBindingBuilder.class);
    AnnotatedBindingBuilder<ILinkingDiagnosticMessageProvider.Extended> bindLinkingDMP = createMock(AnnotatedBindingBuilder.class);
    AnnotatedBindingBuilder<ILaunchManager> bindLaunchManager = createMock(AnnotatedBindingBuilder.class);
    final ILaunchManager launchManager = createMock(ILaunchManager.class);
    final AnnotatedBindingBuilder<Console> bindConsole = createMock(AnnotatedBindingBuilder.class);
    final Console console = createMock(Console.class);

    expect(binder.bind(LangFactory.class)).andReturn(bindLangFactory);
    expect(binder.bind(ILinkingDiagnosticMessageProvider.Extended.class)).andReturn(bindLinkingDMP);
    expect(binder.bind(ILaunchManager.class)).andReturn(bindLaunchManager);
    expect(binder.bind(Console.class)).andReturn(bindConsole);

    bindLangFactory.toInstance(LangFactory.eINSTANCE);

    expect(bindLinkingDMP.to(Antlr4MissingReferenceMessageProvider.class)).andReturn(null);

    bindLaunchManager.toInstance(launchManager);
    bindConsole.toInstance(console);

    Object[] mocks = {binder, bindLangFactory, bindLinkingDMP, launchManager, console };

    replay(mocks);

    new Antlr4RuntimeModule() {
      @Override
      protected ILaunchManager getLaunchManager() {
        return launchManager;
      }
      @Override
      protected Console getConsole() {
        return console;
      }
    }.configure(binder);

    verify(mocks);
  }

  @Test
  public void bindIQualifiedNameProvider() {
    assertEquals(Antlr4NameProvider.class, new Antlr4RuntimeModule().bindIQualifiedNameProvider());
  }

  @Test
  public void bindIOutputConfigurationProvider() {
    assertEquals(Antlr4OutputConfigurationProvider.class,
        new Antlr4RuntimeModule().bindIOutputConfigurationProvider());
  }
}
