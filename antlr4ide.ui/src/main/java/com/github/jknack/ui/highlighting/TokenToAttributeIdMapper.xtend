package com.github.jknack.ui.highlighting

import org.eclipse.xtext.ui.editor.syntaxcoloring.DefaultAntlrTokenToAttributeIdMapper
import org.eclipse.xtext.ui.editor.syntaxcoloring.DefaultHighlightingConfiguration

class TokenToAttributeIdMapper extends DefaultAntlrTokenToAttributeIdMapper {
  override calculateId(String tokenName, int tokenType) {
    if (tokenName.endsWith("RULE_TOKEN_VOCAB") || tokenName.endsWith("RULE_OPTIONS_SPEC") ||
      tokenName.endsWith("RULE_TOKENS_SPEC")) {
      return DefaultHighlightingConfiguration.DEFAULT_ID;
    }
    if (tokenName.endsWith("_SPEC")) {
      return DefaultHighlightingConfiguration.KEYWORD_ID
    }
    return super.calculateId(tokenName, tokenType)
  }
}
