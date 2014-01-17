package com.github.jknack.ui.editor

import org.eclipse.xtext.ui.editor.AbstractDirtyStateAwareEditorCallback
import org.eclipse.xtext.ui.editor.XtextEditor
import org.eclipse.xtext.ui.XtextProjectHelper
import org.eclipse.core.resources.IProject

/**
 * Add Xtext nature without prompt users.
 */
class Antlr4NatureCallback extends AbstractDirtyStateAwareEditorCallback {

  override afterCreatePartControl(XtextEditor editor) {
    super.afterCreatePartControl(editor)
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

}
