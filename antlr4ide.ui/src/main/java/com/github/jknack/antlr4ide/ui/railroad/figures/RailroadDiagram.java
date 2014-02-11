/*******************************************************************************
 * Copyright (c) 2010 itemis AG (http://www.itemis.eu)
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * Contributors:
 *   Jan Koehnlein - Initial API and implementation
 *******************************************************************************/
package com.github.jknack.antlr4ide.ui.railroad.figures;

import java.util.List;

import org.eclipse.draw2d.ColorConstants;
import org.eclipse.draw2d.LayoutManager;
import org.eclipse.draw2d.ToolbarLayout;

import com.github.jknack.antlr4ide.lang.Grammar;

/**
 * The railroad diagram figure. A railroad diagram consists of {@link RailroadTrack}s
 *
 * @author Jan Koehnlein - Initial contribution and API
 */
public class RailroadDiagram extends AbstractSegmentFigure {

  private Grammar grammar;

  public RailroadDiagram(final Grammar grammar, final List<ISegmentFigure> children) {
    super(grammar);
    this.grammar = grammar;

    setOpaque(true);
    setBackgroundColor(ColorConstants.white);
    for (ISegmentFigure child : children) {
      add(child);
    }
  }

  public Grammar getGrammar() {
    return grammar;
  }

  @Override
  protected LayoutManager createLayoutManager() {
    ToolbarLayout layout = new ToolbarLayout();
    layout.setSpacing(ILayoutConstants.vSpaceBetweenTracks());
    return layout;
  }

  @Override
  protected boolean useLocalCoordinates() {
    return false;
  }

}