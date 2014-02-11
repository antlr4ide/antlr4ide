package com.github.jknack.antlr4ide.ui.folding

import org.eclipse.xtext.ui.editor.folding.DefaultFoldingRegionProvider
import org.eclipse.xtext.ui.editor.model.IXtextDocument
import java.util.Collection
import org.eclipse.xtext.ui.editor.folding.FoldedPosition
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.ui.editor.folding.IFoldingRegionAcceptor
import org.eclipse.xtext.util.ITextRegion
import com.github.jknack.antlr4ide.lang.Rule
import com.github.jknack.antlr4ide.lang.PrequelConstruct
import com.github.jknack.antlr4ide.lang.RuleAction

/**
 * Customize default folding by adding a region type to each folded region.
 */
class Antlr4FoldingRegionProvider extends DefaultFoldingRegionProvider {

  override protected computeObjectFolding(EObject eObject, IFoldingRegionAcceptor<ITextRegion> acceptor) {
    (acceptor as Antlr4FoldingRegionAcceptor).regionType = eObject.eClass.name.toFirstLower
    super.computeObjectFolding(eObject, acceptor)
  }

  override protected computeCommentFolding(IXtextDocument xtextDocument, IFoldingRegionAcceptor<ITextRegion> acceptor) {
    (acceptor as Antlr4FoldingRegionAcceptor).regionType = "comment"
    super.computeCommentFolding(xtextDocument, acceptor)
  }

  override protected createAcceptor(IXtextDocument xtextDocument, Collection<FoldedPosition> foldedPositions) {
    new Antlr4FoldingRegionAcceptor(xtextDocument, foldedPositions)
  }

  /**
   * Only prequels and rule support folding.
   */
  override protected isHandled(EObject eObject) {
    val includes = newHashSet(PrequelConstruct, Rule, RuleAction)
    for(include : includes) {
      if (include.isInstance(eObject)) {
        return true
      }
    }
    return false
  }

}
