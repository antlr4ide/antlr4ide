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
import com.github.jknack.ui.railroad.figures.ISegmentFigure

/**
 * Layouts children vertically with common entry and exit nodes to the left /
 * right.
 *
 * @author Jan Koehnlein - Initial contribution and API
 */
class ParallelLayout extends AbstractLayout {

  int hmargin

  new (int hmargin) {
    this.hmargin = hmargin
  }

  new () {
    this(0)
  }

  override layout(IFigure containerSegment) {
    if (containerSegment instanceof ISegmentFigure) {
      var width = 0
      for (Object child : containerSegment.children) {
        if (child instanceof ISegmentFigure) {
          val childSize = child.preferredSize
          width = Math.max(width, childSize.width)
        }
      }
      var y = 0
      val bounds = Rectangle.SINGLETON;
      for (Object child : containerSegment.children) {
        if (child instanceof ISegmentFigure) {
          val childSize = child.preferredSize
          bounds.setLocation(ILayoutConstants::parallelSegmentHSpace + hmargin + (width - childSize.width)
              / 2, y)
          bounds.size = childSize
          child.bounds = bounds
          y = y + childSize.height + ILayoutConstants::vSpace
        }
      }
      y = (y - ILayoutConstants::vSpace) / 2
      bounds.setLocation(hmargin, y)
      bounds.setSize(0, 0)
      containerSegment.entry.bounds = bounds
      bounds.setLocation(width + 2 * ILayoutConstants::parallelSegmentHSpace + hmargin, y)
      containerSegment.exit.bounds = bounds
    }
  }

  override calculatePreferredSize(IFigure containerSegment, int wHint, int hHint) {
    if (containerSegment instanceof ISegmentFigure) {
      var width = 0
      var height = 0
      for (Object child : containerSegment.children) {
        if (child instanceof ISegmentFigure) {
          val childSize = child.preferredSize
          width = Math.max(width, childSize.width)
          height = height + childSize.height + ILayoutConstants::vSpace
        }
      }
      height = height - ILayoutConstants::vSpace
      width = width + (2 * ILayoutConstants::parallelSegmentHSpace + 2 * hmargin + 1)
      return new Dimension(width, height)
    }
    return new Dimension()
  }

}