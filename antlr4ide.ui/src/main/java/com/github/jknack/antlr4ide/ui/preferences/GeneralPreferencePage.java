package com.github.jknack.antlr4ide.ui.preferences;

import com.github.jknack.antlr4ide.console.ConsoleImpl;

import org.apache.log4j.Level;
import org.eclipse.core.runtime.preferences.InstanceScope;
import org.eclipse.jface.preference.ComboFieldEditor;
import org.eclipse.jface.preference.FieldEditorPreferencePage;
import org.eclipse.jface.preference.IPreferenceStore;
import org.eclipse.ui.IWorkbench;
import org.eclipse.ui.IWorkbenchPreferencePage;
import org.eclipse.ui.preferences.ScopedPreferenceStore;

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
		final Level[] logLevels = new Level[] { Level.OFF, Level.ERROR, 
				Level.WARN, Level.INFO, Level.DEBUG, Level.TRACE };
		final String[][] values = new String[logLevels.length][2];
		for (int i = 0; i < logLevels.length; i++) {
			// constructor of ComboFieldEditor expects a two-dimensional
			// array with label-value pairs.
			values[i][0] = logLevels[i].toString();
			values[i][1] = logLevels[i].toString();
		}
		final ComboFieldEditor editor = new ComboFieldEditor(
				ConsoleImpl.KEY, "Log level:", values, 
				this.getFieldEditorParent());
		this.addField(editor);
	}
	
	@Override
	public void init(final IWorkbench workbench) {
		final IPreferenceStore store = new ScopedPreferenceStore(
				InstanceScope.INSTANCE, ConsoleImpl.QUALIFIER);
		store.setDefault(ConsoleImpl.KEY, ConsoleImpl.DEFAULT_LOGLEVEL_AS_STRING);
		setPreferenceStore(store);
	}

}
