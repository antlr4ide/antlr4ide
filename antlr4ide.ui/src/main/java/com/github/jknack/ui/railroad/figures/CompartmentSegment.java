package com.github.jknack.ui.railroad.figures;

import org.eclipse.draw2d.Graphics;
import org.eclipse.draw2d.LayoutManager;
import org.eclipse.draw2d.LineBorder;
import org.eclipse.emf.ecore.EObject;

import com.github.jknack.ui.railroad.figures.layout.CompartmentLayout;
import com.github.jknack.ui.railroad.figures.primitives.PrimitiveFigureFactory;

/**
 * A track segment in a compartment.
 *
 * @author Jan Koehnlein
 */
public class CompartmentSegment extends AbstractSegmentFigure {

  private ISegmentFigure innerFigure;

  public CompartmentSegment(final EObject eObject, final ISegmentFigure innerSegment, final PrimitiveFigureFactory primitiveFactory) {
    super(eObject);
    setEntry(primitiveFactory.createCrossPoint(this));
    setExit(primitiveFactory.createCrossPoint(this));
    add(innerSegment);
    primitiveFactory.createConnection(getEntry(), innerSegment.getEntry(), this);
    primitiveFactory.createConnection(innerSegment.getExit(), getExit(), this);
    setBorder(new LineBorder(getForegroundColor(), 1, Graphics.LINE_DASH));
    innerFigure = innerSegment;
  }

  public ISegmentFigure getInnerSegment() {
    return innerFigure;
  }

  @Override
  protected LayoutManager createLayoutManager() {
    return new CompartmentLayout();
  }

}