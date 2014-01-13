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

  public static val ELEMENT_OPTION_DELIMITER = "antlr4.elementOptionDelimiter"

  public static val ELEMENT_OPTION_ASSIGN_OP = "antlr4.elementOptionAssignOp"

  public static val WILDCARD = "antlr4.wildcard"

  public static val LANG_STRING_LITERAL = "antlr4.langStringLiteral"

  public static val LANG_KEYWORD = "antlr4.langKeyword"

  public static val LANG_COMMENT = "antlr4.langComment"

  public static val LANG_REF = "antlr4.langRef"

  public static val SEM_PRED = "antlr4.semanticPredicate"

  public static val DOC_COMMENT = "antlr4.docComment"

  @Inject
  @Named(Constants.LANGUAGE_NAME)
  static String language

  override configure(IHighlightingConfigurationAcceptor acceptor) {
    super.configure(acceptor);

    acceptor.acceptDefaultHighlighting(ACTION, "Action Name", actionStyle)
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
    acceptor.acceptDefaultHighlighting(WILDCARD, "Wildcard", wildcardStyle)
    acceptor.acceptDefaultHighlighting(SEM_PRED, "Semantic Predicate", semanticPredicateStyle)
    acceptor.acceptDefaultHighlighting(DOC_COMMENT, "Doc Comment", docCommentSyle)
    acceptor.acceptDefaultHighlighting(LANG_STRING_LITERAL, "Language String Literal",
      langStringLiteralStyle
    )
    acceptor.acceptDefaultHighlighting(LANG_KEYWORD, "Language Keyword", langKeywordStyle)
    acceptor.acceptDefaultHighlighting(LANG_COMMENT, "Language Comment", langCommentStyle)
    acceptor.acceptDefaultHighlighting(LANG_REF, "Language Reference", langRefStyle)

    acceptor.acceptDefaultHighlighting(
      ELEMENT_OPTION_DELIMITER,
      "Element option delimiter",
      elementOptionDelimiterStyle
    )
    acceptor.acceptDefaultHighlighting(
      ELEMENT_OPTION_ASSIGN_OP,
      "Element option assign operator",
      elementOptionAssignOpStyle
    )
  }

  def ruleStyle() {
    val style = defaultTextStyle.copy
    style.color = new RGB(0, 64, 128)
    style
  }

  def docCommentSyle() {
    val style = defaultTextStyle.copy
    style.color = new RGB(63, 95, 191)
    style
  }

  def langStringLiteralStyle() {
    val style = stringTextStyle.copy
    style.color = new RGB(0, 128, 0)
    style.style = SWT.BOLD
    style
  }

  def langCommentStyle() {
    val style = defaultTextStyle.copy
    style.color = new RGB(128, 128, 128)
    style
  }

  def langRefStyle() {
    localVarStyle.copy
  }

  def langKeywordStyle() {
    val style = keywordTextStyle.copy
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

  def wildcardStyle() {
    val style = stringTextStyle.copy
    style.style = SWT.BOLD
    style
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

  def elementOptionDelimiterStyle() {
    numberTextStyle.copy
  }

  def semanticPredicateStyle() {
    numberTextStyle.copy
  }

  def elementOptionAssignOpStyle() {
    elementOptionDelimiterStyle.copy
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
