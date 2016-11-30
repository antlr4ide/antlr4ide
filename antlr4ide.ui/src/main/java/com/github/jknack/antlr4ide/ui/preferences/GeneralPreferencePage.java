package com.github.jknack.antlr4ide.ui.preferences;

import org.eclipse.core.runtime.preferences.InstanceScope;
import org.eclipse.jface.preference.ComboFieldEditor;
import org.eclipse.jface.preference.FieldEditorPreferencePage;
import org.eclipse.jface.preference.IPreferenceStore;
import org.eclipse.ui.IWorkbench;
import org.eclipse.ui.IWorkbenchPreferencePage;
import org.eclipse.ui.preferences.ScopedPreferenceStore;

import com.github.jknack.antlr4ide.console.LogOptions;
import com.github.jknack.antlr4ide.console.LogLevel;

/**
 * GeneralPreferencePage
 *
 * @see <a href="http://help.eclipse.org/neon/index.jsp?topic=%2Forg.eclipse.platform.doc.user%2Freference%2Fref-72.htm"
 * >Eclipse preferences</a>
 * 
 * @see <a href="http://xtextcasts.org/episodes/21-preference-page">Xtext
 *      preferences</a>
 * @see <a
 *      href="http://stackoverflow.com/questions/7964212/correctly-initializing-and-retrieving-preferences-in-a-xtext-based-eclipse-plugi">Xtext
 *      preferences on stack-overflow</a>
 */
public class GeneralPreferencePage extends FieldEditorPreferencePage implements
		IWorkbenchPreferencePage {
	
	public GeneralPreferencePage() {
		super(FieldEditorPreferencePage.GRID);
	}

	@Override
	public void createFieldEditors() {
		final LogLevel[] logLevels = LogLevel.values();
		final String[][] values = new String[logLevels.length][2];
		for (int i = 0; i < logLevels.length; i++) {
			values[i][0] = logLevels[i].toString();
			values[i][1] = logLevels[i].toString();
		}
		final ComboFieldEditor editor = new ComboFieldEditor(
				LogOptions.KEY, "Log level:", values, 
				this.getFieldEditorParent());
		this.addField(editor);
	}
	
	@Override
	public void init(final IWorkbench workbench) {
		final IPreferenceStore store = new ScopedPreferenceStore(
				InstanceScope.INSTANCE, LogOptions.QUALIFIER);
		store.setDefault(LogOptions.KEY, LogOptions.DEFAULT_LOGLEVEL_AS_STRING);
		setPreferenceStore(store);
	}

}
