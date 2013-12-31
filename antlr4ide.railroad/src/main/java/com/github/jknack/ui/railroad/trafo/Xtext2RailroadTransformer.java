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

import java.util.Collections;
import java.util.List;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.xtext.AbstractRule;
import org.eclipse.xtext.Alternatives;
import org.eclipse.xtext.Assignment;
import org.eclipse.xtext.CrossReference;
import org.eclipse.xtext.EnumLiteralDeclaration;
import org.eclipse.xtext.Grammar;
import org.eclipse.xtext.Group;
import org.eclipse.xtext.Keyword;
import org.eclipse.xtext.RuleCall;
import org.eclipse.xtext.TerminalRule;
import org.eclipse.xtext.UnorderedGroup;
import org.eclipse.xtext.util.PolymorphicDispatcher;

import com.github.jknack.ui.railroad.figures.ISegmentFigure;
import com.google.common.collect.Lists;
import com.google.inject.Inject;

/**
 * Transforms an Xtext grammar model into a diagram consisting of composite
 * figures.
 *
 * @author Jan Koehnlein - Initial contribution and API
 */
public class Xtext2RailroadTransformer {

  private PolymorphicDispatcher<ISegmentFigure> transformer = new PolymorphicDispatcher<ISegmentFigure>(
      "transformInternal", 1, 1, Collections.singletonList(this),
      new PolymorphicDispatcher.ErrorHandler<ISegmentFigure>() {
        @Override
        public ISegmentFigure handle(final Object[] params, final Throwable throwable) {
          EObject grammarElement = (params[0] instanceof EObject) ? (EObject) params[0] : null;
          return factory.createNodeSegment(grammarElement, throwable);
        }
      });

  @Inject
  private Xtext2RailroadFactory factory;

  public ISegmentFigure transform(final EObject object) {
    return transformer.invoke(object);
  }

  protected ISegmentFigure transformInternal(final Grammar grammar) {
    List<ISegmentFigure> children = transformChildren(grammar.getRules());
    ISegmentFigure diagram = factory.createDiagram(grammar, children);
    return diagram;
  }

  protected ISegmentFigure transformInternal(final AbstractRule rule) {
    if (rule instanceof TerminalRule) {
      return null;
    }
    ISegmentFigure body = transform(rule.getAlternatives());
    ISegmentFigure track = factory.createTrack(rule, body);
    return track;
  }

  protected ISegmentFigure transformInternal(final EObject eObject) {
    return null;
  }

  protected ISegmentFigure transformInternal(final Alternatives alternatives) {
    List<ISegmentFigure> children = transformChildren(alternatives.getElements());
    return factory.createParallel(alternatives, children);
  }

  protected ISegmentFigure transformInternal(final Group group) {
    List<ISegmentFigure> children = transformChildren(group.getElements());
    return factory.createSequence(group, children);
  }

  protected ISegmentFigure transformInternal(final UnorderedGroup unorderedGroup) {
    List<ISegmentFigure> children = transformChildren(unorderedGroup.getElements());
    return factory.createCompartment(unorderedGroup, children);
  }

  protected ISegmentFigure transformInternal(final Keyword keyword) {
    return factory.createNodeSegment(keyword);
  }

  protected ISegmentFigure transformInternal(final RuleCall ruleCall) {
    return factory.createNodeSegment(ruleCall);
  }

  protected ISegmentFigure transformInternal(final Assignment assignment) {
    return transform(assignment.getTerminal());
  }

  protected ISegmentFigure transformInternal(final CrossReference crossReference) {
    return transform(crossReference.getTerminal());
  }

  protected ISegmentFigure transformInternal(final EnumLiteralDeclaration enumLiteralDeclaration) {
    return factory.createNodeSegment(enumLiteralDeclaration);
  }

  private List<ISegmentFigure> transformChildren(final List<? extends EObject> children) {
    List<ISegmentFigure> transformedChildren = Lists.newArrayList();
    for (EObject child : children) {
      ISegmentFigure transformedChild = transform(child);
      if (transformedChild != null) {
        transformedChildren.add(transformedChild);
      }
    }
    return transformedChildren;
  }

}
