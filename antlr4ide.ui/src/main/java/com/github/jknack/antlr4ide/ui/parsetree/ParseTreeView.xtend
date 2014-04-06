package com.github.jknack.antlr4ide.ui.parsetree

import org.eclipse.swt.widgets.Composite
import org.eclipse.swt.SWT
import org.eclipse.swt.custom.StyledText
import org.eclipse.swt.custom.SashForm
import static extension org.eclipse.xtext.EcoreUtil2.*
import com.github.jknack.antlr4ide.lang.Rule
import com.google.inject.Inject
import static com.github.jknack.antlr4ide.ui.Widgets.*
import static com.github.jknack.antlr4ide.generator.Jobs.*
import org.eclipse.core.runtime.Status
import com.github.jknack.antlr4ide.lang.Grammar
import org.eclipse.swt.layout.GridLayout
import org.eclipse.swt.widgets.Label
import org.eclipse.swt.layout.GridData
import java.util.regex.Pattern
import com.google.common.collect.Lists
import org.eclipse.swt.custom.StyleRange
import com.github.jknack.antlr4ide.ui.highlighting.AntlrHighlightingConfiguration
import com.google.inject.name.Named
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
import com.github.jknack.antlr4ide.ui.views.GraphView
import com.github.jknack.antlr4ide.lang.ParserRule

/**
 * Eval and draw parse trees.
 */
class ParseTreeView extends GraphView {

  /** Regex for extracting words from input. */
  static val WORD = Pattern.compile("(\\w(\\w|\\d)*)|(\\S)")

  /** Regex for extracting symbols (+, -, *, etc.) from input. */
  static val SYMBOL = Pattern.compile("[^a-zA-Z\\d\\s:.,;]")

  /** The parse tree generator. */
  @Inject
  ParseTreeGenerator generator

  /** The input textbox. */
  StyledText text

  /** The rule label. */
  Label ruleLabel

  /** Persist text input into the state location. */
  @Inject
  @Named("stateLocation")
  IPath stateLocation

  /** A lock for drawing the latest parse tree. */
  val lock = new AtomicInteger(0)

  /** Update parse tree while typing. */
  val ModifyListener modifyListener = [
    // eval
    eval.cancel
    eval.schedule(500)
    // highlight
    val grammar = selectedRule.getContainerOfType(Grammar)
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
    schedule("building parse tree") [ m |
      if (lock.get != state) {
        m.canceled
        return Status.CANCEL_STATUS
      }
      val tree = generator.build(selectedRule, text)
      if (lock.get != state) {
        return Status.CANCEL_STATUS
      }
      // update tree graph from UI Thread
      uijob("drawing parse tree") [
        if (lock.get != state && canvas != null) {
          return Status.CANCEL_STATUS
        }
        // clear canvas
        clearCanvas

        rootFigure.add(new ParseTreeDiagram(tree, colorProvider))

        return Status.OK_STATUS
      ].schedule
      return Status.OK_STATUS
    ]
    // persist current state
    schedule("dump parse tree input") [
      Files.write(text, dump(selectedRule), Charsets.UTF_8)
      return Status.OK_STATUS
    ]
    return if(lock.get != state) Status.CANCEL_STATUS else Status.OK_STATUS
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

  override createPartControl(Composite parent) {
    val sashForm = new SashForm(parent, SWT.HORIZONTAL.bitwiseOr(SWT.BORDER))

    leftPanel(sashForm)

    rightPanel(sashForm)
  }

  override protected ruleType() {
    ParserRule
  }

  /**
   * Draw the selected rule into the graph view.
   */
  override onSelection(Rule rule) {
    this.text.enabled = true
    val grammar = rule.getContainerOfType(Grammar)
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
    clearCanvas
    if (!this.text.text.empty) {
      eval.schedule
    }
  }

  override protected onNoSelection() {
    this.text.enabled = false
  }

  /**
   * Save rule input into disk.
   */
  private def dump(Rule rule) {
    val dump = new File(stateLocation.append(rule.eResource.URI.path).toFile, rule.name)
    dump.parentFile.mkdirs
    dump
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

    canvas = newCanvas(composite)

    return composite
  }

}
