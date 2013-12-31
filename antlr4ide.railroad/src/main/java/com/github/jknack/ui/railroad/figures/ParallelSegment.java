/*******************************************************************************
 * Copyright (c) 2010 itemis AG (http://www.itemis.eu)
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * Contributors:
 *   Jan Koehnlein - Initial API and implementation
 *******************************************************************************/
package com.github.jknack.ui.railroad.figures;

import java.util.List;

import org.eclipse.draw2d.LayoutManager;
import org.eclipse.emf.ecore.EObject;

import com.github.jknack.ui.railroad.figures.layout.ParallelLayout;
import com.github.jknack.ui.railroad.figures.primitives.CrossPoint;
import com.github.jknack.ui.railroad.figures.primitives.PrimitiveFigureFactory;

/**
 * Connects all child segments to a common entry and a common exit {@link CrossPoint}.
 *
 * @author Jan Koehnlein - Initial contribution and API
 */
public class ParallelSegment extends AbstractSegmentFigure {

  public ParallelSegment(final EObject eObject, final List<ISegmentFigure> children, final PrimitiveFigureFactory primitiveFactory) {
    super(eObject);
    setEntry(primitiveFactory.createCrossPoint(this));
    if (children.isEmpty()) {
      setExit(getEntry());
    } else {
      setExit(primitiveFactory.createCrossPoint(this));
      for (ISegmentFigure child : children) {
        add(child);
        primitiveFactory.createConnection(getEntry(), child.getEntry(), this, ILayoutConstants.CONCAVE_START);
        primitiveFactory.createConnection(child.getExit(), getExit(), this, ILayoutConstants.CONCAVE_END);
      }
    }
  }

  @Override
  protected LayoutManager createLayoutManager() {
    return new ParallelLayout();
  }

}