/*******************************************************************************
 * Copyright (c) 2010 itemis AG (http://www.itemis.eu)
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * Contributors:
 *   Jan Koehnlein - Initial API and implementation
 *******************************************************************************/
package com.github.jknack.ui.railroad.figures.primitives;

import org.eclipse.draw2d.Border;
import org.eclipse.draw2d.Graphics;
import org.eclipse.draw2d.MarginBorder;
import org.eclipse.draw2d.geometry.Rectangle;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.jface.text.Region;
import org.eclipse.swt.graphics.Font;

import com.github.jknack.ui.railroad.figures.ILayoutConstants;

/**
 * @author Jan Koehnlein - Initial contribution and API
 */
class RoundedNode extends AbstractNode {

  new(EObject eObject, String text, Font font, Region textRegion) {
    super(eObject, text, font, textRegion)
    setOpaque(true)
  }

  override Border createBorder() {
    return new MarginBorder(PADDING)
  }

  override paintFigure(Graphics graphics) {
    val lineInset = 0.5f
    val inset1 = Math.floor(lineInset) as int
    val inset2 = Math.ceil(lineInset) as int

    val r = Rectangle.SINGLETON.bounds = bounds
    r.x = r.x + inset1
    r.y = r.y + inset1
    r.width = r.width - (inset1 + inset2)
    r.height = r.height - (inset1 + inset2)

    val arc = Math.max(0, ILayoutConstants::roundedRectangleRadius - lineInset) as int
    graphics.fillRoundRectangle(r, arc, arc)
    graphics.drawRoundRectangle(r, arc, arc)
  }
}
