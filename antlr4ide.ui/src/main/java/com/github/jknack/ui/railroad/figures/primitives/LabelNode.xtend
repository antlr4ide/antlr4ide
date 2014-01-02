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

import org.eclipse.draw2d.Border
import org.eclipse.draw2d.MarginBorder
import org.eclipse.emf.ecore.EObject
import org.eclipse.jface.text.Region
import org.eclipse.swt.graphics.Font

/**
 * A node showing a label only.
 *
 * @author Jan Koehnlein - Initial contribution and API
 */
class LabelNode extends AbstractNode {

  new (EObject eObject, String text, Font font, Region region) {
    super(eObject, text, font, region)
    setOpaque(false)
  }

  override setSelected(boolean isSelected) {
    super.setSelected(isSelected)
    setOpaque(isSelected)
  }

  override Border createBorder() {
    return new MarginBorder(PADDING)
  }

}