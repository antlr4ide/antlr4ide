package com.github.jknack.ui.syntaxcoloring

import org.eclipse.xtext.ui.editor.syntaxcoloring.DefaultAntlrTokenToAttributeIdMapper
import org.eclipse.xtext.ui.editor.syntaxcoloring.DefaultHighlightingConfiguration

class TokenToAttributeIdMapper extends DefaultAntlrTokenToAttributeIdMapper {
  override calculateId(String tokenName, int tokenType) {
    if (tokenName.endsWith("_SPEC")) {
      return DefaultHighlightingConfiguration.KEYWORD_ID
    }
    if (tokenName.endsWith("RULE_TOKEN_VOCAB")) {
      return DefaultHighlightingConfiguration.DEFAULT_ID;
    }
    return super.calculateId(tokenName, tokenType)
  }
}