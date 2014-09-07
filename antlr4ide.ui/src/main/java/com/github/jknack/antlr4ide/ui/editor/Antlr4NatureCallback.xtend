package com.github.jknack.antlr4ide.ui.editor

import org.eclipse.xtext.ui.editor.XtextEditor
import org.eclipse.xtext.ui.XtextProjectHelper
import org.eclipse.core.resources.IProject
import org.eclipse.xtext.ui.editor.IXtextEditorCallback

/**
 * Add Xtext nature without prompt users.
 */
class Antlr4NatureCallback implements IXtextEditorCallback {

  override afterCreatePartControl(XtextEditor editor) {
    val resource = editor.resource
    if (resource != null && !XtextProjectHelper.hasNature(resource.project) && resource.project.accessible &&
      !resource.project.hidden) {
      toggleNature(resource.project)
    }
  }

  /**
   * Add Xtext nature to project.
   */
  def private toggleNature(IProject project) {
    val description = project.description

    // Add the nature
    val newNatures = newArrayList(description.natureIds)
    newNatures += XtextProjectHelper.NATURE_ID
    description.natureIds = newNatures
    project.setDescription(description, null)
  }
  
  override afterSave(XtextEditor editor) {
  }
  
  override afterSetInput(XtextEditor xtextEditor) {
  }
  
  override beforeDispose(XtextEditor editor) {
  }
  
  override beforeSetInput(XtextEditor xtextEditor) {
  }
  
  override onValidateEditorInputState(XtextEditor editor) {
    return true;
  }

}
