package com.github.jknack.antlr4ide.fragment;

import java.util.Set;

import org.eclipse.emf.mwe.utils.StandaloneSetup;
import org.eclipse.xtext.Grammar;
import org.eclipse.xtext.generator.BindFactory;
import org.eclipse.xtext.generator.Binding;
import org.eclipse.xtext.generator.DefaultGeneratorFragment;
import org.eclipse.xtext.scoping.IGlobalScopeProvider;

public class JdtFreeTypesGeneratorFragment extends DefaultGeneratorFragment {
  static {
    new StandaloneSetup()
        .addRegisterGeneratedEPackage("org.eclipse.xtext.common.types.TypesPackage");
  }

  @Override
  public Set<Binding> getGuiceBindingsRt(final Grammar grammar) {
    return new BindFactory()
        .addTypeToInstance(ClassLoader.class.getName(), "getClass().getClassLoader()")
        .addTypeToInstance("org.eclipse.xtext.common.types.TypesFactory",
            "org.eclipse.xtext.common.types.TypesFactory.eINSTANCE")
        .addTypeToType("org.eclipse.xtext.common.types.access.IJvmTypeProvider.Factory",
            "org.eclipse.xtext.common.types.access.ClasspathTypeProviderFactory")
        .addTypeToType("org.eclipse.xtext.common.types.xtext.AbstractTypeScopeProvider",
            "org.eclipse.xtext.common.types.xtext.ClasspathBasedTypeScopeProvider")
        .addTypeToType(IGlobalScopeProvider.class.getName(),
            "org.eclipse.xtext.common.types.xtext.TypesAwareDefaultGlobalScopeProvider")
        .getBindings();
  }

  @Override
  public String[] getRequiredBundlesRt(final Grammar grammar) {
    return new String[]{"org.eclipse.xtext.common.types" };
  }

}
