/*******************************************************************************
 * Copyright (c) 2010 itemis AG (http://www.itemis.eu)
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * Contributors:
 *   Jan Koehnlein - Initial API and implementation
 *******************************************************************************/
package com.github.jknack.ui.railroad.figures

import org.eclipse.swt.graphics.Color

import com.github.jknack.ui.railroad.figures.layout.RailroadConnectionRouter

/**
 * All constants used for layouting and rendering.
 *
 * @author Jan Koehnlein - Initial contribution and API
 */
public class ILayoutConstants {

  // common spacings
  def static hSpace() {
    10
  }

  def static vSpace() {
    9
  }

  def static vSpaceBetweenTracks() {
    25
  }

  def static compartmentPadding() {
    10
  }

  def static roundedRectangleRadius() {
    7
  }

  // connections
  def static connectionRadius() {
    5
  }

  def static routeOptionalTop() {
    true
  }

  def static routeMultipleTop() {
    true
  }

  public static val CONVEX_END = new RailroadConnectionRouter.BendConstraint(false, true);
  public static val CONVEX_START = new RailroadConnectionRouter.BendConstraint(true, true);
  public static val CONCAVE_END = new RailroadConnectionRouter.BendConstraint(false, false);
  public static val CONCAVE_START = new RailroadConnectionRouter.BendConstraint(true, false);

  // segments
  def static minSegmentHeight() {
    25
  }

  def static parallelSegmentHSpace() {
    20
  }

}
