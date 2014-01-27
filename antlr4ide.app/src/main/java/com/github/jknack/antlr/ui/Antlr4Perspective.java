package com.github.jknack.antlr.ui;

import org.eclipse.ui.IFolderLayout;
import org.eclipse.ui.IPageLayout;
import org.eclipse.ui.IPerspectiveFactory;
import org.eclipse.ui.console.IConsoleConstants;

public class Antlr4Perspective implements IPerspectiveFactory {

  @Override
  public void createInitialLayout(final IPageLayout layout) {
    String editorId = layout.getEditorArea();

    IFolderLayout bottom1 = layout.createFolder("bottom1", IPageLayout.BOTTOM, .75f, editorId);
    bottom1.addView(IPageLayout.ID_PROBLEM_VIEW);
    bottom1.addView(IPageLayout.ID_TASK_LIST);
    bottom1.addView(IConsoleConstants.ID_CONSOLE_VIEW);

    IFolderLayout bottom2 = layout.createFolder("bottom2", IPageLayout.RIGHT, .5f, "bottom1");
    bottom2.addView("com.github.jknack.Antlr4.syntaxDiagram");

    IFolderLayout folder = layout.createFolder("left", IPageLayout.LEFT, .22f, editorId);
    folder.addView(IPageLayout.ID_PROJECT_EXPLORER);

    IFolderLayout outline = layout.createFolder("right", IPageLayout.RIGHT, .7f, editorId);
    outline.addView(IPageLayout.ID_OUTLINE);
  }

}
