package com.github.jknack.antlr4ide.ui.parsetree

import org.eclipse.swt.widgets.Composite
import org.eclipse.swt.SWT
import org.eclipse.swt.custom.StyledText
import org.eclipse.draw2d.FigureCanvas
import org.eclipse.swt.custom.SashForm
import org.eclipse.ui.part.ViewPart
import org.eclipse.ui.IViewSite
import org.eclipse.xtext.ui.editor.XtextEditor
import org.eclipse.jface.viewers.ISelectionChangedListener
import org.eclipse.jface.text.ITextSelection
import org.eclipse.xtext.resource.EObjectAtOffsetHelper
import static extension org.eclipse.xtext.EcoreUtil2.*
import com.github.jknack.antlr4ide.lang.Rule
import com.google.inject.Inject
import org.eclipse.jface.viewers.IPostSelectionProvider
import static com.github.jknack.antlr4ide.ui.Widgets.*
import static com.github.jknack.antlr4ide.generator.Jobs.*
import org.eclipse.draw2d.Figure
import org.eclipse.draw2d.StackLayout
import org.eclipse.core.runtime.Status
import com.github.jknack.antlr4ide.lang.Grammar
import com.github.jknack.antlr4ide.ui.views.ColorProvider
import org.eclipse.swt.layout.GridLayout
import org.eclipse.swt.widgets.Label
import org.eclipse.swt.layout.GridData
import org.eclipse.draw2d.ColorConstants
import com.github.jknack.antlr4ide.lang.ParserRule
import org.eclipse.xtext.ui.editor.IXtextEditorAware
import java.util.regex.Pattern
import com.google.common.collect.Lists
import org.eclipse.swt.custom.StyleRange
import com.github.jknack.antlr4ide.ui.highlighting.AntlrHighlightingConfiguration
import org.eclipse.xtext.resource.XtextResource
import org.eclipse.xtext.ui.editor.model.IXtextModelListener
import com.google.inject.name.Named
import org.eclipse.xtext.Constants
import org.eclipse.draw2d.Viewport
import com.github.jknack.antlr4ide.parsetree.ParseTreeGenerator
import org.eclipse.core.runtime.IPath
import com.google.common.io.Files
import java.io.File
import com.google.common.base.Charsets
import static com.google.common.io.CharStreams.*
import java.io.FileReader
import java.io.IOException
import org.eclipse.swt.events.ModifyListener
import java.util.concurrent.atomic.AtomicInteger
import static extension com.github.jknack.antlr4ide.services.ModelExtensions.*
import java.util.regex.Matcher
import org.eclipse.swt.layout.RowLayout
import org.eclipse.swt.widgets.Button

/**
 * Eval and draw parse trees.
 */
class ParseTreeView extends ViewPart implements IXtextEditorAware, IXtextModelListener {

  /** Regex for extracting words from input. */
  static val WORD = Pattern.compile("(\\w(\\w|\\d)*)|(\\S)")

  /** Regex for extracting symbols (+, -, *, etc.) from input. */
  static val SYMBOL = Pattern.compile("[^a-zA-Z\\d\\s:.,;]")

  /** The parse tree generator. */
  @Inject
  ParseTreeGenerator generator

  /** The color provider. */
  @Inject
  ColorProvider colorProvider

  /** The language name. */
  @Inject
  @Named(Constants.LANGUAGE_NAME)
  String language;

  /** The input textbox. */
  StyledText text

  /** The drawing area. */
  FigureCanvas canvas

  /** A reference to the Xtext editor. */
  XtextEditor editor

  /** A reference to the Xtext resource. */
  XtextResource resource

  /** The parse tree synchronizer. Sync view with editor when a view or editor is activated. */
  ParseTreeSynchronizer synchronizer

  /** The rule label. */
  Label ruleLabel

  /** The current selected rule. */
  Rule rule

  /** The root figure. */
  Figure rootFigure

  /** True, if a graphical view is displayed. */
  boolean graph = true

  /** Persist text input into the state location. */
  @Inject
  @Named("stateLocation")
  IPath stateLocation

  /** A lock for drawing the latest parse tree. */
  val lock = new AtomicInteger(0)

  /** React to rule selection from editor. */
  val ISelectionChangedListener ruleSelectionListener = [
    onRuleSelection(it.selection as ITextSelection)
  ]

  /** Update parse tree while typing. */
  val ModifyListener modifyListener = [
    // eval
    eval.cancel
    eval.schedule(500)

    // highlight
    val grammar = rule.getContainerOfType(Grammar)
    highlighter.apply(grammar)
  ]

  /** The eval tree job. */
  val eval = stateJob("building parse tree", lock) [ monitor, state |
    // access to input & grammar from UI Thread
    val text = this.text.text
    if (text.empty || lock.get != state) {
      return Status.CANCEL_STATUS
    }
    // build tree in a none UI Thread
    schedule("building parse tree") [m |
      if (lock.get != state) {
        m.canceled
        return Status.CANCEL_STATUS
      }
      val tree = generator.build(rule, text)
      if (lock.get != state) {
        return Status.CANCEL_STATUS
      }
      // update tree graph from UI Thread
      uijob("drawing parse tree") [
        if (lock.get != state) {
          return Status.CANCEL_STATUS
        }
        rootFigure.removeAll
        val figure = if (graph)
            new ParseTreeDiagram(tree, colorProvider)
          else
            new ParseTreeTextDiagram(tree, colorProvider)
        rootFigure.add(figure)
        return Status.OK_STATUS
      ].schedule
      return Status.OK_STATUS
    ]
    // persist current state
    schedule("dump parse tree input") [
      Files.write(text, dump(rule), Charsets.UTF_8)
      return Status.OK_STATUS
    ]
    return if (lock.get != state) Status.CANCEL_STATUS else Status.OK_STATUS
  ]

  /** Highlight current input. */
  val highlighter = [ Grammar grammar |
    val input = this.text.text
    val literals = grammar.literals
    val styles = Lists.<StyleRange>newArrayList
    val fn = [ Matcher matcher, String colorId, Integer style, Integer len |
      while (matcher.find) {
        val token = matcher.group
        if (token.length > len && literals.contains(token)) {
          styles += new StyleRange => [
            start = matcher.start
            length = token.length
            fontStyle = style
            foreground = colorProvider.get(colorId)
          ]
        }
      }
    ]
    // keywords
    fn.apply(WORD.matcher(input), AntlrHighlightingConfiguration.KEYWORD_ID, SWT.BOLD, 1)

    // symbols
    fn.apply(SYMBOL.matcher(input), AntlrHighlightingConfiguration.STRING_ID, SWT.NONE, 0)

    this.text.styleRanges = styles.sort [ style1, style2 |
      val start = style1.start - style2.start
      return if(start == 0) style1.length - style2.length else start
    ]
  ]

  new() {
    synchronizer = new ParseTreeSynchronizer(this)
  }

  override createPartControl(Composite parent) {
    val sashForm = new SashForm(parent, SWT.HORIZONTAL.bitwiseOr(SWT.BORDER))

    leftPanel(sashForm)

    rightPanel(sashForm)
  }

  override init(IViewSite site) {
    super.init(site)
    site.workbenchWindow.partService.addPartListener(synchronizer)
  }

  override setEditor(XtextEditor editor) {
    uninstall(this.editor)
    install(editor)
  }

  override modelChanged(XtextResource resource) {
    if (language.equals(resource.languageName)) {
      this.resource = resource
    }
  }

  override dispose() {
    uninstall(this.editor)
    site.workbenchWindow.partService.removePartListener(synchronizer)
    this.rootFigure.removeAll
    this.canvas.dispose

    this.rootFigure = null
    this.editor = null
    this.canvas = null
    this.resource = null
    super.dispose
  }

  /**
   * Draw the selected rule into the graph view.
   */
  private def select(Rule rule) {
    if (this.rule == null || this.rule.name != rule.name || this.rule.hash != rule.hash) {
      val grammar = rule.getContainerOfType(Grammar)
      this.rule = rule
      this.ruleLabel.text = grammar.name + "::" + rule.name

      // update text box
      this.text.removeModifyListener(modifyListener)
      this.text.text = try {
        toString(new FileReader(dump(rule)))
      } catch (IOException ex) {
        ""
      }
      highlighter.apply(grammar)
      this.text.addModifyListener(modifyListener)

      // update graph
      rootFigure.removeAll
      if (!this.text.text.empty) {
        eval.schedule
      }
    }
  }

  /**
   * Save rule input into disk.
   */
  private def dump(Rule rule) {
    val dump = new File(stateLocation.append(rule.eResource.URI.path).toFile, rule.name)
    dump.parentFile.mkdirs
    dump
  }

  /**
   * React when a rule has been selected in the editor and/or outline.
   */
  private def onRuleSelection(ITextSelection selection) {
    if (editor != null) {
      val resource = resource()
      val element = new EObjectAtOffsetHelper().resolveElementAt(resource, selection.offset)
      val rule = if(element == null) null else element.getContainerOfType(ParserRule)
      if (rule != null) {
        select(rule)
      }
    }
  }

  /**
   * Bind the Xtext editor.
   */
  private def install(XtextEditor editor) {
    this.editor = editor
    if (editor != null) {
      this.text.enabled = true
      val selectionProvider = editor.selectionProvider
      switch (selectionProvider) {
        IPostSelectionProvider:
          selectionProvider.addPostSelectionChangedListener(ruleSelectionListener)
        default:
          selectionProvider.addSelectionChangedListener(ruleSelectionListener)
      }
      editor.document.addModelListener(this)
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
      editor.document.removeModelListener(this)
    }
    if (!this.text.disposed) {
      this.text.enabled = false
    }
  }

  override setFocus() {
    text.setFocus
  }

  private def leftPanel(Composite parent) {
    val composite = new Composite(parent, SWT.NONE)
    composite.layout = new GridLayout => [
      numColumns = 1
    ]

    this.ruleLabel = new Label(composite, SWT.NONE) => [
      it.text = "<NONE>"
      layoutData = new GridData => [
        horizontalAlignment = SWT.FILL
        grabExcessHorizontalSpace = true
      ]
    ]

    this.text = new StyledText(composite, SWT.BORDER) => [
      enabled = false
      layoutData = new GridData => [
        horizontalAlignment = SWT.FILL
        verticalAlignment = SWT.FILL
        grabExcessHorizontalSpace = true
        grabExcessVerticalSpace = true
      ]
      addModifyListener(modifyListener)
    ]

    return composite
  }

  private def rightPanel(Composite parent) {
    val composite = new Composite(parent, SWT.NONE) => [
      layout = new GridLayout => [
        numColumns = 1
      ]
    ]

    val toolbar = new Composite(composite, SWT.NONE) => [
      layout = new RowLayout
      layoutData = new GridData => [
        horizontalAlignment = SWT.FILL
        grabExcessHorizontalSpace = true
      ]
    ]

    new Button(toolbar, SWT.RADIO) => [
      it.text = "Graph"
      selection = true
      onClick(it) [
        graph = true
        val rule = this.rule
        this.rule = null
        select(rule)
      ]
    ]
    new Button(toolbar, SWT.RADIO) => [
      it.text = "Lisp"
      onClick(it) [
        graph = false
        val rule = this.rule
        this.rule = null
        select(rule)
      ]
    ]

    rootFigure = new Figure => [
      visible = true
      layoutManager = new StackLayout
    ]

    canvas = new FigureCanvas(composite, SWT.V_SCROLL.bitwiseOr(SWT.H_SCROLL)) => [
      viewport = new Viewport(true)
      background = ColorConstants.white
      contents = rootFigure
      layoutData = new GridData => [
        horizontalAlignment = SWT.FILL
        verticalAlignment = SWT.FILL
        grabExcessHorizontalSpace = true
        grabExcessVerticalSpace = true
      ]
    ]

    return composite
  }

}
