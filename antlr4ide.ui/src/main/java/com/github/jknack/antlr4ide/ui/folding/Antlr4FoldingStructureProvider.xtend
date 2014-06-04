package com.github.jknack.antlr4ide.ui.folding

import org.eclipse.xtext.ui.editor.folding.DefaultFoldingStructureProvider
import org.eclipse.jface.text.Position
import org.eclipse.jface.text.source.projection.ProjectionAnnotation
import com.google.inject.Inject
import org.eclipse.xtext.ui.editor.preferences.IPreferenceStoreAccess
import static com.github.jknack.antlr4ide.ui.folding.Antlr4FoldingPreferenceStoreInitializer.*

/**
 * Customize collapse by default.
 */
class Antlr4FoldingStructureProvider extends DefaultFoldingStructureProvider {

  IPreferenceStoreAccess storeAccess

  boolean init

  @Inject
  new(IPreferenceStoreAccess storeAccess) {
    this.storeAccess = storeAccess
  }

  override initialize() {
    try {
      init = true
      super.initialize()
    } finally {
      init = false
    }
  }

  override protected createProjectionAnnotation(boolean isCollapsed, Position foldedRegion) {
    this.createProjectionAnnotation(isCollapsed, foldedRegion as Antlr4FoldedPosition)
  }

  /**
   * Collapse comment, actions and options by default.
   */
  def private createProjectionAnnotation(boolean isCollapsed, Antlr4FoldedPosition foldedRegion) {
    val preferenceStore = storeAccess.preferenceStore
    val folding = preferenceStore.getBoolean(ENABLED)
    val collapsed = if (folding) {
        if (init) {
          switch (foldedRegion.regionType) {
            case "options": preferenceStore.getBoolean(OPTIONS)
            case "v4Tokens": preferenceStore.getBoolean(TOKENS)
            case "v3Tokens": preferenceStore.getBoolean(TOKENS)
            case "comment": preferenceStore.getBoolean(COMMENTS)
            case "grammarAction": preferenceStore.getBoolean(GRAMMAR_ACTION)
            case "ruleAction": preferenceStore.getBoolean(RULE_ACTION)
            case "parserRule": preferenceStore.getBoolean(RULE)
            case "lexerRule": preferenceStore.getBoolean(LEXER_RULE)
            default: isCollapsed
          }
        } else {
          false
        }
      } else {
        false
      }
    new ProjectionAnnotation(collapsed)
  }

}
