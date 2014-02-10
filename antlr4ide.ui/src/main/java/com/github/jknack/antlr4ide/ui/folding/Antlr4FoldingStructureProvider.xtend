package com.github.jknack.antlr4ide.ui.folding

import org.eclipse.xtext.ui.editor.folding.DefaultFoldingStructureProvider
import org.eclipse.jface.text.Position
import org.eclipse.jface.text.source.projection.ProjectionAnnotation

/**
 * Customize collapse by default.
 */
class Antlr4FoldingStructureProvider extends DefaultFoldingStructureProvider {

  boolean init

  override initialize() {
    try {
      init = true
      super.initialize()
    } finally {
      init = false
    }
  }

  override protected createProjectionAnnotation(boolean isCollapsed, Position foldedRegion) {
    this.createProjectionAnnotation(isCollapsed, foldedRegion as Antlr4FoldedPosition)
  }

  /**
   * Collapse comment, actions and options by default.
   */
  def private createProjectionAnnotation(boolean isCollapsed, Antlr4FoldedPosition foldedRegion) {
    val collapsed = switch (foldedRegion.regionType) {
      case "options": true && init
      case "comment": true && init
      case "grammarAction": true && init
      case "ruleAction": true && init
      default: isCollapsed
    }
    new ProjectionAnnotation(collapsed)
  }

}
