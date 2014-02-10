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

import org.eclipse.draw2d.ChopboxAnchor
import org.eclipse.draw2d.IFigure
import org.eclipse.draw2d.PolylineConnection
import org.eclipse.swt.SWT
import org.eclipse.draw2d.geometry.Point

/**
 * A connection between two {@link CrossPoint}s.
 *
 * @author Jan Koehnlein - Initial contribution and API
 */
class Connection extends PolylineConnection {

  new(CrossPoint source, CrossPoint target) {
    createAnchors(source, target)
    lineCap = SWT.CAP_SQUARE
  }

  def createAnchors(CrossPoint source, CrossPoint target) {
    sourceAnchor = new Anchor(source)
    targetAnchor = new Anchor(target)
  }
}

class Anchor extends ChopboxAnchor {

  new(IFigure owner) {
    super(owner)
  }

  override getLocation(Point reference) {
    val owner = owner
    val bounds = owner.bounds.copy
    owner.translateToAbsolute(bounds)
    if (reference.x < bounds.left.x) {
      return bounds.left
    } else {
      return bounds.getRight
    }
  }

}
