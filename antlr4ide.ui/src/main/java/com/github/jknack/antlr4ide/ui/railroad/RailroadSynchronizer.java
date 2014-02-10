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

import org.eclipse.draw2d.IFigure;
import org.eclipse.emf.common.util.EList;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.ui.IPartListener;
import org.eclipse.ui.IWorkbenchPart;
import org.eclipse.ui.IWorkbenchPartSite;
import org.eclipse.xtext.Constants;
import org.eclipse.xtext.resource.XtextResource;
import org.eclipse.xtext.ui.editor.XtextEditor;
import org.eclipse.xtext.ui.editor.model.IXtextDocument;
import org.eclipse.xtext.ui.editor.model.IXtextModelListener;
import org.eclipse.xtext.util.concurrent.IUnitOfWork;

import com.github.jknack.antlr4ide.ui.railroad.actions.RailroadSelectionLinker;
import com.github.jknack.antlr4ide.ui.railroad.trafo.Antlr4RailroadTransformer;
import com.google.inject.Inject;
import com.google.inject.Singleton;
import com.google.inject.name.Named;

/**
 * Synchronizes the railroad diagram view with the active editor.
 *
 * @author Jan Koehnlein - Initial contribution and API
 */
@Singleton
public class RailroadSynchronizer implements IPartListener, IXtextModelListener {

  @Inject
  private RailroadView view;

  @Inject
  private Antlr4RailroadTransformer transformer;

  @Inject
  private RailroadSelectionLinker selectionLinker;

  private IXtextDocument lastActiveDocument;

  @Inject
  @Named(Constants.LANGUAGE_NAME)
  private String language;

  public void start(final IWorkbenchPartSite site) {
    partActivated(site.getPage().getActiveEditor());
    site.getWorkbenchWindow().getPartService().addPartListener(this);
  }

  public void stop(final IWorkbenchPartSite site) {
    site.getWorkbenchWindow().getPartService().removePartListener(this);
    lastActiveDocument = null;
  }

  @Override
  public void partActivated(final IWorkbenchPart part) {
    if (part instanceof XtextEditor) {
      boolean draw = false;
      XtextEditor xtextEditor = (XtextEditor) part;
      if (language.equals(xtextEditor.getLanguageName())) {
        IXtextDocument xtextDocument = xtextEditor.getDocument();
        draw = xtextDocument != lastActiveDocument;
        if (draw) {
          drawDiagram(xtextEditor, xtextDocument);
        }
      }
      if (!draw) {
        if (lastActiveDocument != null) {
          lastActiveDocument.removeModelListener(this);
          lastActiveDocument = null;
        }
        view.clearView();
      }
    }
  }

  private void drawDiagram(final XtextEditor xtextEditor, final IXtextDocument xtextDocument) {
    selectionLinker.setXtextEditor(xtextEditor);
    IFigure contents = xtextDocument
        .readOnly(new IUnitOfWork<IFigure, XtextResource>() {
          @Override
          public IFigure exec(final XtextResource resource) throws Exception {
            return createFigure(resource);
          }
        });
    if (contents != null) {
      view.setContents(contents);
      if (lastActiveDocument != null) {
        lastActiveDocument.removeModelListener(this);
      }
      lastActiveDocument = xtextDocument;
      lastActiveDocument.addModelListener(this);
    }
  }

  private IFigure createFigure(final XtextResource state) {
    EList<EObject> contents = state.getContents();
    if (!contents.isEmpty()) {
      EObject rootObject = contents.get(0);
      return transformer.transform(rootObject);
    }
    return null;
  }

  @Override
  public void partBroughtToTop(final IWorkbenchPart part) {
  }

  @Override
  public void partClosed(final IWorkbenchPart part) {
  }

  @Override
  public void partDeactivated(final IWorkbenchPart part) {
    if (part instanceof XtextEditor) {
      view.clearView();
      if (lastActiveDocument != null) {
        lastActiveDocument.removeModelListener(this);
      }
      lastActiveDocument = null;
    }
  }

  @Override
  public void partOpened(final IWorkbenchPart part) {
  }

  @Override
  public void modelChanged(final XtextResource resource) {
    if (language.equals(resource.getLanguageName())) {
      view.setContents(createFigure(resource));
    }
  }

}
