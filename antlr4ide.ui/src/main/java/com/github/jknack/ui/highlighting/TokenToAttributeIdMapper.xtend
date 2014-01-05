package com.github.jknack.ui.highlighting

import org.eclipse.xtext.ui.editor.syntaxcoloring.DefaultAntlrTokenToAttributeIdMapper

class TokenToAttributeIdMapper extends DefaultAntlrTokenToAttributeIdMapper {

  override calculateId(String tokenName, int tokenType) {
    switch (tokenName) {
      case "RULE_TOKEN_VOCAB": AntlrHighlightingConfiguration.DEFAULT_ID
      case "RULE_OPTIONS_SPEC": AntlrHighlightingConfiguration.DEFAULT_ID
      case "RULE_TOKENS_SPEC": AntlrHighlightingConfiguration.DEFAULT_ID
      case tokenName.endsWith("_SPEC"): AntlrHighlightingConfiguration.KEYWORD_ID
      default: super.calculateId(tokenName, tokenType)
    }
  }

}
