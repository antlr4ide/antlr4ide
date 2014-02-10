/*******************************************************************************
 * Copyright (c) 2010 itemis AG (http://www.itemis.eu)
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * Contributors:
 *   Jan Koehnlein - Initial API and implementation
 *******************************************************************************/
package com.github.jknack.antlr4ide.ui.railroad;

import org.eclipse.core.runtime.ListenerList;
import org.eclipse.draw2d.IFigure;
import org.eclipse.draw2d.MouseEvent;
import org.eclipse.draw2d.MouseListener;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.jface.viewers.ISelectionChangedListener;
import org.eclipse.jface.viewers.ISelectionProvider;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.jface.viewers.SelectionChangedEvent;
import org.eclipse.jface.viewers.StructuredSelection;

import com.github.jknack.antlr4ide.ui.railroad.figures.IEObjectReferer;
import com.github.jknack.antlr4ide.ui.railroad.figures.ISelectable;
import com.google.inject.Inject;
import com.google.inject.Singleton;

/**
 * Manages selection and navigation in the railroad diagram view.
 *
 * @author Jan Koehnlein
 */
@Singleton
public class RailroadSelectionProvider implements MouseListener, ISelectionProvider {

  public static class DoubleClickEvent extends SelectionChangedEvent {
    private static final long serialVersionUID = 6328075027502345297L;

    public DoubleClickEvent(final ISelectionProvider source, final ISelection selection) {
      super(source, selection);
    }
  }

  @Inject
  private RailroadView view;

  private ListenerList selectionListeners = new ListenerList();

  private IFigure currentSelectedFigure;

  @Override
  public void mousePressed(final MouseEvent me) {
    setSelection(me, false);
  }

  @Override
  public void mouseReleased(final MouseEvent me) {
    // do nothing
  }

  @Override
  public void mouseDoubleClicked(final MouseEvent me) {
    setSelection(me, true);
  }

  protected void setSelection(final MouseEvent me, final boolean isDoubleClick) {
    IFigure selectedFigure = view.findFigureAt(me.getLocation());
    while (selectedFigure != null && !(selectedFigure instanceof IEObjectReferer)) {
      selectedFigure = selectedFigure.getParent();
    }
    if (selectedFigure != null) {
      setSelection(new StructuredSelection(selectedFigure), isDoubleClick);
    }
  }

  @Override
  public void addSelectionChangedListener(final ISelectionChangedListener listener) {
    selectionListeners.add(listener);
  }

  @Override
  public void removeSelectionChangedListener(final ISelectionChangedListener listener) {
    selectionListeners.remove(listener);
  }

  @Override
  public ISelection getSelection() {
    if (currentSelectedFigure != null) {
      return new StructuredSelection(currentSelectedFigure);
    } else {
      return StructuredSelection.EMPTY;
    }
  }

  protected void setSelection(final ISelection selection, final boolean isDoubleClick) {
    IFigure selectedFigure = getSelectedFigure(selection);
    if (currentSelectedFigure instanceof ISelectable) {
      ((ISelectable) currentSelectedFigure).setSelected(false);
    }
    currentSelectedFigure = selectedFigure;
    if (selectedFigure instanceof ISelectable) {
      ((ISelectable) selectedFigure).setSelected(true);
    }
    SelectionChangedEvent event = isDoubleClick ? new DoubleClickEvent(this, selection)
        : new SelectionChangedEvent(this, selection);
    for (Object listener : selectionListeners.getListeners()) {
      ((ISelectionChangedListener) listener).selectionChanged(event);
    }
  }

  @Override
  public void setSelection(final ISelection selection) {
    setSelection(selection, false);
  }

  protected IFigure getSelectedFigure(final ISelection selection) {
    if (selection instanceof IStructuredSelection && ((IStructuredSelection) selection).size() == 1) {
      Object selectedElement = ((IStructuredSelection) selection).getFirstElement();
      if (selectedElement instanceof IFigure) {
        return (IFigure) selectedElement;
      }
    }
    return null;
  }
}