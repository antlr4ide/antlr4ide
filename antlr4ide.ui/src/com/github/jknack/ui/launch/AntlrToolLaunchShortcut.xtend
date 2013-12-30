package com.github.jknack.ui.launch

import org.eclipse.debug.ui.ILaunchShortcut
import org.eclipse.jface.viewers.ISelection
import org.eclipse.ui.IEditorPart
import org.eclipse.debug.core.DebugPlugin
import org.eclipse.xtext.ui.editor.XtextEditor
import org.eclipse.core.resources.IFile
import org.eclipse.jface.viewers.IStructuredSelection
import org.eclipse.core.runtime.NullProgressMonitor
import com.github.jknack.launch.AntlrToolLaunchConstants
import com.google.inject.Inject
import com.github.jknack.generator.ToolOptionsProvider

class AntlrToolLaunchShortcut implements ILaunchShortcut {

  @Inject
  ToolOptionsProvider optionsProvider

  override launch(ISelection selection, String mode) {
    if (selection instanceof IStructuredSelection) {
      val file = selection.firstElement
      if (file instanceof IFile) {
        launchConfiguration(file, mode)
      }
    }
  }

  override launch(IEditorPart editorPart, String mode) {
    val editor = editorPart.getAdapter(XtextEditor) as XtextEditor
    val file = editor.resource as IFile

    launchConfiguration(file, mode)
  }

  private def launchConfiguration(IFile file, String mode) {
    val args = optionsProvider.options(file).defaults.join(" ")
    val grammar = file.fullPath.toOSString
    val manager = DebugPlugin.^default.launchManager
    val configType = manager.getLaunchConfigurationType(AntlrToolLaunchConstants.ID)
    var configurations = manager.getLaunchConfigurations(configType)

    val existing = configurations.filter [ launch |
      if (grammar == launch.getAttribute(AntlrToolLaunchConstants.GRAMMAR, "")) {
        return true
      }
      return false
    ]
    if (existing.size > 0) {
      // launch existing
      existing.head.launch(mode, new NullProgressMonitor)
    } else {
      val names = configurations.filter [ launch |
        if (launch.name == file.name) {
          return true
        }
        return false
      ]
      val name = if(names.size == 0) file.name else file.name + " (" + names.size + ")"
      val cgwc = configType.newInstance(null, name)
      cgwc.setAttribute(AntlrToolLaunchConstants.GRAMMAR, grammar)
      cgwc.setAttribute(AntlrToolLaunchConstants.ARGUMENTS, args)

      val config = cgwc.doSave()
      config.launch(mode, new NullProgressMonitor)
    }
  }

}
