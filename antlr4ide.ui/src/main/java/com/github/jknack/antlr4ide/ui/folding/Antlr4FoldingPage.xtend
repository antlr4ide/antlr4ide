package com.github.jknack.antlr4ide.ui.folding

import org.eclipse.xtext.ui.editor.preferences.AbstractPreferencePage
import org.eclipse.jface.preference.BooleanFieldEditor
import static com.github.jknack.antlr4ide.ui.folding.Antlr4FoldingPreferenceStoreInitializer.*
import org.eclipse.swt.widgets.Label
import org.eclipse.swt.SWT
import org.eclipse.swt.layout.GridData

class Antlr4FoldingPage extends AbstractPreferencePage {

  override protected createFieldEditors() {
    val parent = fieldEditorParent
    addField(new BooleanFieldEditor(ENABLED, "Enable folding", parent))

    new Label(parent, SWT.NONE) => [
      text = "Initially fold these elements:"
      layoutData = new GridData => [
        it.verticalAlignment = SWT.BOTTOM
        verticalSpan = 6
      ]
    ]

    addField(new BooleanFieldEditor(COMMENTS, "Comments", parent))
    addField(new BooleanFieldEditor(OPTIONS, "Options", parent))
    addField(new BooleanFieldEditor(TOKENS, "Tokens", parent))
    addField(new BooleanFieldEditor(GRAMMAR_ACTION, "Actions", parent))
    addField(new BooleanFieldEditor(RULE, "Rules", parent))
    addField(new BooleanFieldEditor(LEXER_RULE, "Lexer Rules", parent))
    addField(new BooleanFieldEditor(RULE_ACTION, "Rule actions", parent))
  }

}
