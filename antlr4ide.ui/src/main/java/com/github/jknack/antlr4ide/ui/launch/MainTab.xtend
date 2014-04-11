package com.github.jknack.antlr4ide.ui.launch

import org.eclipse.debug.ui.AbstractLaunchConfigurationTab
import org.eclipse.swt.widgets.Composite
import org.eclipse.debug.core.ILaunchConfiguration
import org.eclipse.debug.core.ILaunchConfigurationWorkingCopy
import org.eclipse.swt.widgets.Group
import org.eclipse.swt.SWT
import org.eclipse.swt.layout.GridData
import org.eclipse.swt.layout.GridLayout
import org.eclipse.swt.widgets.Text
import org.eclipse.swt.events.ModifyListener
import com.github.jknack.antlr4ide.generator.LaunchConstants
import org.eclipse.core.resources.IFile
import org.eclipse.ui.PlatformUI
import org.eclipse.ui.IWorkbenchPage
import org.eclipse.jface.viewers.IStructuredSelection
import org.eclipse.xtext.ui.editor.XtextEditor
import com.google.inject.Inject
import org.eclipse.xtext.ui.IImageHelper
import org.eclipse.swt.graphics.Font
import com.github.jknack.antlr4ide.generator.ToolOptionsProvider
import org.eclipse.core.resources.IWorkspaceRoot
import org.eclipse.core.runtime.Path
import com.github.jknack.antlr4ide.generator.ToolOptions
import java.util.List
import org.eclipse.swt.widgets.Button
import static extension com.github.jknack.antlr4ide.ui.Widgets.*

class MainTab extends AbstractLaunchConfigurationTab {

  @Inject
  IImageHelper imageHelper

  @Inject
  ToolOptionsProvider optionsProvider

  @Inject
  IWorkspaceRoot workspaceRoot

  Text fGrammarText

  Text fArgsText

  Text fVmArgsText

  ModifyListener modifyListener = [ event |
    updateLaunchConfigurationDialog
  ]

  override createControl(Composite parent) {
    val comp = createComposite(parent, parent.font, 1, 1, GridData.FILL_BOTH)

    createVerticalSpacer(comp, 2)
    fGrammarText = createSection(comp, "Grammar:", SWT.SINGLE.bitwiseOr(SWT.BORDER), 1, true)
    createVerticalSpacer(comp, 8)

    fArgsText = createSection(comp, "Arguments:",
      SWT.MULTI.bitwiseOr(SWT.WRAP).bitwiseOr(SWT.BORDER), 5, false
    )

    fVmArgsText = createSection(comp, "VM Arguments:",
      SWT.MULTI.bitwiseOr(SWT.WRAP).bitwiseOr(SWT.BORDER), 5, false
    )

    setControl(comp)
  }

  protected def createComposite(Composite parent, Font font, int columns, int hspan, int fill) {
    new Composite(parent, SWT.NONE) => [
      it.layout = new GridLayout(columns, false) => [
        verticalSpacing = 0
      ]
      layoutData = new GridData(fill) => [
        horizontalSpan = hspan
        grabExcessHorizontalSpace = true
      ]
      it.font = font
    ]
  }

  override getName() {
    " Tool    "
  }

  override initializeFrom(ILaunchConfiguration config) {
    fGrammarText.setText(config.getAttribute(LaunchConstants.GRAMMAR, ""))

    fArgsText.setText(config.getAttribute(LaunchConstants.ARGUMENTS, ""))

    fVmArgsText.setText(config.getAttribute(LaunchConstants.VM_ARGUMENTS, ""))
  }

  override performApply(ILaunchConfigurationWorkingCopy workingCopy) {
    workingCopy.setAttribute(LaunchConstants.GRAMMAR, fGrammarText.text)

    workingCopy.setAttribute(LaunchConstants.ARGUMENTS, fArgsText.text)

    workingCopy.setAttribute(LaunchConstants.VM_ARGUMENTS, fVmArgsText.text)
  }

  override setDefaults(ILaunchConfigurationWorkingCopy workingCopy) {
    val file = context
    if (file != null) {
      workingCopy.setAttribute(LaunchConstants.GRAMMAR, file.fullPath.toOSString)
      workingCopy.setAttribute(
        LaunchConstants.ARGUMENTS,
        optionsProvider.options(file).defaults.join(" ")
      )
    }
  }

  override isValid(ILaunchConfiguration launchConfig) {
    val List<String> errors = newArrayList()
    errorMessage = null

    val path = fGrammarText.text
    if (path == null || path.empty) {
      errors.add( "Grammar path is empty")
    } else {
      val file = workspaceRoot.getFile(Path.fromOSString(path))
      if (file == null || !file.exists) {
        errors.add( "File not found: " + fGrammarText.text)
      }
      ToolOptions.parse(fArgsText.text) [message|
        errors.add(message)
      ]
    }
    return if (errors.size == 0) {
      true
    } else {
      errorMessage = errors.head
      false
    }
  }

  /**
   * Creates the widgets for specifying a main type.
   *
   * @param parent the parent composite
   */
  protected def createSection(Composite parent, String title, int style, int rows, boolean btn) {
    val font = parent.font
    val group = new Group(parent, SWT.NONE)
    group.text = title
    var gd = new GridData(GridData.FILL_HORIZONTAL)
    group.layoutData = gd
    val layout = new GridLayout
    layout.numColumns = 2
    group.layout = layout
    group.font = font

    val text = new Text(group, style)
    gd = new GridData(GridData.FILL_HORIZONTAL)
    gd.heightHint = rows * text.lineHeight
    text.layoutData = gd
    text.font = font
    text.addModifyListener(modifyListener)

    if (btn) {
      val button = new Button(group, SWT.PUSH)
      gd = new GridData(GridData.END)
      button.layoutData = gd

      button.text = "Browse..."
      button.chooseGrammar(workspaceRoot, [resource|
        fGrammarText.text = resource.fullPath.toOSString
      ])
    }
    return text
  }

  /**
 * Returns the current Java element context in the active workbench page
 * or <code>null</code> if none.
 * 
 * @return current Java element in the active page or <code>null</code>
 */
  private def IFile getContext() {
    val page = activePage
    if (page != null) {
      val selection = page.selection
      if (selection instanceof IStructuredSelection) {
        if (!selection.isEmpty) {
          val obj = selection.firstElement
          if (obj instanceof IFile) {
            return obj
          }
        }
      }
      val part = page.activeEditor
      if (part != null) {
        val editor = part.editorInput.getAdapter(XtextEditor) as XtextEditor
        if (editor != null) {
          return editor.resource as IFile
        }
      }
    }
    return null;
  }

  private def IWorkbenchPage activePage() {
    val workbench = PlatformUI.workbench
    val workbenchWindow = workbench.activeWorkbenchWindow
    if(workbenchWindow != null) workbenchWindow.activePage
  }

  override getImage() {
    return imageHelper.getImage("g.png")
  }

}
