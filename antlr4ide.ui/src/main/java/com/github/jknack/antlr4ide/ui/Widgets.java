package com.github.jknack.antlr4ide.ui;

import org.eclipse.core.resources.IContainer;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IResource;
import org.eclipse.swt.events.SelectionAdapter;
import org.eclipse.swt.events.SelectionEvent;
import org.eclipse.swt.events.SelectionListener;
import org.eclipse.swt.widgets.Button;
import org.eclipse.swt.widgets.Table;
import org.eclipse.ui.dialogs.FilteredResourcesSelectionDialog;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1;

public class Widgets {

  public static SelectionListener onClick(final Table table,
      final Procedure1<SelectionEvent> listener) {
    return new SelectionListener() {
      @Override
      public void widgetSelected(final SelectionEvent event) {
        listener.apply(event);
      }

      @Override
      public void widgetDefaultSelected(final SelectionEvent event) {
        widgetSelected(event);
      }
    };
  }

  public static void onClick(final Button button,
      final Procedure1<SelectionEvent> listener) {
    button.addSelectionListener(new SelectionAdapter() {
      @Override
      public void widgetSelected(final SelectionEvent event) {
        listener.apply(event);
      }
    });
  }

  public static void chooseGrammar(final Button button, final IContainer root,
      final Procedure1<IFile> listener) {
    button.addSelectionListener(new SelectionListener() {

      @Override
      public void widgetSelected(final SelectionEvent event) {
        FilteredResourcesSelectionDialog dialog = new FilteredResourcesSelectionDialog(
            button.getShell(), false, root, IResource.FILE);
        dialog.setInitialPattern("*.g4");
        if (dialog.open() == FilteredResourcesSelectionDialog.OK) {
          listener.apply((IFile) dialog.getResult()[0]);
        }
      }

      @Override
      public void widgetDefaultSelected(final SelectionEvent event) {
      }
    });
  }

}
