package com.github.jknack.antlr4ide.ui.labeling

import org.eclipse.xtext.ui.editor.hover.html.DefaultEObjectHoverProvider
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.nodemodel.util.NodeModelUtils
import com.github.jknack.antlr4ide.antlr4.Grammar
import com.github.jknack.antlr4ide.antlr4.RuleRef
import com.github.jknack.antlr4ide.antlr4.Terminal
import com.github.jknack.antlr4ide.antlr4.LexerRule
import com.github.jknack.antlr4ide.antlr4.V3Token
import com.github.jknack.antlr4ide.antlr4.V4Token
import com.github.jknack.antlr4ide.antlr4.ParserRule
import org.eclipse.xtext.nodemodel.INode
import org.eclipse.xtext.nodemodel.ILeafNode
import org.eclipse.xtext.nodemodel.ICompositeNode
import com.github.jknack.antlr4ide.antlr4.Rule

class Antlr4HoverProvider extends DefaultEObjectHoverProvider {

  override protected getFirstLine(EObject o) {
    val body = body(o, false)
    return getLabel(o) + ":<p>    " + body + "</p>"
  }

  def String doc(Grammar grammar) {
    getDocumentation(grammar)
  }

  /**
   * Get a rule definition as HTML.
   */
  def String definition(Rule rule) {
    body(rule, true)
  }

  def String doc(Rule rule) {
    getDocumentation(rule)
  }

  private def dispatch String body(Grammar grammar, boolean html) {
    ""
  }

  private def dispatch String body(RuleRef ref, boolean html) {
    text(ref.reference, html)
  }

  private def dispatch String body(Terminal terminal, boolean html) {
    val literal = terminal.literal
    if(literal != null) text(literal, html) else text(terminal.reference, html)
  }

  private def dispatch String body(ParserRule rule, boolean html) {
    text(rule.body, html)
  }

  private def dispatch String body(LexerRule rule, boolean html) {
    text(rule.body, html)
  }

  private def String text(EObject source, boolean html) {
    val node = NodeModelUtils.findActualNodeFor(source)
    text(node, html)
  }

  private def String text(INode node, boolean html) {
    if (node instanceof ILeafNode) {
      return if(node.hidden) " " else text(node.text, html)
    } else {
      val composite = node as ICompositeNode
      val buff = new StringBuilder
      for (child : composite.children) {
        buff.append(text(child, html))
      }
      return buff.toString
    }
  }

  private def String text(String text, boolean html) {
    if (html) {
      return switch (text) {
        case "EOF": '''<span class="keyword">«text»</span>'''
        case text.startsWith("'"): '''<span class="literal">«text»</span>'''
        case text.startsWith("["): '''[<span class="literal">«text.substring(1, text.length - 1)»</span>]'''
        case Character.isUpperCase(text.charAt(0)): '''<a href="#«text»" class="token">«text»</a>'''
        case Character.isLowerCase(text.charAt(0)): '''<a href="#«text»" class="rule">«text»</a>'''
        default: '''<span class="operator">«text»</span>'''
      }
    } else {
      text
    }
  }

  private def dispatch String body(V3Token token, boolean html) {
    if (html) '''<span class="token"> «token.id»</span>''' else token.id
  }

  private def dispatch String body(V4Token token, boolean html) {
    if (html) '''<span class="token"> «token.name»</span>''' else token.name
  }

  private def dispatch String body(EObject object, boolean html) {
    ""
  }
}
