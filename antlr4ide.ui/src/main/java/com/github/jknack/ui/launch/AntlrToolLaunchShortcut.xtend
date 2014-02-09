package com.github.jknack.ui.launch

import org.eclipse.debug.ui.ILaunchShortcut
import org.eclipse.jface.viewers.ISelection
import org.eclipse.ui.IEditorPart
import org.eclipse.debug.core.DebugPlugin
import org.eclipse.xtext.ui.editor.XtextEditor
import org.eclipse.core.resources.IFile
import org.eclipse.jface.viewers.IStructuredSelection
import org.eclipse.core.runtime.NullProgressMonitor
import com.github.jknack.generator.LaunchConstants
import com.google.inject.Inject
import com.github.jknack.generator.ToolOptionsProvider
import org.eclipse.core.runtime.IExecutableExtension
import org.eclipse.core.runtime.IConfigurationElement
import org.eclipse.core.runtime.CoreException

class AntlrToolLaunchShortcut implements ILaunchShortcut, IExecutableExtension {

  @Inject
  ToolOptionsProvider optionsProvider

  boolean showDialog

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
    val options = optionsProvider.options(file)
    val args = options.defaults.join(" ")
    val grammar = file.fullPath.toOSString
    val manager = DebugPlugin.^default.launchManager
    val configType = manager.getLaunchConfigurationType(LaunchConstants.LAUNCH_ID)
    var configurations = manager.getLaunchConfigurations(configType)

    val existing = configurations.filter [ launch |
      if (grammar == launch.getAttribute(LaunchConstants.GRAMMAR, "")) {
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
      cgwc.setAttribute(LaunchConstants.GRAMMAR, grammar)
      cgwc.setAttribute(LaunchConstants.ARGUMENTS, args)
      cgwc.setAttribute(LaunchConstants.VM_ARGUMENTS, options.vmArgs)

      val config = cgwc.doSave()
      config.launch(mode, new NullProgressMonitor)
    }
  }

  override setInitializationData(IConfigurationElement config, String propertyName, Object data) throws CoreException {
    showDialog = "showDialog".equals(data)
  }

}
