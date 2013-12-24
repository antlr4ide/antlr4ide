package com.github.jknack.ui.syntaxcoloring

import org.eclipse.xtext.ui.editor.syntaxcoloring.DefaultHighlightingConfiguration
import org.eclipse.xtext.ui.editor.syntaxcoloring.IHighlightingConfigurationAcceptor
import org.eclipse.swt.SWT
import org.eclipse.swt.graphics.RGB

class AntlrHighlightingConfiguration extends DefaultHighlightingConfiguration {

  public static final String ACTION = "antlr4.action";

  public static final String RULE = "antlr4.rule";

  public static final String TOKEN = "antlr4.token";

  public static final String LABEL = "antlr4.label";

  public static final String LOCAL_VAR = "antlr4.localVar";

  override configure(IHighlightingConfigurationAcceptor acceptor) {
    super.configure(acceptor);

    acceptor.acceptDefaultHighlighting(ACTION, "Action", actionStyle)
    acceptor.acceptDefaultHighlighting(LABEL, "Label", labelStyle)
    acceptor.acceptDefaultHighlighting(RULE, "Rule", ruleStyle)
    acceptor.acceptDefaultHighlighting(TOKEN, "Token", tokenStyle)
    acceptor.acceptDefaultHighlighting(LOCAL_VAR, "Variable", localVarStyle)
  }

  def ruleStyle() {
    val style = defaultTextStyle.copy
    style.color = new RGB(0, 64, 128)
    return style;
  }

  def localVarStyle() {
    val style = numberTextStyle.copy
    return style;
  }

  def tokenStyle() {
    val style = defaultTextStyle.copy
    style.style = SWT.ITALIC
    return style;
  }

  def labelStyle() {
    val style = numberTextStyle.copy
    return style;
  }

  def actionStyle() {
    val style = keywordTextStyle.copy
    style.style = SWT.NORMAL;
    return style;
  }
}
