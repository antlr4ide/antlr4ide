/*******************************************************************************
 * Copyright (c) 2010 itemis AG (http://www.itemis.eu)
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * Contributors:
 *   Jan Koehnlein - Initial API and implementation
 *******************************************************************************/
package com.github.jknack.antlr4ide.ui.railroad.actions

import org.eclipse.draw2d.SWTGraphics
import org.eclipse.jface.action.Action
import org.eclipse.swt.SWT
import org.eclipse.swt.graphics.GC
import org.eclipse.swt.graphics.Image
import org.eclipse.swt.graphics.ImageLoader
import org.eclipse.swt.widgets.Display
import static org.eclipse.ui.ISharedImages.*
import org.eclipse.ui.PlatformUI

import com.github.jknack.antlr4ide.ui.railroad.RailroadView
import com.google.inject.Inject
import com.github.jknack.antlr4ide.ui.railroad.figures.RailroadDiagram
import org.eclipse.swt.widgets.DirectoryDialog
import com.github.jknack.antlr4ide.ui.railroad.figures.RailroadTrack
import org.eclipse.core.runtime.Path
import com.github.jknack.antlr4ide.ui.railroad.figures.AbstractSegmentFigure
import com.github.jknack.antlr4ide.antlr4.Grammar
import com.google.common.io.Files
import com.google.common.base.Charsets
import com.github.jknack.antlr4ide.ui.labeling.Antlr4HoverProvider
import com.github.jknack.antlr4ide.generator.Jobs
import org.eclipse.core.runtime.Status
import com.github.jknack.antlr4ide.console.Console

/**
 * Exports an Xtext grammar railroad diagram to an image file.
 *
 * @author Jan Koehnlein - Initial contribution and API
 * @author edgar - HTML report
 */
class ExportToHtmlAction extends Action {

  @Inject
  RailroadView railroadView

  @Inject
  Console console

  @Inject
  extension Antlr4HoverProvider

  new() {
    id = class.name
    text = "Export to HTML"
    description = "Exports to HTML"
    toolTipText = "Exports to HTML"
    val sharedImages = PlatformUI.workbench.sharedImages
    imageDescriptor = sharedImages.getImageDescriptor(IMG_ETOOL_SAVEAS_EDIT)
    disabledImageDescriptor = sharedImages.getImageDescriptor(IMG_ETOOL_SAVEAS_EDIT_DISABLED)
  }

  override run() {
    val contents = railroadView.contents as RailroadDiagram
    if (contents != null) {
      val grammar = contents.grammar
      val shell = this.railroadView.site.shell
      val dialog = new DirectoryDialog(shell)
      dialog.text = "Output directory"
      val dir = dialog.open
      if (dir == null) {
        return
      }
      val output = Path.fromOSString(dir)
      val jobName = "Exporting " + grammar.name + ".g4 to HTML"

      Jobs.schedule(jobName) [ monitor |
        val tasks = contents.children.size + 1
        monitor.beginTask(jobName, tasks)
        console.info(jobName)
        contents.children.forEach [ it |
          val track = it as RailroadTrack

          val filename = output.append("images").append(track.name + ".png")
          console.info("  " + filename.toOSString)
          monitor.subTask(filename.lastSegment)

          var figure = track.children.last as AbstractSegmentFigure
          val preferredSize = figure.preferredSize
          val image = new Image(Display.^default, preferredSize.width, preferredSize.height)
          val gc = new GC(image)
          val graphics = new SWTGraphics(gc)
          val imageLoader = new ImageLoader
          val offset = figure.bounds.location.negated

          graphics.translate(offset)
          figure.paint(graphics)
          imageLoader.data = #[image.imageData]

          // create /images dir if missing
          filename.toFile.parentFile.mkdirs
          imageLoader.save(filename.toOSString, SWT.IMAGE_PNG)
          image.dispose
          monitor.worked(1)
        ]
        val fname = grammar.name + ".g4.html"
        val fileOutput = output.append(fname).toFile
        monitor.subTask(fname)
        val html = toHTML(grammar)
        Files.write(html, fileOutput, Charsets.UTF_8)
        monitor.worked(1)

        console.info("\nDone: %s", fileOutput)

        return Status.OK_STATUS
      ]
    }
  }

  def private toHTML(Grammar grammar) '''
    <!DOCTYPE html>
    <html>
    <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>«grammar.name».g4</title>
    <style type="text/css">
    body { 
      color: #000;
      font-family: sans-serif;
      font-size: 12px;
      margin: 20px 5px 10px 20px;
    }
    /* resets */
    ul {
      list-style: none;
      padding: 0;
    }
    a {
      text-decoration: none;
    }
    a:hover {
      text-decoration: underline;
    }
    img {
      border: 0;
    }
    .clear {
      clear: both;
    }
    .container {
      position: relative;
    }
    /* Grammar name */
    h1 {
      font-size: 20px;
    }
    /*Grammar documentation*/
    .gdoc {
      margin-left: 20px;
      margin-bottom: 20px;
    }
    #index {
      position: absolute;
      top: 0;
      left: 0;
      width: 200px;
      overflow: auto;
    }
    #index h2 {
      margin: 0;
    }
    #index ol {
      padding-left: 30px;
      list-style-type: square;
      color: #364559;
    }
    #index ol li {
      margin: 2px 0;
    }
    #index ol li a {
      color: #366199;
      font-family: monospace;
    }
    #rules {
      margin-left: 210px;
      padding-left: 20px;
      border-left: 1px solid #AAA;
    }
    .rule {
      margin-bottom: 30px;
    }
    /* Rule name*/
    .rule h3 {
      color: #364559;
      background-color: #DADFE6;
      font-size: 16px;
      font-weight: bold;
      padding: 4px 5px;
      border-bottom: 1px solid #828B99;
    }
    .rule h3 a.topLink {
      font-family: sans-serif;
      font-size: 10px;
      color: #000;
      margin-left: 20px;
    }
    .rule h3, .rule .ebnf div {
      font-family: monospace;
    }
    /* Sections: ebnf, railroad*/
    .doc, .ebnf, .railroad {
      padding-left: 20px;
    }
    .doc h4, .ebnf h4, .railroad h4 {
      font-size: 12px;
      margin: 15px 0 10px -20px;
    }
    .ebnf div {
      background-color: #F7F7F7;
      border-top: 1px solid #E8E8E8;
      border-bottom: 1px solid #E8E8E8;
      padding: 10px 5px;
    }
    .ebnf div .literal {
      color: #0000FF;
    }
    .ebnf div .keyword {
      color: #7F0055;
      font-weight: bold;
    }
    .ebnf div .rule {
      color: #004084;
      font-weight: bold;
    }
    .ebnf div .token {
      font-style:italic;
    }
    .railroad img {
      display: block;
    }
    footer {
      float: right;
    }
    </style>
    </head>
    <body>
    <h1><a href="«grammar.name».g4.html" name="top">«grammar.name»</a></h1>
    <p class="gdoc">«grammar.doc»</p>
    <div class="container">
    <div id="index">
    <h2>Rules</h2>
    <ol>
      «FOR rule : grammar.rules»
        <li><a href="#«rule.name»">«rule.name»</a></li>
      «ENDFOR»
    </ol>
    </div>
    
    <div id="rules">
    <ul>
      «FOR rule : grammar.rules»
        <li class="rule" id="«rule.name»">
        <h3>«rule.name» <a class="topLink" title="Go to top" href="«grammar.name».g4.html">Top</a></h3>
        <div class="doc">
          <p>
            «rule.doc»
          </p>
        </div>
        <div class="ebnf">
        <h4>Text notation:</h4>
        <div>
          <span class="rule">«rule.name»</span> : «rule.definition» ;
        </div>
        </div>
        <div class="railroad">
        <h4>Visual notation:</h4>
        <img border="0" src="images/«rule.name».png" />
        </div>
        </li>
      «ENDFOR»
    </ul>
    </div>
    </div>
    <footer>Generated by: <a href="https://github.com/jknack/antlr4ide">ANTLR 4 IDE</a>. Copyright (c) 2013 <a href="https://twitter.com/edgarespina">Edgar Espina</a></footer>
    </body>
    </html>
  '''

}
