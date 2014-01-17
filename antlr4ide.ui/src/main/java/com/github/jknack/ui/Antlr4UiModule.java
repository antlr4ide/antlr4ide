package com.github.jknack.ui;

import org.eclipse.ui.plugin.AbstractUIPlugin;
import org.eclipse.xtext.documentation.impl.AbstractMultiLineCommentProvider;
import org.eclipse.xtext.ui.editor.IXtextEditorCallback;
import org.eclipse.xtext.ui.editor.actions.IActionContributor;
import org.eclipse.xtext.ui.editor.folding.IFoldingRegionProvider;
import org.eclipse.xtext.ui.editor.folding.IFoldingStructureProvider;
import org.eclipse.xtext.ui.editor.hover.IEObjectHoverProvider;
import org.eclipse.xtext.ui.editor.preferences.IPreferenceStoreInitializer;
import org.eclipse.xtext.ui.editor.syntaxcoloring.AbstractAntlrTokenToAttributeIdMapper;
import org.eclipse.xtext.ui.editor.syntaxcoloring.IHighlightingConfiguration;
import org.eclipse.xtext.ui.editor.syntaxcoloring.ISemanticHighlightingCalculator;

import com.github.jknack.console.Console;
import com.github.jknack.generator.ToolOptionsProvider;
import com.github.jknack.ui.console.AntlrConsoleFactory;
import com.github.jknack.ui.console.DefaultConsole;
import com.github.jknack.ui.editor.Antlr4NatureCallback;
import com.github.jknack.ui.folding.Antlr4FoldingRegionProvider;
import com.github.jknack.ui.folding.Antlr4FoldingStructureProvider;
import com.github.jknack.ui.generator.DefaultToolOptionsProvider;
import com.github.jknack.ui.highlighting.AntlrHighlightingCalculator;
import com.github.jknack.ui.highlighting.AntlrHighlightingConfiguration;
import com.github.jknack.ui.highlighting.ShowWhitespaceCharactersActionContributor;
import com.github.jknack.ui.highlighting.TokenToAttributeIdMapper;
import com.github.jknack.ui.labeling.Antlr4HoverProvider;
import com.github.jknack.ui.preferences.BuildPreferenceStoreInitializer;
import com.google.inject.Binder;
import com.google.inject.name.Names;

/**
 * Use this class to register components to be used within the IDE.
 */
public class Antlr4UiModule extends com.github.jknack.ui.AbstractAntlr4UiModule {

  public Antlr4UiModule(final AbstractUIPlugin plugin) {
    super(plugin);
  }

  @Override
  public void configure(final Binder binder) {
    super.configure(binder);

    binder.requestStaticInjection(AntlrConsoleFactory.class);
    binder.requestStaticInjection(AntlrHighlightingConfiguration.class);
    binder.bind(Console.class).to(DefaultConsole.class);

    binder.bind(ToolOptionsProvider.class).to(DefaultToolOptionsProvider.class);

    binder.bind(IFoldingStructureProvider.class).to(Antlr4FoldingStructureProvider.class);
    binder.bind(IFoldingRegionProvider.class).to(Antlr4FoldingRegionProvider.class);

    binder.bind(String.class)
        .annotatedWith(Names.named(AbstractMultiLineCommentProvider.START_TAG))
        .toInstance("/\\*\\*");

    binder.bind(IActionContributor.class).annotatedWith(Names.named("Show Whitespace"))
        .to(ShowWhitespaceCharactersActionContributor.class);

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
}
