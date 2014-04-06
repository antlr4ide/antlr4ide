package com.github.jknack.antlr4ide.ui.views

import org.eclipse.ui.part.ViewPart
import org.eclipse.xtext.ui.editor.model.IXtextModelListener
import org.eclipse.draw2d.FigureCanvas
import org.eclipse.xtext.ui.editor.XtextEditor
import org.eclipse.xtext.resource.XtextResource
import org.eclipse.ui.IViewSite
import org.eclipse.jface.text.ITextSelection
import org.eclipse.xtext.resource.EObjectAtOffsetHelper
import com.github.jknack.antlr4ide.lang.Rule
import org.eclipse.jface.viewers.IPostSelectionProvider
import org.eclipse.jface.viewers.ISelectionChangedListener
import com.google.inject.Inject
import com.google.inject.name.Named
import org.eclipse.xtext.Constants
import static extension org.eclipse.xtext.EcoreUtil2.*
import static extension com.github.jknack.antlr4ide.services.ModelExtensions.*
import org.eclipse.draw2d.Figure
import org.eclipse.swt.widgets.Composite
import org.eclipse.swt.SWT
import org.eclipse.draw2d.Viewport
import org.eclipse.draw2d.ColorConstants
import org.eclipse.swt.layout.GridData
import org.eclipse.ui.IPartListener
import org.eclipse.ui.IWorkbenchPart
import org.eclipse.draw2d.StackLayout

/**
 * A graph view that synchronize editor and/or outline selection to a rule.
 */
abstract class GraphView extends ViewPart implements IXtextModelListener, IPartListener {

  /** The language name. */
  @Inject
  @Named(Constants.LANGUAGE_NAME)
  String language;

  /** The color provider. */
  @Inject
  protected ColorProvider colorProvider

  /** The drawing area. */
  protected FigureCanvas canvas

  /** A reference to the Xtext editor. */
  protected XtextEditor editor

  /** A reference to the Xtext resource. */
  protected XtextResource resource

  /** The current selected rule. */
  private Rule rule

  /** Find an object at current offset. */
  val EObjectAtOffsetHelper objectAtOffsetHelper

  /** React to rule selection from editor. */
  val ISelectionChangedListener ruleSelectionListener = [
    onRuleSelection(it.selection as ITextSelection)
  ]

  new() {
    objectAtOffsetHelper = new EObjectAtOffsetHelper
  }

  /**
   * A rule has been selected from editor. Update view the reflect current rule.
   */
  protected abstract def void onSelection(Rule rule)

  /**
   * A selection was fired but no rule was selected.
   */
  protected abstract def void onNoSelection()

  /**
   * @return The selected rule or null.
   */
  protected def selectedRule() {
    rule
  }

  override final init(IViewSite site) {
    super.init(site)
    site.workbenchWindow.partService.addPartListener(this)
  }

  override final modelChanged(XtextResource resource) {
    if (language.equals(resource.languageName)) {
      this.resource = resource
    }
  }

  override final dispose() {
    uninstall(this.editor)
    site.workbenchWindow.partService.removePartListener(this)
    clearCanvas
    this.canvas.dispose

    onDispose

    this.editor = null
    this.canvas = null
    this.resource = null
    super.dispose
  }

  /**
   * Dispose callback.
   */
  protected def onDispose() {
  }


  /**
   * Clear canvas.
   */
  protected def clearCanvas() {
    val figure = canvas.contents as Figure
    figure.removeAll
  }

  /**
   * Clear canvas.
   */
  protected def rootFigure() {
    canvas.contents
  }

  /**
   * Choose what type of rule we want.
   */
  protected def Class<? extends Rule> ruleType() {
    return Rule
  }

  /**
   * Creates a new canvas area.
   */
  protected def newCanvas(Composite composite) {
    new FigureCanvas(composite, SWT.V_SCROLL.bitwiseOr(SWT.H_SCROLL)) => [
      viewport = new Viewport(true)
      background = ColorConstants.white
      contents = new Figure => [
        visible = true
        layoutManager = new StackLayout
      ]
      layoutData = new GridData => [
        horizontalAlignment = SWT.FILL
        verticalAlignment = SWT.FILL
        grabExcessHorizontalSpace = true
        grabExcessVerticalSpace = true
      ]
    ]
  }

  /**
   * Bind the Xtext editor.
   */
  private def install(XtextEditor editor) {
    if (this.editor != editor) {
      uninstall(this.editor)
    }
    this.editor = editor
    val selectionProvider = editor.selectionProvider
    switch (selectionProvider) {
      IPostSelectionProvider:
        selectionProvider.addPostSelectionChangedListener(ruleSelectionListener)
      default:
        selectionProvider.addSelectionChangedListener(ruleSelectionListener)
    }
    editor.document.addModelListener(this)
  }

  /**
   * Un-bind the Xtext editor.
   */
  private def uninstall(XtextEditor editor) {
    if (editor != null) {
      val selectionProvider = editor.selectionProvider
      if (selectionProvider != null) {
        switch (selectionProvider) {
          IPostSelectionProvider:
            selectionProvider.removePostSelectionChangedListener(ruleSelectionListener)
          default:
            selectionProvider.removeSelectionChangedListener(ruleSelectionListener)
        }
      }
      editor.document?.removeModelListener(this)
    }
  }

  /**
   * React when a rule has been selected in the editor and/or outline.
   */
  private def onRuleSelection(ITextSelection selection) {
    val resource = resource()
    val element = new EObjectAtOffsetHelper().resolveElementAt(resource, selection.offset)
    val rule = if(element == null) null else element.getContainerOfType(ruleType)
    if (rule != null) {
      select(rule)
    } else {
      onNoSelection
    }
  }

  /**
   * A rule has been selected from editor. Update view the reflect current rule.
   */
  private def select(Rule rule) {
    if (this.rule == null || this.rule.name != rule.name || this.rule.hash != rule.hash) {
      this.rule = rule
      onSelection(rule)
    }
  }

  /**
   * Sync access to the underlying resource.
   */
  private def resource() {
    if (resource == null) {
      resource = editor.document.readOnly [
        it
      ]
    }
    return resource
  }

  /**
   * Bind editor if possible.
   */
  override partActivated(IWorkbenchPart part) {
    if (part instanceof XtextEditor) {
      // reset resource
      this.resource = null

      install(part)
    }
  }

  /**
   * Unbind editor.
   */
  override partClosed(IWorkbenchPart part) {
    if (part instanceof XtextEditor) {
      uninstall(part)
    }
  }

  override partBroughtToTop(IWorkbenchPart part) {
  }

  override partDeactivated(IWorkbenchPart part) {
  }

  override partOpened(IWorkbenchPart part) {
  }

}
