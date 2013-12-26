package com.github.jknack.validation

import com.github.jknack.antlr4.Grammar
import com.github.jknack.antlr4.ParserRule
import com.github.jknack.antlr4.Rule
import java.util.Set
import org.eclipse.xtext.validation.Check
import org.eclipse.emf.ecore.EObject
import com.github.jknack.antlr4.V3Tokens
import com.github.jknack.antlr4.GrammarType
import com.github.jknack.antlr4.LexerRule
import com.github.jknack.antlr4.LabeledAlt
import org.eclipse.emf.ecore.util.EcoreUtil
import com.github.jknack.antlr4.V3Token
import com.github.jknack.antlr4.EmptyTokens
import com.github.jknack.antlr4.Antlr4Package

/**
 * Custom validation rules. 
 *
 * see http://www.eclipse.org/Xtext/documentation.html#validation
 */
class Antlr4Validator extends AbstractAntlr4Validator {

  private Set<String> keywords = newHashSet("rule")

  public static val GRAMMAR_NAME_DIFFER = "grammarNameDiffer"

  @Check
  def checkGrammarName(Grammar grammar) {
    val resource = grammar.eResource.URI
    val filename = resource.lastSegment.replace("." + resource.fileExtension, "")
    val name = grammar.name
    if (filename != name) {
      error(
        "grammar name '" + name + "' and file name '" + resource.lastSegment + "' differ",
        Antlr4Package.Literals.GRAMMAR__NAME, GRAMMAR_NAME_DIFFER, name, filename
      )
    }
  }

  @Check
  def checkTreeGrammar(Grammar grammar) {
    if (grammar.type == GrammarType.TREE) {
      error(
        "tree grammars are not supported in ANTLR 4",
        grammar,
        grammar.eClass.getEStructuralFeature("name")
      )
    }
  }

  @Check
  def checkEmptyRules(Grammar grammar) {
    val filter = if(grammar.type == GrammarType.LEXER) LexerRule else ParserRule
    val rules = grammar.rules
    if (rules == null || rules.filter(filter).length == 0) {
      error(
        "grammar '" + grammar.name + "' has no rules",
        grammar,
        grammar.eClass.getEStructuralFeature("name")
      )
    }
  }

  @Check
  def v3Tokens(V3Tokens tokens) {
    warning(
      "tokens {A; B;}' syntax is now 'tokens {A, B}' in ANTLR 4",
      tokens,
      tokens.eClass.getEStructuralFeature("keyword")
    )
  }

  @Check
  def v3Token(V3Token token) {
    if (token.value != null && token.value.length > 0) {
      error(
        "assignments in tokens{} are not supported in ANTLR 4; use lexical rule '" + token.id + ": " +
          token.value + "' instead",
        token,
        token.eClass.getEStructuralFeature("id")
      )
    }
  }

  @Check
  def emptyTokens(EmptyTokens tokens) {
    warning(
      "tokens {} are empty",
      tokens,
      tokens.eClass.getEStructuralFeature("keyword")
    )
  }

  @Check
  def nameConflict(Rule rule) {
    val name = rule.name
    nameConflict(name, rule)
  }

  @Check
  def nameConflict(LabeledAlt labeledAlt) {
    val grammar = EcoreUtil.getRootContainer(labeledAlt) as Grammar
    val name = labeledAlt.label
    if (grammar.rules.exists[it.name == name]) {
      error(
        "rule alt label '" + name + "' conflicts with rule '" + name + "'",
        labeledAlt,
        labeledAlt.eClass.getEStructuralFeature("label")
      )
    }
  }

  private def nameConflict(String name, EObject source) {
    if (keywords.contains(name)) {
      error(
        "symbol '" + name + "'conflicts with generated code in target language or runtime",
        source,
        source.eClass.getEStructuralFeature("name")
      )
    }
  }
}
