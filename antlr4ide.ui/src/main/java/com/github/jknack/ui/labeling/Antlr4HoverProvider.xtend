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
import org.eclipse.xtext.nodemodel.INode
import org.eclipse.xtext.nodemodel.ILeafNode
import org.eclipse.xtext.nodemodel.ICompositeNode

class Antlr4HoverProvider extends DefaultEObjectHoverProvider {

  override protected getFirstLine(EObject o) {
    val body = body(o)
    return getLabel(o) + ":<p>    " + body + "</p>"
  }

  private def dispatch String body(Grammar grammar) {
    ""
  }

  private def dispatch String body(RuleRef ref) {
    text(ref.reference)
  }

  private def dispatch String body(Terminal terminal) {
    val literal = terminal.literal
    if (literal != null) literal else text(terminal.reference)
  }

  private def dispatch String body(ParserRule rule) {
    text(rule.body)
  }

  private def dispatch String body(LexerRule rule) {
    text(rule.body)
  }

  private def String text(EObject source) {
    val node = NodeModelUtils.findActualNodeFor(source)
    text(node)
  }

  private def String text(INode node) {
    if (node instanceof ILeafNode) {
      return if (node.hidden) " " else node.text
    } else {
      val composite = node as ICompositeNode
      val buff = new StringBuilder
      for(child : composite.children) {
        buff.append(text(child))
      }
      return buff.toString
    } 
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
