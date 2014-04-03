package com.github.jknack.antlr4ide.ui.railroad.trafo

import com.github.jknack.antlr4ide.lang.EbnfSuffix
import com.github.jknack.antlr4ide.lang.Grammar
import com.github.jknack.antlr4ide.lang.Rule
import com.github.jknack.antlr4ide.ui.railroad.figures.CompartmentSegment
import com.github.jknack.antlr4ide.ui.railroad.figures.ISegmentFigure
import com.github.jknack.antlr4ide.ui.railroad.figures.LoopSegment
import com.github.jknack.antlr4ide.ui.railroad.figures.NodeSegment
import com.github.jknack.antlr4ide.ui.railroad.figures.ParallelSegment
import com.github.jknack.antlr4ide.ui.railroad.figures.RailroadDiagram
import com.github.jknack.antlr4ide.ui.railroad.figures.RailroadTrack
import com.github.jknack.antlr4ide.ui.railroad.figures.SequenceSegment
import com.github.jknack.antlr4ide.ui.railroad.figures.primitives.NodeType
import com.google.inject.Inject
import java.util.List
import org.eclipse.emf.ecore.EObject
import org.eclipse.jface.text.Region
import org.eclipse.xtext.nodemodel.util.NodeModelUtils
import com.github.jknack.antlr4ide.ui.railroad.figures.BypassSegment
import com.github.jknack.antlr4ide.ui.railroad.figures.primitives.PrimitiveFigureFactory
import com.github.jknack.antlr4ide.ui.highlighting.AntlrHighlightingConfiguration
import com.github.jknack.antlr4ide.ui.views.ColorProvider

class Antlr4RailroadFactory {

  @Inject
  PrimitiveFigureFactory primitiveFactory

  @Inject
  ColorProvider colorProvider

  def createEbnf(ISegmentFigure segment, EbnfSuffix suffix) {
    if (suffix == null) {
      return segment
    }
    val operator = suffix.operator
    var ebnf = segment
    if (operator == "*" || operator == "+") {
      ebnf = new LoopSegment(suffix, ebnf, primitiveFactory)
    }
    if (operator == "?" || operator == "*") {
      ebnf = new BypassSegment(suffix, ebnf, primitiveFactory)
    }
    return ebnf
  }

  def createDiagram(Grammar grammar, List<ISegmentFigure> children) {
    return new RailroadDiagram(grammar, children);
  }

  def createTrack(Rule rule, ISegmentFigure body) {
    val track = new RailroadTrack(rule, rule.name, body, primitiveFactory, getTextRegion(rule))
    track.foregroundColor = colorProvider.get(AntlrHighlightingConfiguration.RULE)
    track
  }

  def createParallel(EObject alternatives, List<ISegmentFigure> children) {
    return new ParallelSegment(alternatives, children, primitiveFactory)
  }

  def createSequence(EObject group, List<ISegmentFigure> children) {
    if (children.size() == 1) {
      children.get(0)
    } else {
      new SequenceSegment(group, children, primitiveFactory)
    }
  }

  def createCompartment(EObject group, List<ISegmentFigure> children) {
    val multiSwitch = new ParallelSegment(group, children, primitiveFactory)
    val compartmentSegment = new CompartmentSegment(group, multiSwitch, primitiveFactory)
    return compartmentSegment
  }

  def createNodeSegment(EObject source, String name, NodeType type) {
    val region = getTextRegion(source)
    val doc = "Select " + name + " in editor"
    val node = new NodeSegment(source, type, name, doc, primitiveFactory, region)
    if (name != null && name.length > 0) {
      node.foregroundColor = colorProvider.bestFor(name)
    }
    node
  }

  private def Region getTextRegion(EObject eObject) {
    val parseTreeNode = NodeModelUtils.getNode(eObject)
    if (parseTreeNode != null) {
      val parseTreeRegion = parseTreeNode.textRegion
      return new Region(parseTreeRegion.offset, parseTreeRegion.length)
    } else {
      return null
    }
  }
}
