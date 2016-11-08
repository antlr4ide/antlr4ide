package com.github.jknack.antlr4ide.ui.launch

import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.variables.IStringVariableManager;
import org.eclipse.core.variables.VariablesPlugin;
import org.eclipse.debug.ui.StringVariableSelectionDialog 
import org.eclipse.swt.events.ModifyEvent;
import org.eclipse.swt.events.ModifyListener;
import org.eclipse.swt.events.SelectionAdapter;
import org.eclipse.swt.events.SelectionEvent;
import org.eclipse.swt.widgets.Shell
import org.eclipse.swt.widgets.Text;

/**
 * Listener for variables button, similar to inner class
 * <code>WidgetListener</code> of class
 * @see org.eclipse.debug.ui.WorkingDirectoryBlock
 */
class VariableButtonListener extends SelectionAdapter implements ModifyListener {
	
	private Text text;
	private ITabUtilities tab;
	
	new(Text text, ITabUtilities tab) {
		this.text = text;
		this.tab = tab;
	}

	override modifyText(ModifyEvent e) {
		tab.scheduleAnUpdateJob();
	}

	override void widgetSelected(SelectionEvent e) {
		val shell = tab.getAShell();
		val dialog = new StringVariableSelectionDialog(shell);
		dialog.open();
		val variableText = dialog.getVariableExpression();
		if (variableText != null) {
			text.insert(variableText);
		}
	}
	
	def static String substituteVariables(String text) throws CoreException {
		if (text.indexOf("${") >= 0) {
	  		val manager = VariablesPlugin.getDefault().getStringVariableManager();
	  		val result = manager.performStringSubstitution(text, false);
	  		return result;
	  	}
	  	else {
	  		return text;
	  	}
	}

}
