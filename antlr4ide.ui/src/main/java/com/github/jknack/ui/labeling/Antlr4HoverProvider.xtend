package com.github.jknack.ui.labeling

import org.eclipse.xtext.ui.editor.hover.html.DefaultEObjectHoverProvider
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.nodemodel.util.NodeModelUtils
import com.github.jknack.antlr4.Grammar
import com.github.jknack.antlr4.RuleRef
import com.github.jknack.antlr4.Terminal
import com.github.jknack.antlr4.LexerRule
import com.github.jknack.antlr4.V3Token
import com.github.jknack.antlr4.V4Token
import com.github.jknack.antlr4.ParserRule

class Antlr4HoverProvider extends DefaultEObjectHoverProvider {

  override protected getFirstLine(EObject o) {
    val body = body(o)
    return getLabel(o) + ":<p>    " + body + "</p>"
  }

  private def dispatch String body(Grammar grammar) {
    grammar.name
  }

  private def dispatch String body(RuleRef ref) {
    val rule = ref.reference
    NodeModelUtils.findActualNodeFor(rule.body).text
  }

  private def dispatch String body(Terminal terminal) {
    val literal = terminal.literal
    if (literal != null) literal else body(terminal.reference)
  }

  private def dispatch String body(ParserRule rule) {
    NodeModelUtils.findActualNodeFor(rule.body).text
  }

  private def dispatch String body(LexerRule rule) {
    NodeModelUtils.findActualNodeFor(rule.body).text
  }

  private def dispatch String body(V3Token token) {
    token.id
  }

  private def dispatch String body(V4Token token) {
    token.name
  }

  private def dispatch String body(EObject object) {
    ""
  }
}
