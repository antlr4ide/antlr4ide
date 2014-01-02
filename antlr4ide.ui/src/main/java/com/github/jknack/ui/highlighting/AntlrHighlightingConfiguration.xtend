package com.github.jknack.ui.highlighting

import org.eclipse.xtext.ui.editor.syntaxcoloring.DefaultHighlightingConfiguration
import org.eclipse.xtext.ui.editor.syntaxcoloring.IHighlightingConfigurationAcceptor
import org.eclipse.swt.SWT
import org.eclipse.swt.graphics.RGB
import org.eclipse.xtext.ui.editor.syntaxcoloring.PreferenceStoreAccessor
import com.google.inject.Inject
import com.google.inject.name.Named
import org.eclipse.xtext.Constants

class AntlrHighlightingConfiguration extends DefaultHighlightingConfiguration {

  public static val ACTION = "antlr4.action"

  public static val RULE = "antlr4.rule"

  public static val TOKEN = "antlr4.token"

  public static val LABEL = "antlr4.label"

  public static val LOCAL_VAR = "antlr4.localVar"

  public static val LEXER_COMMAND = "antlr4.lexerCommand"

  public static val MODE_OPERATOR = "antlr4.modeOperator"

  public static val MODE = "antlr4.mode"

  public static val CHARSET = "antlr4.charSet"

  public static val RULE_REF = "antlr4.ruleRef"

  public static val TOKEN_REF = "antlr4.tokenRef"

  public static val EBNF = "antlr4.ebnf"

  @Inject
  @Named(Constants.LANGUAGE_NAME)
  static String language

  override configure(IHighlightingConfigurationAcceptor acceptor) {
    super.configure(acceptor);

    acceptor.acceptDefaultHighlighting(ACTION, "Action", actionStyle)
    acceptor.acceptDefaultHighlighting(LABEL, "Label", labelStyle)
    acceptor.acceptDefaultHighlighting(RULE, "Rule", ruleStyle)
    acceptor.acceptDefaultHighlighting(RULE_REF, "Rule Reference", ruleRefStyle)
    acceptor.acceptDefaultHighlighting(TOKEN_REF, "Token Reference", tokenRefStyle)
    acceptor.acceptDefaultHighlighting(TOKEN, "Token", tokenStyle)
    acceptor.acceptDefaultHighlighting(LOCAL_VAR, "Variable", localVarStyle)
    acceptor.acceptDefaultHighlighting(LEXER_COMMAND, "Lexer Command", lexerCommandStyle)
    acceptor.acceptDefaultHighlighting(MODE_OPERATOR, "Mode Operator", modeOperatorStyle)
    acceptor.acceptDefaultHighlighting(MODE, "Mode", modeStyle)
    acceptor.acceptDefaultHighlighting(CHARSET, "Char set", charSetStyle)
    acceptor.acceptDefaultHighlighting(EBNF, "Ebnf Opertator", ebnfStyle)
  }

  def ruleStyle() {
    val style = defaultTextStyle.copy
    style.color = new RGB(0, 64, 128)
    style
  }

  def ebnfStyle() {
    defaultTextStyle.copy
  }

  def ruleRefStyle() {
    ruleStyle.copy
  }

  def charSetStyle() {
    stringTextStyle.copy
  }

  def localVarStyle() {
    val style = numberTextStyle.copy
    return style;
  }

  def tokenStyle() {
    val style = defaultTextStyle.copy
    style.style = SWT.ITALIC
    style
  }

  def tokenRefStyle() {
    tokenStyle.copy
  }

  def modeStyle() {
    tokenStyle.copy
  }

  def labelStyle() {
    numberTextStyle.copy
  }

  def lexerCommandStyle() {
    val style = numberTextStyle.copy
    style.color = new RGB(100, 70, 50)
    style
  }

  def modeOperatorStyle() {
    val style = defaultTextStyle.copy
    style.style = SWT.BOLD
    style
  }

  def actionStyle() {
    val style = keywordTextStyle.copy
    style.style = SWT.NORMAL;
    style
  }

  def static qualifiedId(String tokenType) {
    val lang = PreferenceStoreAccessor::tokenTypeTag(language)
    return lang + "." + PreferenceStoreAccessor::getTokenColorPreferenceKey(tokenType)
  }
}
