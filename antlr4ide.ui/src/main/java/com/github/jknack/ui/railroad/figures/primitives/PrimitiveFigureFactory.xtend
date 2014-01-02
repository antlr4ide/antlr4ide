package com.github.jknack.ui.railroad.figures.primitives

import com.google.inject.Inject
import com.github.jknack.ui.railroad.figures.layout.RailroadConnectionRouter
import org.eclipse.swt.graphics.Font
import org.eclipse.emf.ecore.EObject
import org.eclipse.draw2d.IFigure
import org.eclipse.jface.text.Region
import org.eclipse.draw2d.ColorConstants
import com.github.jknack.ui.railroad.figures.layout.RailroadConnectionRouter.BendConstraint
import org.eclipse.swt.widgets.Display

class PrimitiveFigureFactory {
  @Inject
  RailroadConnectionRouter connectionRouter;

  Font font;

  def createNode(NodeType nodeType, EObject source, String name, IFigure containerFigure, Region region) {
    val node = newNode(nodeType, source, name, region)
    containerFigure.add(node)
    node
  }

  def CrossPoint createCrossPoint(IFigure containerFigure) {
    val crossPoint = new CrossPoint()
    containerFigure.add(crossPoint)
    crossPoint.setForegroundColor(ColorConstants.black)
    return crossPoint
  }

  def createConnection(CrossPoint source, CrossPoint target, IFigure containerFigure) {
    val connection = new Connection(source, target)
    containerFigure.add(connection)
    connection.setConnectionRouter(connectionRouter)
    connection.setForegroundColor(ColorConstants.black)
    return connection
  }

  def Connection createConnection(CrossPoint source, CrossPoint target, IFigure containerFigure,
      BendConstraint bendConstraint) {
    val connection = new Connection(source, target)
    containerFigure.add(connection)
    connection.setConnectionRouter(connectionRouter)
    connectionRouter.setConstraint(connection, bendConstraint)
    connection.setForegroundColor(ColorConstants.black)
    return connection
  }

  protected def newNode(NodeType type, EObject eObject, String text, Region region) {
    switch (type) {
    case RECTANGLE: new RectangleNode(eObject, text, getFont(), region)
    case ROUNDED: new RoundedNode(eObject, text, getFont(), region)
    case LABEL: new LabelNode(eObject, text, getFont(), region)
    case EMPTY_ALT: new EmptyAltNode(eObject, text, getFont(), region)
    default:
      throw new IllegalArgumentException("Unknown node type " + type)
    }
  }

  protected def getFont() {
    if (font == null) {
      if (Display.current != null) {
        font = Display.current.systemFont
      } else {
        Display.getDefault().syncExec([|
          font = Display.current.systemFont
        ])
      }
    }
    return font;
  }
}