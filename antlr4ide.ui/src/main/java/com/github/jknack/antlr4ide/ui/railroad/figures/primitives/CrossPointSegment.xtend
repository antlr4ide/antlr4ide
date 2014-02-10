/*******************************************************************************
 * Copyright (c) 2010 itemis AG (http://www.itemis.eu)
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * Contributors:
 *   Jan Koehnlein - Initial API and implementation
 *******************************************************************************/
package com.github.jknack.antlr4ide.ui.railroad.figures.primitives

import org.eclipse.emf.ecore.EObject

import com.github.jknack.antlr4ide.ui.railroad.figures.AbstractSegmentFigure
import com.github.jknack.antlr4ide.ui.railroad.figures.ILayoutConstants
import com.github.jknack.antlr4ide.ui.railroad.figures.layout.SequenceLayout

/**
 * A segment containing a single {@link CrossPoint}.
 *
 * @author Jan Koehnlein - Initial contribution and API
 */
class CrossPointSegment extends AbstractSegmentFigure {

  new (EObject eObject, PrimitiveFigureFactory primitiveFactory) {
    super(eObject)
    val crossPoint = primitiveFactory.createCrossPoint(this)
    entry = crossPoint
    exit = crossPoint
  }

  override createLayoutManager() {
    return new SequenceLayout(ILayoutConstants::minSegmentHeight)
  }

}