/*******************************************************************************
 * Copyright (c) 2010 itemis AG (http://www.itemis.eu)
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * Contributors:
 *   Jan Koehnlein - Initial API and implementation
 *******************************************************************************/
package com.github.jknack.ui.railroad.figures.primitives

import org.eclipse.draw2d.Border
import org.eclipse.draw2d.ColorConstants
import org.eclipse.draw2d.Label
import org.eclipse.draw2d.ToolbarLayout
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.jface.text.Region
import org.eclipse.swt.graphics.Color
import org.eclipse.swt.graphics.Font

import com.github.jknack.ui.railroad.figures.IEObjectReferer
import com.github.jknack.ui.railroad.figures.ISelectable

/**
 * Base class of all nodes.
 *
 * @author Jan Koehnlein - Initial contribution and API
 */
abstract class AbstractNode extends CrossPoint implements IEObjectReferer, ISelectable {

  public static val PADDING = 5

  Label label

  boolean isSelected = false

  URI grammarElementURI

  Region textRegion

  new (EObject eObject, String text, Font font, Region textRegion) {
    if (eObject != null) {
      grammarElementURI = EcoreUtil.getURI(eObject);
    }
    layoutManager = new ToolbarLayout()
    backgroundColor = unselectedBackgroundColor
    label = new Label(text)
    add(label)
    border = createBorder()
    this.font = font
    this.textRegion = textRegion
  }

  protected abstract def Border createBorder()

  override setFont(Font f) {
    super.font = f
    label.font = f
  }

  override setSelected(boolean isSelected) {
    if (isSelected != this.isSelected) {
      if (isSelected) {
        backgroundColor = selectedBackgroundColor
      } else {
        backgroundColor = unselectedBackgroundColor
      }
      this.isSelected = isSelected
      invalidate()
    }
  }

  protected def Color getSelectedBackgroundColor() {
    return ColorConstants::lightGray
  }

  protected def Color getUnselectedBackgroundColor() {
    return ColorConstants::buttonLightest
  }

  override URI getEObjectURI() {
    return grammarElementURI
  }

  override Region getTextRegion() {
    return textRegion
  }

  @Override
  override getMaximumSize() {
    return preferredSize
  }

  def isSelectable() {
    return true
  }
}