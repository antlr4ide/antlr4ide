/*******************************************************************************
 * Copyright (c) 2011 itemis AG (http://www.itemis.eu)
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * Contributors:
 *   Jan Koehnlein - Initial API and implementation
 *******************************************************************************/
package com.github.jknack.ui.railroad.figures.layout

import org.eclipse.draw2d.AbstractLayout
import org.eclipse.draw2d.IFigure
import org.eclipse.draw2d.geometry.Dimension
import org.eclipse.draw2d.geometry.Rectangle

import com.github.jknack.ui.railroad.figures.CompartmentSegment
import com.github.jknack.ui.railroad.figures.ILayoutConstants

class CompartmentLayout extends AbstractLayout {

  override layout(IFigure compartment) {
    if (compartment instanceof CompartmentSegment) {
      val innerBounds = new Rectangle
      val padding = ILayoutConstants::compartmentPadding
      innerBounds.setLocation(padding, padding)
      innerBounds.size = compartment.innerSegment.preferredSize
      compartment.innerSegment.bounds = innerBounds

      val bounds = Rectangle.SINGLETON
      bounds.setLocation(0, innerBounds.center.y)
      bounds.setSize(0, 0)
      compartment.entry.bounds = bounds
      bounds.setLocation(innerBounds.getRight().x + padding, innerBounds.center.y)
      compartment.exit.bounds = bounds
    }
  }

  override calculatePreferredSize(IFigure compartment, int wHint, int hHint) {
    if (compartment instanceof CompartmentSegment) {
      val padding = ILayoutConstants::compartmentPadding
      val preferredSize = compartment.innerSegment.getPreferredSize(wHint, hHint)
      return new Dimension(preferredSize.width + 2 * padding + 2,
        preferredSize.height + 2 * padding + 2);
    }
    return new Dimension
  }

}
