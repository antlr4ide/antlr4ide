package com.github.jknack.antlr4ide.ui.highlighting

import com.google.inject.Singleton
import com.google.inject.Inject
import org.eclipse.xtext.ui.IImageHelper.IImageDescriptorHelper
import org.eclipse.xtext.ui.editor.XtextEditor
import org.eclipse.ui.texteditor.ITextEditorActionConstants
import org.eclipse.xtext.ui.editor.actions.IActionContributor

@Singleton
class ShowWhitespaceCharactersActionContributor implements IActionContributor {

  @Inject
  private IImageDescriptorHelper imageHelper;

  override contributeActions(XtextEditor editor) {
    val action = editor.getAction(ITextEditorActionConstants.SHOW_WHITESPACE_CHARACTERS)
    action.imageDescriptor = imageHelper.getImageDescriptor("showWhitespace.gif")
    action.disabledImageDescriptor = imageHelper.getImageDescriptor("showWhitespace.disabled.gif")

    val toolBarManager = editor.editorSite.actionBars.toolBarManager
    toolBarManager.remove(ITextEditorActionConstants.SHOW_WHITESPACE_CHARACTERS)
    toolBarManager.add(action)
  }

  override void editorDisposed(XtextEditor editor) {
  }

}
