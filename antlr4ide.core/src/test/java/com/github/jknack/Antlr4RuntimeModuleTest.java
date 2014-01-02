package com.github.jknack;

import static org.easymock.EasyMock.createMock;
import static org.easymock.EasyMock.expect;
import static org.easymock.EasyMock.replay;
import static org.easymock.EasyMock.verify;
import static org.junit.Assert.assertEquals;

import org.eclipse.xtext.linking.ILinkingDiagnosticMessageProvider;
import org.junit.Test;
import org.osgi.framework.Bundle;

import com.github.jknack.antlr4.Antlr4Factory;
import com.github.jknack.launch.AntlrToolLaunchConfigurationDelegate;
import com.github.jknack.scoping.Antlr4NameProvider;
import com.github.jknack.validation.Antlr4MissingReferenceMessageProvider;
import com.google.inject.Binder;
import com.google.inject.binder.AnnotatedBindingBuilder;

public class Antlr4RuntimeModuleTest {

  @SuppressWarnings("unchecked")
  @Test
  public void configureLocal() throws Exception {
    Activator.bundle = createMock(Bundle.class);

    AnnotatedBindingBuilder<Bundle> bundleBind = createMock(AnnotatedBindingBuilder.class);
    bundleBind.toInstance(Activator.bundle);

    AnnotatedBindingBuilder<Antlr4Factory> factoryBind = createMock(AnnotatedBindingBuilder.class);
    factoryBind.toInstance(Antlr4Factory.eINSTANCE);

    AnnotatedBindingBuilder<ILinkingDiagnosticMessageProvider.Extended> diagnosticMessageProvider = createMock(AnnotatedBindingBuilder.class);
    expect(diagnosticMessageProvider.to(Antlr4MissingReferenceMessageProvider.class)).andReturn(
        null);

    Binder binder = createMock(Binder.class);
    expect(binder.bind(Bundle.class)).andReturn(bundleBind);

    expect(binder.bind(Antlr4Factory.class)).andReturn(factoryBind);

    expect(binder.bind(ILinkingDiagnosticMessageProvider.Extended.class)).andReturn(
        diagnosticMessageProvider);

    binder.requestStaticInjection(AntlrToolLaunchConfigurationDelegate.class);

    Object[] mocks = {Activator.bundle, bundleBind, factoryBind, diagnosticMessageProvider, binder };

    replay(mocks);

    Antlr4RuntimeModule module = new Antlr4RuntimeModule();

    module.configureLocal(binder);

    verify(mocks);
  }

  @Test
  public void bindIQualifiedNameProvider() throws Exception {
    assertEquals(Antlr4NameProvider.class, new Antlr4RuntimeModule().bindIQualifiedNameProvider());
  }

}
