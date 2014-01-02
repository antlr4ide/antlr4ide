/*******************************************************************************
 * Copyright (c) 2010 itemis AG (http://www.itemis.eu)
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

import com.github.jknack.ui.railroad.figures.ILayoutConstants

/**
 * Layouts children left to right an centered vertically. Could not find a
 * Draw2D layout for this :-(
 *
 * @author Jan Koehnlein - Initial contribution and API
 */
class SequenceLayout extends AbstractLayout {

  int minHeight

  new (int minHeight) {
    this.minHeight = minHeight;
  }

  new () {
    this(0)
  }

  override layout(IFigure container) {
    var height = minHeight;
    for (Object child : container.children) {
      if (child instanceof IFigure) {
        val childSize = child.preferredSize
        height = Math.max(height, childSize.height)
      }
    }
    val bounds = Rectangle.SINGLETON
    var x = 0
    for (Object child : container.children) {
      if (child instanceof IFigure) {
        val childSize = child.preferredSize
        bounds.setLocation(x, (height - childSize.height) / 2)
        bounds.size = childSize
        child.bounds = bounds
        x = x + childSize.width + ILayoutConstants::hSpace
      }
    }
  }

  override calculatePreferredSize(IFigure container, int wHint, int hHint) {
    var width = 0
    var height = minHeight
    for (Object child : container.children) {
      if (child instanceof IFigure) {
        val childSize = child.preferredSize
        height = Math.max(height, childSize.height)
        width = width + childSize.width + ILayoutConstants::hSpace
      }
    }
    width = width - ILayoutConstants::hSpace
    return new Dimension(width, height)
  }

}