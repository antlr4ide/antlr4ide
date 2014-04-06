package com.github.jknack.antlr4ide.formatting

import com.github.jknack.antlr4ide.services.Antlr4GrammarAccess
import com.google.inject.Inject
import org.eclipse.xtext.formatting.impl.AbstractDeclarativeFormatter
import org.eclipse.xtext.formatting.impl.FormattingConfig

/**
 * This class contains custom formatting description.
 * 
 * see : http://www.eclipse.org/Xtext/documentation.html#formatting
 * on how and when to use it 
 * 
 * Also see {@link org.eclipse.xtext.xtext.XtextFormattingTokenSerializer} as an example
 */
class Antlr4Formatter extends AbstractDeclarativeFormatter {

  /**
   * Access to grammar components.
   */
  @Inject extension Antlr4GrammarAccess g

  /**
   * Configure a formatter.
   *
   *  @param c The formatting configuration.
   */
  override protected configureFormatting(FormattingConfig c) {

    grammar(c)

    options(c)

    tokens(c)

    actions(c)

    imports(c)

    parseRule(c)

    lexerRule(c)

    ruleAction(c)

    mode(c)

    comments(c)
  }

  /**
   * Configure comment formatting.
   *
   * @param c formatter configuration
   */
  protected def comments(FormattingConfig c) {
    c.setLinewrap(0, 1, 2).before(SL_COMMENTRule)
    c.setLinewrap(0, 1, 2).before(ML_COMMENTRule)
    c.setLinewrap(0, 1, 1).after(ML_COMMENTRule)
  }

  /**
   * Configure lexical mode formatting.
   *
   * @param c formatter configuration
   */
  protected def mode(FormattingConfig c) {
    c.setNoSpace.before(g.modeAccess.semicolonKeyword_2)
    c.setLinewrap(2).after(g.modeAccess.semicolonKeyword_2)
  }

  /**
   * Configure rule actions formatting.
   *
   * @param c formatter configuration
   */
  protected def ruleAction(FormattingConfig c) {
    c.setLinewrap.before(g.actionElementAccess.rule)
    c.setLinewrap(2).after(g.actionElementAccess.rule)
  }

  /**
   * Configure lexer rules formatting.
   *
   * @param c formatter configuration
   */
  protected def lexerRule(FormattingConfig c) {
    c.setLinewrap.before(g.lexerRuleAccess.fragmentFragmentKeyword_0_0)
    c.setLinewrap.before(g.lexerRuleAccess.nameTOKEN_REFTerminalRuleCall_1_0)
    c.setLinewrap.before(g.lexerRuleAccess.COLONTerminalRuleCall_2)
    c.setLinewrap.after(g.lexerRuleAccess.COLONTerminalRuleCall_2)

    // Indent rule body -> ':' body ';'
    c.setIndentation(g.lexerRuleAccess.COLONTerminalRuleCall_2,
      g.lexerRuleAccess.semicolonSymbolSemicolonKeyword_4_0)

    // alternatives
    c.setLinewrap.before(g.lexerAltListAccess.verticalLineKeyword_1_0_0)

    // '(' block ')'
    c.setLinewrap.before(g.lexerBlockAccess.leftParenthesisKeyword_0)
    c.setLinewrap.after(g.lexerBlockAccess.leftParenthesisKeyword_0)
    c.setIndentation(g.lexerBlockAccess.leftParenthesisKeyword_0, g.lexerBlockAccess.rightParenthesisKeyword_3)
    c.setLinewrap.before(g.lexerBlockAccess.rightParenthesisKeyword_3)

    // ';'
    c.setLinewrap.before(g.lexerRuleAccess.semicolonSymbolSemicolonKeyword_4_0)
    c.setLinewrap(2).after(g.lexerRuleAccess.semicolonSymbolSemicolonKeyword_4_0)

    // '~'
    c.setNoSpace.after(g.notSetAccess.tildeKeyword_0_0)
    c.setNoSpace.after(g.notSetAccess.tildeKeyword_1_0)
  }

  /**
   * Configure a parser rule formatting.
   *
   * @param c formatter configuration
   */
  protected def parseRule(FormattingConfig c) {
    c.setLinewrap.before(g.parserRuleAccess.nameRULE_REFTerminalRuleCall_0_0)
    c.setLinewrap.before(g.parserRuleAccess.COLONTerminalRuleCall_6)
    c.setLinewrap.after(g.parserRuleAccess.COLONTerminalRuleCall_6)

    // Indent rule body -> ':' body ';'
    c.setIndentation(g.parserRuleAccess.COLONTerminalRuleCall_6,
      g.parserRuleAccess.semicolonSymbolSemicolonKeyword_9_0)

    // locals
    c.setLinewrap.before(g.localVarsAccess.localsKeyword_0)

    // actions
    c.setLinewrap(0, 1, 1).after(g.ruleActionAccess.atSymbolCommercialAtKeyword_0_0)
    c.setNoSpace.after(g.ruleActionAccess.atSymbolCommercialAtKeyword_0_0)
    c.setSpace(" ").after(g.ruleActionAccess.nameIdParserRuleCall_1_0)
    c.setLinewrap.after(g.ruleActionAccess.bodyACTIONTerminalRuleCall_2_0)

    // ebnf
    c.setNoSpace.before(g.ebnfSuffixAccess.operatorQuestionMarkKeyword_0_0_0)
    c.setNoSpace.before(g.ebnfSuffixAccess.operatorAsteriskKeyword_1_0_0)
    c.setNoSpace.before(g.ebnfSuffixAccess.operatorPlusSignKeyword_2_0_0)
    c.setNoSpace.before(g.ebnfSuffixAccess.nongreedyQuestionMarkKeyword_0_1_0)
    c.setNoSpace.before(g.ebnfSuffixAccess.nongreedyQuestionMarkKeyword_1_1_0)
    c.setNoSpace.before(g.ebnfSuffixAccess.nongreedyQuestionMarkKeyword_2_1_0)

    // alternatives
    c.setSpace(" ").before(g.labeledAltAccess.poundSymbolNumberSignKeyword_1_0_0)
    c.setLinewrap.before(g.ruleAltListAccess.verticalLineKeyword_1_0)
    c.setLinewrap.before(g.altListAccess.verticalLineKeyword_1_0)

    // '(' block ')'
    c.setLinewrap.before(g.blockAccess.leftParenthesisKeyword_0)
    c.setLinewrap.after(g.blockAccess.leftParenthesisKeyword_0)
    c.setIndentation(g.blockAccess.leftParenthesisKeyword_0, g.blockAccess.rightParenthesisKeyword_3)
    c.setLinewrap.before(g.blockAccess.rightParenthesisKeyword_3)

    // ';'
    c.setLinewrap.before(g.parserRuleAccess.semicolonSymbolSemicolonKeyword_9_0)
    c.setLinewrap(2).after(g.parserRuleAccess.semicolonSymbolSemicolonKeyword_9_0)
  }

  /**
   * Configure import formatting.
   *
   * @param c formatter configuration
   */
  protected def imports(FormattingConfig c) {
    c.setLinewrap.before(g.importsAccess.keywordImportKeyword_0_0)

    // ','
    c.setNoSpace.before(g.importsAccess.commaKeyword_2_0)
    c.setSpace(" ").after(g.importsAccess.commaKeyword_2_0)

    // ';'
    c.setNoSpace.before(g.importsAccess.semicolonKeyword_3)
    c.setLinewrap(2).after(g.importsAccess.semicolonKeyword_3)
  }

  /**
   * Configure grammar action formatting.
   *
   * @param c formatter configuration
   */
  protected def actions(FormattingConfig c) {
    c.setLinewrap.before(g.grammarActionAccess.atSymbolCommercialAtKeyword_0_0)
    c.setNoSpace.after(g.grammarActionAccess.atSymbolCommercialAtKeyword_0_0)

    // [@]scope
    c.setNoSpace.after(g.grammarActionAccess.scopeActionScopeParserRuleCall_1_0_0)

    // [@scope]::
    c.setNoSpace.after(g.grammarActionAccess.colonSymbolColonColonKeyword_1_1_0)

    // [@scope::]name
    c.setSpace(" ").after(g.grammarActionAccess.nameIdParserRuleCall_2_0)

    // {}
    c.setLinewrap(2).after(g.grammarActionAccess.actionACTIONTerminalRuleCall_3_0)
  }

  /**
   * Configure tokens formatting.
   *
   * @param c formatter configuration
   */
  protected def tokens(FormattingConfig c) {
    // tokens {
    c.setLinewrap.before(g.v3TokensAccess.keywordTOKENS_SPECTerminalRuleCall_0_0)
    c.setLinewrap.after(g.v3TokensAccess.keywordTOKENS_SPECTerminalRuleCall_0_0)

    // tokens {}
    c.setIndentation(g.v3TokensAccess.keywordTOKENS_SPECTerminalRuleCall_0_0,
      g.v3TokensAccess.rightCurlyBracketKeyword_2)

    // ';'
    c.setLinewrap.after(g.v3TokenAccess.semicolonKeyword_2)

    // tokens {
    c.setLinewrap.before(g.v4TokensAccess.keywordTOKENS_SPECTerminalRuleCall_0_0)
    c.setLinewrap.after(g.v4TokensAccess.keywordTOKENS_SPECTerminalRuleCall_0_0)

    // tokens {}
    c.setIndentation(g.v4TokensAccess.keywordTOKENS_SPECTerminalRuleCall_0_0,
      g.v4TokensAccess.rightCurlyBracketKeyword_3)

    // ','
    c.setLinewrap.after(g.v4TokensAccess.commaKeyword_2_0)
    c.setNoSpace.before(g.v4TokensAccess.commaKeyword_2_0)

    // }
    c.setLinewrap.before(g.v4TokensAccess.rightCurlyBracketKeyword_3)
    c.setLinewrap(2).after(g.v4TokensAccess.rightCurlyBracketKeyword_3)
  }

  /**
   * Configure options formatting.
   *
   * @param c formatter configuration
   */
  protected def options(FormattingConfig c) {
    c.setLinewrap.before(g.optionsAccess.keywordOPTIONS_SPECTerminalRuleCall_1_0)
    c.setLinewrap.after(g.optionsAccess.keywordOPTIONS_SPECTerminalRuleCall_1_0)

    // name = value ';'
    c.setLinewrap.after(g.optionsAccess.semicolonKeyword_2_1)
    c.setNoSpace.before(g.optionsAccess.semicolonKeyword_2_1)
    c.setIndentation(g.optionsAccess.keywordOPTIONS_SPECTerminalRuleCall_1_0,
      g.optionsAccess.rightCurlyBracketKeyword_3)

    // }
    c.setLinewrap(2).after(g.optionsAccess.rightCurlyBracketKeyword_3)
  }

  /**
   * Configure grammar name formatting.
   *
   * @param c formatter configuration
   */
  protected def grammar(FormattingConfig c) {
    c.setNoSpace.before(g.grammarAccess.semicolonKeyword_3)
    c.setLinewrap(2).after(g.grammarAccess.semicolonKeyword_3)
  }

}
