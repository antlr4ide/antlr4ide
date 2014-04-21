package com.github.jknack.antlr4ide.ui.parsetree

import org.eclipse.draw2d.Figure
import org.eclipse.draw2d.Graphics
import org.abego.treelayout.TreeForTreeLayout
import org.abego.treelayout.TreeLayout
import org.eclipse.swt.widgets.Display
import org.eclipse.draw2d.geometry.Rectangle
import org.eclipse.draw2d.FigureUtilities
import org.abego.treelayout.util.DefaultConfiguration
import org.abego.treelayout.NodeExtentProvider
import com.github.jknack.antlr4ide.parsetree.ParseTreeNode
import com.github.jknack.antlr4ide.ui.views.ColorProvider
import org.eclipse.draw2d.ColorConstants
import java.awt.geom.Rectangle2D
import org.eclipse.draw2d.geometry.Point
import com.github.jknack.antlr4ide.lang.ParserRule

/**
 * Draw a parse tree result using the Abego layout. See https://code.google.com/p/treelayout/
 */
class ParseTreeDiagram extends Figure {

  /** The arc size. */
  static val ARC_SIZE = 10

  /** The initial X margin. */
  static val X_MARGIN = 10

  /** The initial Y margin. */
  static val Y_MARGIN = 10

  /** The tree layout. */
  TreeLayout<ParseTreeNode> layout

  /** The tree root. */
  TreeForTreeLayout<ParseTreeNode> tree

  /** The node width & height provider. */
  ParseTreeNodeExtentProvider nodeExtentProvider

  /** Provide colors. */
  ColorProvider colorProvider

  new(TreeForTreeLayout<ParseTreeNode> tree, ColorProvider colorProvider) {
    this.tree = tree
    this.colorProvider = colorProvider

    // setup the tree layout configuration
    val gapBetweenLevels = 30
    val gapBetweenNodes = 10
    val configuration = new DefaultConfiguration<ParseTreeNode>(gapBetweenLevels, gapBetweenNodes)

    // create the NodeExtentProvider for TextInBox nodes
    nodeExtentProvider = new ParseTreeNodeExtentProvider

    // create the layout
    layout = new TreeLayout<ParseTreeNode>(tree, nodeExtentProvider, configuration)
  }

  /**
   * Paint edges and connections between nodes.
   */
  private def void paintEdges(Graphics g, ParseTreeNode parent) {
    if (!tree.isLeaf(parent)) {
      val height = 30
      val children = tree.getChildren(parent)
      val p1 = center(parent)

      // draw short vertical line
      g.drawLine(p1.x, p1.y, p1.x, p1.y + height)

      if (children.size > 1) {
        val head = children.head
        val last = children.last

        // draw long horizontal line from first to last child
        g.drawLine(center(head).x, p1.y + height, center(last).x, p1.y + height)
      }

      children.forEach [
        val p2 = center(it)
        // draw short vertical line
        g.drawLine(p2.x, p1.y + height, p2.x, p2.y)
        paintEdges(g, it)
      ]
    }
  }

  /**
   * Paint a box for a node. We use rounded box for parser rule.
   */
  private def paintBox(Graphics g, ParseTreeNode node) {
    val bounds = bounds(node)

    // draw the box in the background
    g.backgroundColor = ColorConstants.white
    g.foregroundColor = ColorConstants.black

    switch (node.element) {
      ParserRule: {
        g.fillRoundRectangle(bounds, ARC_SIZE, ARC_SIZE)
        g.drawRoundRectangle(bounds, ARC_SIZE, ARC_SIZE)
      }
      default: {
        g.fillRectangle(bounds)
        g.drawRectangle(bounds)
      }
    }

    val x = bounds.x + ARC_SIZE / 2
    val y = bounds.y + 5
    val fgc = colorProvider.bestFor(node.element)
    g.foregroundColor = if (fgc == null) ColorConstants.black else fgc
    g.drawString(node.text, x, y)
  }

  override protected paintFigure(Graphics graphics) {
    graphics.translate(X_MARGIN, Y_MARGIN)
    paintEdges(graphics, tree.root)

    // paint the boxes
    for (ParseTreeNode node : layout.getNodeBounds().keySet()) {
      paintBox(graphics, node)
    }
    val bounds = bounds(layout.bounds)
    setSize(bounds.width + X_MARGIN + 10, bounds.height + Y_MARGIN + 10)
    preferredSize = size
  }

  /**
   * @return bounds for a node.
   */
  private def bounds(ParseTreeNode node) {
    bounds(layout.nodeBounds.get(node))
  }

  /**
   * @return bounds for a node.
   */
  private def bounds(Rectangle2D box) {
    val bounds = Rectangle.SINGLETON
    bounds.x = box.x as int
    bounds.y = box.y as int
    bounds.width = (box.width as int) - 1
    bounds.height = (box.height as int) - 1
    bounds
  }

  /**
   * @return center for a node.
   */
  private def center(ParseTreeNode node) {
    center(layout.nodeBounds.get(node))
  }

  /**
   * @return center for a node.
   */
  private def center(Rectangle2D box) {
    new Point(box.centerX as int, box.centerY as int)
  }
}

/**
 * Provide width and height for nodes.
 */
class ParseTreeNodeExtentProvider implements NodeExtentProvider<ParseTreeNode> {

  override getHeight(ParseTreeNode node) {
    FigureUtilities.getTextExtents(node.text, Display.^default.systemFont).height + 10
  }

  override getWidth(ParseTreeNode node) {
    FigureUtilities.getTextExtents(node.text, Display.^default.systemFont).width + 10
  }

}
