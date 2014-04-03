package com.github.jknack.antlr4ide.ui.parsetree

import org.eclipse.draw2d.Figure
import org.eclipse.draw2d.Graphics
import org.abego.treelayout.TreeForTreeLayout
import org.eclipse.swt.widgets.Display
import org.eclipse.draw2d.FigureUtilities
import com.github.jknack.antlr4ide.parsetree.ParseTreeNode
import com.github.jknack.antlr4ide.ui.views.ColorProvider
import org.eclipse.draw2d.ColorConstants
import org.eclipse.draw2d.geometry.Dimension

/**
 * Draw a parse tree using 'text' representation.
 */
class ParseTreeTextDiagram extends Figure {

  /** The initial X margin. */
  static val X_MARGIN = 10

  /** The initial Y margin. */
  static val Y_MARGIN = 10

  /** The parse tree root. */
  TreeForTreeLayout<ParseTreeNode> tree

  /** The color provider. */
  ColorProvider colorProvider

  /** The width & height provider. */
  ParseTreeNodeExtentProvider nodeExtentProvider

  new(TreeForTreeLayout<ParseTreeNode> tree, ColorProvider colorProvider) {
    this.tree = tree
    this.colorProvider = colorProvider

    // create the NodeExtentProvider for TextInBox nodes
    nodeExtentProvider = new ParseTreeNodeExtentProvider
  }

  /**
   * Paint edges and calculate the graph size.
   */
  private def Dimension paintEdges(Graphics g, ParseTreeNode node, int x, int y, Dimension size) {
    val children = tree.getChildren(node)

    g.foregroundColor = ColorConstants.black
    g.drawString("(", x, y)
    val lpsize = getWidth("(") as int

    g.foregroundColor = colorProvider.bestFor(node.element)
    g.drawString(node.text, x + lpsize / 2, y)

    val startx = (x + nodeExtentProvider.getWidth(node)) as int
    var xx = startx
    var yy = y
    var subtree = false
    for (child : children) {
      if (tree.isLeaf(child)) {
        g.foregroundColor = colorProvider.bestFor(child.element)
        g.drawString(child.text, xx, yy)
        xx = xx + nodeExtentProvider.getWidth(child) as int
      } else {
        subtree = true
        val height = nodeExtentProvider.getHeight(child) as int
        val d = paintEdges(g, child, x + getWidth("  "), yy + height, size)
        yy = d.height
        xx = d.width
      }
    }
    g.foregroundColor = ColorConstants.black
    if (subtree) {
      yy = yy + getHeight(")")
      g.drawString(")", x, yy)
      xx = x + lpsize
    } else {
      g.drawString(")", xx + lpsize / 2, yy)
    }

    if (xx > size.width) {
      size.width = xx
    }
    if (yy > size.height) {
      size.height = yy
    }
    new Dimension(xx, yy)
  }

  override protected paintFigure(Graphics graphics) {
    graphics.translate(X_MARGIN, Y_MARGIN)

    val size = new Dimension
    paintEdges(graphics, tree.root, X_MARGIN, Y_MARGIN, size)

    setSize(size.width + 50, size.height + 50)
    this.preferredSize = getSize()
  }

  private def getHeight(String node) {
    FigureUtilities.getTextExtents(node, Display.^default.systemFont).height + 10
  }

  private def getWidth(String node) {
    FigureUtilities.getTextExtents(node, Display.^default.systemFont).width + 10
  }

}
