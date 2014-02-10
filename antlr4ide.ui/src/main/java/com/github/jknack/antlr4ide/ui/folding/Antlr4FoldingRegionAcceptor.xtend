package com.github.jknack.antlr4ide.ui.folding

import org.eclipse.xtext.ui.editor.folding.DefaultFoldingRegionAcceptor
import org.eclipse.xtext.ui.editor.model.IXtextDocument
import java.util.Collection
import org.eclipse.xtext.ui.editor.folding.FoldedPosition
import org.eclipse.jface.text.IRegion
import org.eclipse.xtext.util.ITextRegion

/**
 * Creates typed folded regions.
 */
class Antlr4FoldingRegionAcceptor extends DefaultFoldingRegionAcceptor {

  /** The folded region type. */
  @Property
  String regionType

  new(IXtextDocument document, Collection<FoldedPosition> result) {
    super(document, result)
  }

  override protected newFoldedPosition(IRegion region, ITextRegion significantRegion) {
    if (region == null)
      return null;

    // adjust some bad offset
    val content = switch (regionType) {
      case "options": -1 -> -1
      case "v4Tokens": -1 -> -1
      case "v3Tokens": -1 -> -1
      default: if (significantRegion == null)
          -1 -> -1
        else
          significantRegion.offset - region.offset -> significantRegion.length
    }

    new Antlr4FoldedPosition(
      regionType,
      region.offset,
      region.length,
      content.key,
      content.value
    )
  }

}
