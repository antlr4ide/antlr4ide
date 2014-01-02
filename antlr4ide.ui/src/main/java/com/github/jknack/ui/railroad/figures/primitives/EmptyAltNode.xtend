package com.github.jknack.ui.railroad.figures.primitives

import org.eclipse.emf.ecore.EObject
import org.eclipse.swt.graphics.Font
import org.eclipse.jface.text.Region
import org.eclipse.draw2d.MarginBorder
import org.eclipse.draw2d.LineBorder
import org.eclipse.draw2d.ColorConstants

class EmptyAltNode extends AbstractNode {

  new (EObject eObject, String text, Font font, Region region) {
    super(eObject, text, font, region)
    setOpaque(false)
  }

  override setSelected(boolean isSelected) {
    super.setSelected(isSelected);
    setOpaque(isSelected);
  }

  override createBorder() {
    val marginBorder = new MarginBorder(PADDING, 0, PADDING, 0)
    val lineBorder = new LineBorder(1);
    lineBorder.setColor(ColorConstants.black);
    return marginBorder
  }
}
