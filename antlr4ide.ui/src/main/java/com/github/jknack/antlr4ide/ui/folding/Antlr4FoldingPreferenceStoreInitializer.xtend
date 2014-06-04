package com.github.jknack.antlr4ide.ui.folding

import org.eclipse.xtext.ui.editor.preferences.IPreferenceStoreInitializer
import org.eclipse.xtext.ui.editor.preferences.IPreferenceStoreAccess

class Antlr4FoldingPreferenceStoreInitializer implements IPreferenceStoreInitializer {

  public static val ENABLED = "folding.enabled"

  public static val OPTIONS = "folding.options"

  public static val TOKENS = "folding.tokens"

  public static val COMMENTS = "folding.comments"

  public static val GRAMMAR_ACTION = "folding.grammarAction"

  public static val RULE_ACTION = "folding.ruleAction"

  public static val RULE = "folding.rule"

  public static val LEXER_RULE = "folding.lexerRule"

  override initialize(IPreferenceStoreAccess access) {
    val store = access.writablePreferenceStore
    store.setDefault(ENABLED, true)
    store.setDefault(OPTIONS, true)
    store.setDefault(TOKENS, false)
    store.setDefault(GRAMMAR_ACTION, true)
    store.setDefault(RULE_ACTION, true)
    store.setDefault(COMMENTS, true)
    store.setDefault(RULE, false)
    store.setDefault(LEXER_RULE, false)
  }

}
