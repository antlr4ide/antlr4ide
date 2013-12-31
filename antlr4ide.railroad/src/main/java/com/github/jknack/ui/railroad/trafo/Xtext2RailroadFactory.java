/*******************************************************************************
 * Copyright (c) 2010 itemis AG (http://www.itemis.eu)
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * Contributors:
 *   Jan Koehnlein - Initial API and implementation
 *******************************************************************************/
package com.github.jknack.ui.railroad.trafo;

import java.util.List;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.jface.text.Region;
import org.eclipse.xtext.AbstractElement;
import org.eclipse.xtext.AbstractRule;
import org.eclipse.xtext.Alternatives;
import org.eclipse.xtext.Assignment;
import org.eclipse.xtext.EnumLiteralDeclaration;
import org.eclipse.xtext.Grammar;
import org.eclipse.xtext.GrammarUtil;
import org.eclipse.xtext.Group;
import org.eclipse.xtext.Keyword;
import org.eclipse.xtext.RuleCall;
import org.eclipse.xtext.UnorderedGroup;
import org.eclipse.xtext.nodemodel.ICompositeNode;
import org.eclipse.xtext.nodemodel.util.NodeModelUtils;
import org.eclipse.xtext.util.ITextRegion;

import com.github.jknack.ui.railroad.figures.BypassSegment;
import com.github.jknack.ui.railroad.figures.CompartmentSegment;
import com.github.jknack.ui.railroad.figures.ISegmentFigure;
import com.github.jknack.ui.railroad.figures.LoopSegment;
import com.github.jknack.ui.railroad.figures.NodeSegment;
import com.github.jknack.ui.railroad.figures.ParallelSegment;
import com.github.jknack.ui.railroad.figures.RailroadDiagram;
import com.github.jknack.ui.railroad.figures.RailroadTrack;
import com.github.jknack.ui.railroad.figures.SequenceSegment;
import com.github.jknack.ui.railroad.figures.primitives.NodeType;
import com.github.jknack.ui.railroad.figures.primitives.PrimitiveFigureFactory;
import com.google.inject.Inject;

/**
 * Creates railrowad {@link ISegmentFigure}s and {@link ISegmentFigure}s for Xtext artifacts.
 *
 * @author Jan Koehnlein - Initial contribution and API
 */
public class Xtext2RailroadFactory {

  @Inject
  private PrimitiveFigureFactory primitiveFactory;

  public ISegmentFigure createNodeSegment(final Keyword keyword) {
    NodeSegment nodeSegment = new NodeSegment(keyword, NodeType.RECTANGLE, keyword.getValue(),
        primitiveFactory,
        getTextRegion(keyword));
    Assignment containingAssignment = GrammarUtil.containingAssignment(keyword);
    return wrapCardinalitySegments(containingAssignment != null ? containingAssignment : keyword,
        nodeSegment);
  }

  public ISegmentFigure createNodeSegment(final RuleCall ruleCall) {
    NodeSegment nodeSegment = new NodeSegment(ruleCall, NodeType.ROUNDED, ruleCall.getRule()
        .getName(),
        primitiveFactory, getTextRegion(ruleCall));
    Assignment containingAssignment = GrammarUtil.containingAssignment(ruleCall);
    return wrapCardinalitySegments(containingAssignment != null ? containingAssignment : ruleCall,
        nodeSegment);
  }

  public ISegmentFigure createNodeSegment(final EnumLiteralDeclaration enumLiteralDeclaration) {
    String literalName = (enumLiteralDeclaration.getLiteral() != null) ?
        enumLiteralDeclaration.getLiteral().getValue() : enumLiteralDeclaration.getEnumLiteral()
            .getName();
    NodeSegment nodeSegment = new NodeSegment(enumLiteralDeclaration, NodeType.RECTANGLE,
        literalName, primitiveFactory,
        getTextRegion(enumLiteralDeclaration));
    return nodeSegment;
  }

  public ISegmentFigure createNodeSegment(final EObject grammarElement, final Throwable throwable) {
    return new NodeSegment(grammarElement, NodeType.ERROR, "ERROR", primitiveFactory,
        getTextRegion(grammarElement));
  }

  public ISegmentFigure createTrack(final AbstractRule rule, final ISegmentFigure body) {
    return new RailroadTrack(rule, rule.getName(), body, primitiveFactory, getTextRegion(rule));
  }

  public ISegmentFigure createDiagram(final Grammar grammar, final List<ISegmentFigure> children) {
    return new RailroadDiagram(grammar, children);
  }

  public ISegmentFigure createSequence(final Group group, final List<ISegmentFigure> children) {
    ISegmentFigure sequence = children.size() == 1 ? children.get(0) : new SequenceSegment(group,
        children, primitiveFactory);
    return wrapCardinalitySegments(group, sequence);
  }

  public ISegmentFigure createParallel(final Alternatives alternatives,
      final List<ISegmentFigure> children) {
    ParallelSegment multiSwitch = new ParallelSegment(alternatives, children, primitiveFactory);
    return wrapCardinalitySegments(alternatives, multiSwitch);
  }

  public ISegmentFigure createCompartment(final UnorderedGroup unorderedGroup,
      final List<ISegmentFigure> children) {
    ParallelSegment multiSwitch = new ParallelSegment(unorderedGroup, children, primitiveFactory);
    CompartmentSegment compartmentSegment = new CompartmentSegment(unorderedGroup, multiSwitch,
        primitiveFactory);
    return wrapCardinalitySegments(unorderedGroup, compartmentSegment);
  }

  protected Region getTextRegion(final EObject eObject) {
    ICompositeNode parseTreeNode = NodeModelUtils.getNode(eObject);
    if (parseTreeNode != null) {
      ITextRegion parseTreeRegion = parseTreeNode.getTextRegion();
      return new Region(parseTreeRegion.getOffset(), parseTreeRegion.getLength());
    } else {
      return null;
    }
  }

  protected ISegmentFigure wrapCardinalitySegments(final AbstractElement element,
      final ISegmentFigure segment) {
    ISegmentFigure result = segment;
    if (GrammarUtil.isMultipleCardinality(element)) {
      result = new LoopSegment(element, result, primitiveFactory);
    }
    if (GrammarUtil.isOptionalCardinality(element)) {
      result = new BypassSegment(element, result, primitiveFactory);
    }
    return result;
  }

}
