package com.github.jknack.ui.folding

import org.eclipse.xtext.ui.editor.folding.DefaultFoldedPosition

/**
 * A folded position with region type information. The region type is usually the eClass of an
 * EObject element.
 */
class Antlr4FoldedPosition extends DefaultFoldedPosition {

  /** The region type. */
  @Property
  String regionType

  new(String regionType, int offset, int length, int contentStart, int contentLength) {
    super(offset, length, contentStart, contentLength)
    this.regionType = regionType
  }

}
