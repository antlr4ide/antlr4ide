package com.github.jknack.antlr4ide.ui;

import java.util.Set;

import org.eclipse.core.runtime.IPath;
import org.eclipse.ui.plugin.AbstractUIPlugin;
import org.eclipse.xtext.documentation.impl.AbstractMultiLineCommentProvider;
import org.eclipse.xtext.resource.containers.IAllContainersState;
import org.eclipse.xtext.ui.editor.IXtextEditorCallback;
import org.eclipse.xtext.ui.editor.actions.IActionContributor;
import org.eclipse.xtext.ui.editor.folding.IFoldingRegionProvider;
import org.eclipse.xtext.ui.editor.folding.IFoldingStructureProvider;
import org.eclipse.xtext.ui.editor.hover.IEObjectHoverProvider;
import org.eclipse.xtext.ui.editor.model.IResourceForEditorInputFactory;
import org.eclipse.xtext.ui.editor.model.ResourceForIEditorInputFactory;
import org.eclipse.xtext.ui.editor.preferences.IPreferenceStoreInitializer;
import org.eclipse.xtext.ui.editor.syntaxcoloring.AbstractAntlrTokenToAttributeIdMapper;
import org.eclipse.xtext.ui.editor.syntaxcoloring.IHighlightingConfiguration;
import org.eclipse.xtext.ui.editor.syntaxcoloring.ISemanticHighlightingCalculator;
import org.eclipse.xtext.ui.resource.IResourceSetProvider;
import org.eclipse.xtext.ui.resource.IStorage2UriMapperJdtExtensions;
import org.eclipse.xtext.ui.resource.SimpleResourceSetProvider;
import org.eclipse.xtext.ui.wizard.IProjectCreator;

import com.github.jknack.antlr4ide.console.Console;
import com.github.jknack.antlr4ide.generator.CodeGeneratorListener;
import com.github.jknack.antlr4ide.generator.ToolOptionsProvider;
import com.github.jknack.antlr4ide.services.GrammarResource;
import com.github.jknack.antlr4ide.ui.console.AntlrConsoleFactory;
import com.github.jknack.antlr4ide.ui.console.DefaultConsole;
import com.github.jknack.antlr4ide.ui.editor.Antlr4NatureCallback;
import com.github.jknack.antlr4ide.ui.folding.Antlr4FoldingRegionProvider;
import com.github.jknack.antlr4ide.ui.folding.Antlr4FoldingStructureProvider;
import com.github.jknack.antlr4ide.ui.generator.DefaultToolOptionsProvider;
import com.github.jknack.antlr4ide.ui.generator.RefreshProjectProcessor;
import com.github.jknack.antlr4ide.ui.generator.TodoListProcessor;
import com.github.jknack.antlr4ide.ui.highlighting.AntlrHighlightingCalculator;
import com.github.jknack.antlr4ide.ui.highlighting.AntlrHighlightingConfiguration;
import com.github.jknack.antlr4ide.ui.highlighting.ShowWhitespaceCharactersActionContributor;
import com.github.jknack.antlr4ide.ui.highlighting.TokenToAttributeIdMapper;
import com.github.jknack.antlr4ide.ui.labeling.Antlr4HoverProvider;
import com.github.jknack.antlr4ide.ui.preferences.BuildPreferenceStoreInitializer;
import com.github.jknack.antlr4ide.ui.services.DefaultGrammarResource;
import com.github.jknack.antlr4ide.ui.wizard.JdtFreeProjectCreator;
import com.google.common.collect.Sets;
import com.google.inject.Binder;
import com.google.inject.Inject;
import com.google.inject.Provider;
import com.google.inject.Provides;
import com.google.inject.name.Names;
import com.google.inject.util.Providers;

/**
 * Use this class to register components to be used within the IDE.
 */
public class Antlr4UiModule extends com.github.jknack.antlr4ide.ui.AbstractAntlr4UiModule {

  private IPath stateLocation;

  public Antlr4UiModule(final AbstractUIPlugin plugin) {
    super(plugin);
    this.stateLocation = plugin.getStateLocation();
  }

  @Override
  public void configure(final Binder binder) {
    super.configure(binder);

    binder.requestStaticInjection(AntlrConsoleFactory.class);
    binder.requestStaticInjection(AntlrHighlightingConfiguration.class);
    binder.bind(Console.class).to(DefaultConsole.class);
    binder.bind(GrammarResource.class).to(DefaultGrammarResource.class);

    binder.bind(ToolOptionsProvider.class).to(DefaultToolOptionsProvider.class);

    binder.bind(IFoldingStructureProvider.class).to(Antlr4FoldingStructureProvider.class);
    binder.bind(IFoldingRegionProvider.class).to(Antlr4FoldingRegionProvider.class);

    binder.bind(String.class)
        .annotatedWith(Names.named(AbstractMultiLineCommentProvider.START_TAG))
        .toInstance("/\\*\\*");

    binder.bind(IActionContributor.class).annotatedWith(Names.named("Show Whitespace"))
        .to(ShowWhitespaceCharactersActionContributor.class);

    binder.bind(TodoListProcessor.class);
    binder.bind(RefreshProjectProcessor.class);

    binder.bind(IPath.class).annotatedWith(Names.named("stateLocation")).toInstance(stateLocation);
  }

  @Provides
  @Inject
  public Set<CodeGeneratorListener> codeGeneratorListeners(final TodoListProcessor todoProcessor,
      final RefreshProjectProcessor refreshProjectProcessor) {
    return Sets.<CodeGeneratorListener> newHashSet(todoProcessor, refreshProjectProcessor);
  }

  public Class<? extends AbstractAntlrTokenToAttributeIdMapper> bindAntlrTokenToAttributeIdMapper() {
    return TokenToAttributeIdMapper.class;
  }

  public Class<? extends IHighlightingConfiguration> bindIHighlightingConfiguration() {
    return AntlrHighlightingConfiguration.class;
  }

  public Class<? extends ISemanticHighlightingCalculator> bindISemanticHighlightingCalculator() {
    return AntlrHighlightingCalculator.class;
  }

  public Class<? extends IPreferenceStoreInitializer> bindIPreferenceStoreInitializer() {
    return BuildPreferenceStoreInitializer.class;
  }

  public Class<? extends IEObjectHoverProvider> bindIEObjectHoverProvider() {
    return Antlr4HoverProvider.class;
  }

  @Override
  public Class<? extends IXtextEditorCallback> bindIXtextEditorCallback() {
    return Antlr4NatureCallback.class;
  }

  // prevent JDT dependencies, see https://bugs.eclipse.org/bugs/show_bug.cgi?id=404322
  @Override
  public Class<? extends IResourceForEditorInputFactory> bindIResourceForEditorInputFactory() {
    return ResourceForIEditorInputFactory.class;
  }

  @Override
  public Class<? extends IResourceSetProvider> bindIResourceSetProvider() {
    return SimpleResourceSetProvider.class;
  }

  @Override
  public Provider<IAllContainersState> provideIAllContainersState() {
    return org.eclipse.xtext.ui.shared.Access.getWorkspaceProjectsState();
  }

  // FIXME: due to "Xtext based editor does not start since 2.5 without JDT installed",
  // https://bugs.eclipse.org/bugs/show_bug.cgi?id=424455
  public void configureIStorage2UriMapperJdtExtensions(final Binder binder) {
    binder.bind(IStorage2UriMapperJdtExtensions.class).toProvider(
        Providers.of((IStorage2UriMapperJdtExtensions) null));
  }

  @Override
  public Class<? extends IProjectCreator> bindIProjectCreator() {
    return JdtFreeProjectCreator.class;
  }
}
