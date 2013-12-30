package com.github.jknack.ui.highlighting

import org.eclipse.xtext.ui.editor.syntaxcoloring.DefaultHighlightingConfiguration
import org.eclipse.xtext.ui.editor.syntaxcoloring.IHighlightingConfigurationAcceptor
import org.eclipse.swt.SWT
import org.eclipse.swt.graphics.RGB

class AntlrHighlightingConfiguration extends DefaultHighlightingConfiguration {

  public static final String ACTION = "antlr4.action"

  public static final String RULE = "antlr4.rule"

  public static final String TOKEN = "antlr4.token"

  public static final String LABEL = "antlr4.label"

  public static final String LOCAL_VAR = "antlr4.localVar"

  public static final String LEXER_COMMAND = "antlr4.lexerCommand"

  public static final String MODE_OPERATOR = "antlr4.modeOperator"

  public static final String MODE = "antlr4.mode"

  public static final String CHARSET = "antlr4.charSet"

  public static final String RULE_REF = "antlr4.ruleRef"

  public static final String TOKEN_REF = "antlr4.tokenRef"

  public static final String EBNF = "antlr4.ebnf"

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
}
