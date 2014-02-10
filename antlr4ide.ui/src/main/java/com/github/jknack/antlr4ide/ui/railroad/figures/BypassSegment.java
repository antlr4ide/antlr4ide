/*******************************************************************************
 * Copyright (c) 2010 itemis AG (http://www.itemis.eu)
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * Contributors:
 *   Jan Koehnlein - Initial API and implementation
 *******************************************************************************/
package com.github.jknack.antlr4ide.ui.railroad.figures;

import org.eclipse.draw2d.LayoutManager;
import org.eclipse.emf.ecore.EObject;

import com.github.jknack.antlr4ide.ui.railroad.figures.layout.ParallelLayout;
import com.github.jknack.antlr4ide.ui.railroad.figures.primitives.CrossPointSegment;
import com.github.jknack.antlr4ide.ui.railroad.figures.primitives.PrimitiveFigureFactory;

/**
 * A segment with an additional connection bypassing the child segment.
 *
 * @author Jan Koehnlein - Initial contribution and API
 */
public class BypassSegment extends AbstractSegmentFigure {

  public BypassSegment(final EObject eObject, final ISegmentFigure child,
      final PrimitiveFigureFactory primitiveFactory) {
    super(eObject);
    setEntry(primitiveFactory.createCrossPoint(this));
    CrossPointSegment crossPointSegment = new CrossPointSegment(eObject, primitiveFactory);
    if (ILayoutConstants.routeOptionalTop()) {
      add(crossPointSegment);
      add(child);
    } else {
      add(child);
      add(crossPointSegment);
    }
    setExit(primitiveFactory.createCrossPoint(this));
    primitiveFactory.createConnection(getEntry(), crossPointSegment.getEntry(), this,
        ILayoutConstants.CONCAVE_START);
    primitiveFactory.createConnection(crossPointSegment.getExit(), getExit(), this,
        ILayoutConstants.CONCAVE_END);
    primitiveFactory.createConnection(getEntry(), child.getEntry(), this,
        ILayoutConstants.CONCAVE_START);
    primitiveFactory.createConnection(child.getExit(), getExit(), this,
        ILayoutConstants.CONCAVE_END);
  }

  @Override
  protected LayoutManager createLayoutManager() {
    return new ParallelLayout();
  }

}
