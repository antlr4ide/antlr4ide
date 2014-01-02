package com.github.jknack;

import org.eclipse.xtext.Constants;
import org.eclipse.xtext.generator.IOutputConfigurationProvider;
import org.eclipse.xtext.linking.ILinkingDiagnosticMessageProvider;
import org.eclipse.xtext.naming.IQualifiedNameProvider;
import org.osgi.framework.Bundle;

import com.github.jknack.antlr4.Antlr4Factory;
import com.github.jknack.generator.BuildConfigurationProvider;
import com.github.jknack.launch.AntlrToolLaunchConfigurationDelegate;
import com.github.jknack.scoping.Antlr4NameProvider;
import com.github.jknack.validation.Antlr4MissingReferenceMessageProvider;
import com.google.inject.Binder;
import com.google.inject.name.Names;

/**
 * Use this class to register components to be used at runtime / without the Equinox extension
 * registry.
 */
public class Antlr4RuntimeModule extends com.github.jknack.AbstractAntlr4RuntimeModule {

  public static final String LANG_NAME = "com.github.jknack.Antlr4";

  @Override
  public void configure(final Binder binder) {
    super.configure(binder);
    configureLocal(binder);
  }

  void configureLocal(final Binder binder) {
    binder.bind(Bundle.class).toInstance(Activator.bundle);

    binder.bind(Antlr4Factory.class).toInstance(Antlr4Factory.eINSTANCE);

    binder.bind(ILinkingDiagnosticMessageProvider.Extended.class)
        .to(Antlr4MissingReferenceMessageProvider.class);

    binder.requestStaticInjection(AntlrToolLaunchConfigurationDelegate.class);
  }

  @Override
  public Class<? extends IQualifiedNameProvider> bindIQualifiedNameProvider() {
    return Antlr4NameProvider.class;
  }

  public Class<? extends IOutputConfigurationProvider> bindIOutputConfigurationProvider() {
    return BuildConfigurationProvider.class;
  }

  @Override
  public void configureLanguageName(final Binder binder) {
    binder.bind(String.class).annotatedWith(Names.named(Constants.LANGUAGE_NAME)).toInstance(LANG_NAME);
  }
}
