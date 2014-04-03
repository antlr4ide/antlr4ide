package com.github.jknack.antlr4ide.ui.parsetree

import org.eclipse.ui.IPartListener
import org.eclipse.ui.IWorkbenchPart
import org.eclipse.xtext.ui.editor.XtextEditor
import org.eclipse.xtext.ui.editor.IXtextEditorAware
import static com.google.common.base.Preconditions.*

/**
 * Synchronize a view with an editor.
 */
class ParseTreeSynchronizer implements IPartListener {

  /** The editor callback. */
  IXtextEditorAware callback

  /**
   * @param callback The editor callback. Required.
   */
  new (IXtextEditorAware callback) {
    this.callback = checkNotNull(callback, "An editor callback is required.")
  }

  /**
   * Bind editor if possible.
   */
  override partActivated(IWorkbenchPart part) {
    if (part instanceof XtextEditor) {
      callback.editor = part
    }
  }

  override partBroughtToTop(IWorkbenchPart part) {
  }

  /**
   * Unbind editor if possible.
   */
  override partClosed(IWorkbenchPart part) {
    if (part instanceof XtextEditor) {
      callback.editor = null
    }
  }

  override partDeactivated(IWorkbenchPart part) {
  }

  override partOpened(IWorkbenchPart part) {
  }

}
