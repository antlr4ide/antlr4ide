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

import org.eclipse.draw2d.IFigure;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.jface.text.Region;
import org.eclipse.swt.graphics.Font;
import org.eclipse.swt.widgets.Display;

import com.github.jknack.ui.railroad.figures.layout.RailroadConnectionRouter;
import com.google.inject.Inject;

public class PrimitiveFigureFactory {

  @Inject
  private RailroadConnectionRouter connectionRouter;

  private Font font;

  public AbstractNode createNode(final NodeType nodeType, final EObject eObject, final String name, final IFigure containerFigure, final Region textRegion) {
    AbstractNode node = newNode(nodeType, eObject, name, textRegion);
    containerFigure.add(node);
    return node;
  }

  public CrossPoint createCrossPoint(final IFigure containerFigure) {
    CrossPoint crossPoint = new CrossPoint();
    containerFigure.add(crossPoint);
    return crossPoint;
  }

  public Connection createConnection(final CrossPoint source, final CrossPoint target, final IFigure containerFigure) {
    Connection connection = new Connection(source, target);
    containerFigure.add(connection);
    connection.setConnectionRouter(connectionRouter);
    return connection;
  }

  public Connection createConnection(final CrossPoint source, final CrossPoint target, final IFigure containerFigure,
      final RailroadConnectionRouter.BendConstraint bendConstraint) {
    Connection connection = new Connection(source, target);
    containerFigure.add(connection);
    connection.setConnectionRouter(connectionRouter);
    connectionRouter.setConstraint(connection, bendConstraint);
    return connection;
  }

  protected AbstractNode newNode(final NodeType type, final EObject eObject, final String text, final Region textRegion) {
    switch (type) {
    case RECTANGLE:
      return new RectangleNode(eObject, text, getFont(), textRegion);
    case ROUNDED:
      return new RoundedNode(eObject, text, getFont(), textRegion);
    case ERROR:
      return new ErrorNode(eObject, text, getFont(), textRegion);
    case LABEL:
      return new LabelNode(eObject, text, getFont(), textRegion);
    default:
      throw new IllegalArgumentException("Unknown node type " + type);
    }
  }

  protected Font getFont() {
    if (font == null) {
      if (Display.getCurrent() != null) {
        font = Display.getCurrent().getSystemFont();
      } else {
        Display.getDefault().syncExec(new Runnable() {
          @Override
          public void run() {
            font = Display.getCurrent().getSystemFont();
          }
        });
      }
    }
    return font;
  }
}