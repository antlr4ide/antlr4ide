package com.github.jknack.ui.folding

import org.eclipse.xtext.ui.editor.folding.DefaultFoldingStructureProvider
import org.eclipse.jface.text.Position
import org.eclipse.jface.text.source.projection.ProjectionAnnotation

/**
 * Customize collapse by default.
 */
class Antlr4FoldingStructureProvider extends DefaultFoldingStructureProvider {

  override protected createProjectionAnnotation(boolean isCollapsed, Position foldedRegion) {
    this.createProjectionAnnotation(isCollapsed, foldedRegion as Antlr4FoldedPosition)
  }

  /**
   * Collapse comment, actions and options by default.
   */
  def private createProjectionAnnotation(boolean isCollapsed, Antlr4FoldedPosition foldedRegion) {
      val collapsed = switch (foldedRegion.regionType) {
        case "options": true
        case "comment": true
        case "grammarAction": true
        case "ruleAction": true
        default: false
      }
      new ProjectionAnnotation(collapsed)
  }

}
