package com.github.jknack.antlr4ide.ui.railroad.trafo

import com.github.jknack.antlr4ide.ui.railroad.figures.ISegmentFigure
import org.eclipse.emf.ecore.EObject
import com.github.jknack.antlr4ide.lang.ParserRule
import com.github.jknack.antlr4ide.lang.LexerRule
import com.google.inject.Inject
import com.github.jknack.antlr4ide.lang.Grammar
import com.github.jknack.antlr4ide.lang.RuleBlock
import com.github.jknack.antlr4ide.lang.RuleAltList
import java.util.List
import com.github.jknack.antlr4ide.lang.Element
import com.github.jknack.antlr4ide.lang.Alternative
import com.github.jknack.antlr4ide.lang.LabeledAlt
import com.github.jknack.antlr4ide.lang.LabeledElement
import com.github.jknack.antlr4ide.lang.Atom
import com.github.jknack.antlr4ide.lang.Range
import com.github.jknack.antlr4ide.lang.Terminal
import com.github.jknack.antlr4ide.lang.V3Token
import com.github.jknack.antlr4ide.lang.V4Token
import com.github.jknack.antlr4ide.lang.RuleRef
import com.github.jknack.antlr4ide.ui.railroad.figures.primitives.NodeType
import com.github.jknack.antlr4ide.lang.NotSet
import com.github.jknack.antlr4ide.lang.SetElement
import com.github.jknack.antlr4ide.lang.BlockSet
import com.github.jknack.antlr4ide.lang.Ebnf
import com.github.jknack.antlr4ide.lang.Block
import com.github.jknack.antlr4ide.lang.AltList
import com.github.jknack.antlr4ide.lang.LexerRuleBlock
import com.github.jknack.antlr4ide.lang.LexerAltList
import com.github.jknack.antlr4ide.lang.LexerAlt
import com.github.jknack.antlr4ide.lang.LexerElements
import com.github.jknack.antlr4ide.lang.LexerElement
import com.github.jknack.antlr4ide.lang.LabeledLexerElement
import com.github.jknack.antlr4ide.lang.LexerAtom
import com.github.jknack.antlr4ide.lang.Wildcard
import com.github.jknack.antlr4ide.lang.LexerCharSet
import com.github.jknack.antlr4ide.lang.LexerBlock
import com.github.jknack.antlr4ide.lang.ActionElement

class Antlr4RailroadTransformer {

  @Inject
  Antlr4RailroadFactory factory

  def ISegmentFigure transform(EObject object) {
    toFigure(object)
  }

  def dispatch ISegmentFigure toFigure(Grammar grammar) {
    val List<EObject> rules = newArrayList(grammar.rules)
    grammar.modes.forEach[it|rules.addAll(it.rules)]
    factory.createDiagram(grammar, children(rules))
  }

  def dispatch ISegmentFigure toFigure(ParserRule rule) {
    val body = toFigure(rule.body)
    val track = factory.createTrack(rule, body)
    return track
  }

  def dispatch ISegmentFigure toFigure(RuleBlock block) {
    toFigure(block.body)
  }

  def dispatch ISegmentFigure toFigure(RuleAltList alt) {
    factory.createParallel(alt, children(alt.alternatives))
  }

  def dispatch ISegmentFigure toFigure(LabeledAlt labeledAlt) {
    toFigure(labeledAlt.body)
  }

  def dispatch ISegmentFigure toFigure(Alternative alt) {
    if (alt.elements.size == 0) {
      factory.createNodeSegment(alt, "", NodeType.EMPTY_ALT)
    } else {
      factory.createSequence(alt, children(alt.elements))
    }
  }

  def dispatch ISegmentFigure toFigure(Element element) {
    val body = toFigure(element.body)
    factory.createEbnf(body, element.operator)
  }

  def dispatch ISegmentFigure toFigure(LabeledElement ele) {
    toFigure(ele.body)
  }

  def dispatch ISegmentFigure toFigure(Atom atom) {
    toFigure(atom.body)
  }

  def dispatch ISegmentFigure toFigure(Range range) {
    factory.createNodeSegment(range, "'" + range.from + ".." + range.to + "'", NodeType.RECTANGLE)
  }

  def dispatch ISegmentFigure toFigure(Terminal terminal) {
    val literal = terminal.literal
    if (literal != null) {
      if (literal == "EOF") {
        factory.createNodeSegment(terminal, literal, NodeType.RECTANGLE)
      } else {
        factory.createNodeSegment(terminal, "'" + escape(literal) + "'", NodeType.RECTANGLE)
      }
    } else {
      factory.createNodeSegment(terminal, nameOf(terminal.reference), NodeType.RECTANGLE)
    }
  }

  def dispatch ISegmentFigure toFigure(V3Token token) {
    factory.createNodeSegment(token, token.id, NodeType.RECTANGLE)
  }

  def dispatch ISegmentFigure toFigure(V4Token token) {
    factory.createNodeSegment(token, token.name, NodeType.RECTANGLE)
  }

  private def escape(String value) {
    value.replace("\n", "\\n")
      .replace("\t", "\\t")
      .replace("\f", "\\f")
      .replace("\r", "\\r")
  }

  def dispatch ISegmentFigure toFigure(RuleRef ruleRef) {
    factory.createNodeSegment(ruleRef, ruleRef.reference.name, NodeType.ROUNDED)
  }

  def dispatch ISegmentFigure toFigure(NotSet notSet) {
    val body = toFigure(notSet.body)
    val not = factory.createNodeSegment(notSet, "'~'", NodeType.RECTANGLE)
    factory.createSequence(notSet, newArrayList(not, body))
  }

  def dispatch ISegmentFigure toFigure(BlockSet blockSet) {
    factory.createCompartment(blockSet, children(blockSet.elements))
  }

  def dispatch ISegmentFigure toFigure(SetElement element) {
    if (element.tokenRef != null) {
      factory.createNodeSegment(element, element.tokenRef, NodeType.RECTANGLE)
    } else if (element.stringLiteral != null) {
      factory.createNodeSegment(element, element.stringLiteral, NodeType.RECTANGLE)
    } else if (element.charSet != null) {
      factory.createNodeSegment(element, element.charSet, NodeType.RECTANGLE)
    } else {
      toFigure(element.range)
    }
  }

  def dispatch ISegmentFigure toFigure(Ebnf ebnf) {
    val body = toFigure(ebnf.body)
    factory.createEbnf(body, ebnf.operator)
  }

  def dispatch ISegmentFigure toFigure(Block block) {
    toFigure(block.body)
  }

  def dispatch ISegmentFigure toFigure(AltList alt) {
    factory.createParallel(alt, children(alt.alternatives))
  }

  def dispatch String nameOf(LexerRule rule) {
    rule.name
  }

  def dispatch String nameOf(EObject object) {
    "<missing>"
  }

  def dispatch String nameOf(V3Token token) {
    token.id
  }

  def dispatch String nameOf(V4Token token) {
    token.name
  }

  def dispatch ISegmentFigure toFigure(LexerRule rule) {
    val body = toFigure(rule.body)
    val track = factory.createTrack(rule, body)
    return track
  }

  def dispatch ISegmentFigure toFigure(LexerRuleBlock block) {
    toFigure(block.body)
  }

  def dispatch ISegmentFigure toFigure(LexerAltList alt) {
    factory.createParallel(alt, children(alt.alternatives))
  }

  def dispatch ISegmentFigure toFigure(LexerAlt alt) {
    toFigure(alt.body)
  }

  def dispatch ISegmentFigure toFigure(LexerElements elements) {
    factory.createSequence(elements, children(elements.elements))
  }

  def dispatch ISegmentFigure toFigure(LexerElement element) {
    val body = toFigure(element.body)
    factory.createEbnf(body, element.operator)
  }

  def dispatch ISegmentFigure toFigure(LabeledLexerElement element) {
    toFigure(element.body)
  }

  def dispatch ISegmentFigure toFigure(LexerAtom atom) {
    toFigure(atom.body)
  }

  def dispatch ISegmentFigure toFigure(Wildcard wilcard) {
    factory.createNodeSegment(wilcard, "'.'", NodeType.RECTANGLE)
  }

  def dispatch ISegmentFigure toFigure(LexerCharSet charSet) {
    factory.createNodeSegment(charSet, charSet.body, NodeType.RECTANGLE)
  }

  def dispatch ISegmentFigure toFigure(LexerBlock block) {
    toFigure(block.body)
  }

  def dispatch ISegmentFigure toFigure(ActionElement action) {
    factory.createNodeSegment(action, action.body, NodeType.RECTANGLE)
  }

  private def children(List<? extends EObject> iterator) {
    val List<ISegmentFigure> figures = newArrayList()
    for (child : iterator) {
      val figure = transform(child)
      if (figure != null) {
        figures += figure
      }
    }
    return figures;
  }
}
