package com.github.jknack.scoping

import org.eclipse.xtext.scoping.IScope
import com.github.jknack.antlr4.Grammar
import org.eclipse.emf.ecore.EReference
import com.google.common.collect.Lists
import org.eclipse.xtext.scoping.Scopes
import org.eclipse.emf.ecore.EObject
import com.github.jknack.antlr4.Imports
import com.github.jknack.antlr4.Rule
import com.github.jknack.antlr4.ParserRule
import com.github.jknack.antlr4.LexerRule
import org.eclipse.xtext.scoping.impl.AbstractDeclarativeScopeProvider
import java.util.List
import com.github.jknack.antlr4.V3Tokens
import com.github.jknack.antlr4.V4Tokens
import com.github.jknack.antlr4.Options
import com.github.jknack.antlr4.TokenVocab
import static extension org.eclipse.xtext.EcoreUtil2.*

/**
 * Calculate and produce 'visible' components (like rules, tokens, grammar).
 * 
 * see : http://www.eclipse.org/Xtext/documentation.html#scoping
 * on how and when to use it 
 *
 */
class Antlr4ScopeProvider extends AbstractDeclarativeScopeProvider {

  override getScope(EObject context, EReference reference) {
    val candidate = context.getContainerOfType(Rule)
    if (candidate != null) {
      return scopeFor(candidate)
    }
    return super.getScope(context, reference);
  }

  /**
   * Produces a parser rule scope. The scope is composed by current grammar rules, including
   * parser rules, lexer rules and tokens definitions.
   *
   * Rules and tokens from imported grammar are included too. Via 'import' or 'tokenVocab'.
   */
  def dispatch IScope scopeFor(ParserRule rule) {
    val grammar = rule.eContainer as Grammar;
    val scopes = Lists.<EObject>newArrayList()
    scopes.addAll(grammar.rules)

    // traverse prequels
    for (prequel : grammar.prequels) {
      try {
        scopeFor(prequel, scopes, Rule)
      } catch (IllegalArgumentException ex) {
        // not all the prequel define rules
      }
    }
    return Scopes.scopeFor(scopes, Antlr4NameProvider.nameFn, IScope.NULLSCOPE)
  }

  /**
   * Collect scopes from imported grammars.
   */
  def dispatch void scopeFor(Imports imports, List<EObject> scopes, Class<? extends Rule> filter) {
    for (delegate : imports.imports) {
      scopes.addAll(delegate.importURI.rules.filter(filter))
    }
  }

  /**
   * Collect scopes from a tokenVocab grammar.
   */
  def dispatch void scopeFor(Options options, List<EObject> scopes, Class<? extends Rule> filter) {
    for (option : options.options) {
      if (option instanceof TokenVocab) {
        scopeFor(option, scopes)
      }
    }
  }

  /**
   * Extract scopes from a tokenVocab.
   */
  def void scopeFor(TokenVocab tokenVocab, List<EObject> scopes) {
    val grammar = tokenVocab.importURI;
    if (grammar != null) {
      lexerRules(grammar, scopes);
      for (prequel : grammar.prequels) {
        try {
          scopeFor(prequel, scopes, Rule)
        } catch (IllegalArgumentException ex) {
          // not all the prequel define rules
        }
      }
    }
  }

  /**
   * Collect tokens from deprecated token section.
   */
  def dispatch void scopeFor(V3Tokens tokens, List<EObject> scopes, Class<? extends Rule> filter) {
    for (token : tokens.tokens) {
      scopes.addAll(token)
    }
  }

  /**
   * Collect tokens.
   */
  def dispatch void scopeFor(V4Tokens tokens, List<EObject> scopes, Class<? extends Rule> filter) {
    for (token : tokens.tokens) {
      scopes.addAll(token)
    }
  }

  /**
   * Produces scope for a lexer rule. Scope is defined by current lexer rules and tokens definitions.
   * 
   * Lexer rules and tokens from imported grammar are provided too.
   */
  def dispatch IScope scopeFor(LexerRule rule) {
    val scopes = Lists.<EObject>newArrayList()
    val grammar = rule.getRootContainer() as Grammar

    lexerRules(grammar, scopes);

    // traverse prequels
    for (prequel : grammar.prequels) {
      try {
        scopeFor(prequel, scopes, LexerRule)
      } catch (IllegalArgumentException ex) {
        // not all the prequel define rules
      }
    }

    return Scopes.scopeFor(scopes, Antlr4NameProvider.nameFn, IScope.NULLSCOPE)
  }

  /**
   * Collect lexer rules from a grammar and/or grammar modes.
   */
  def lexerRules(Grammar grammar, List<EObject> scopes) {
    scopes.addAll(grammar.rules.filter(LexerRule))

    if (grammar.modes != null) {
      for (mode : grammar.modes) {
        scopes.add(mode)
        scopes.addAll(mode.rules.filter(LexerRule))
      }
    }
  }

}
