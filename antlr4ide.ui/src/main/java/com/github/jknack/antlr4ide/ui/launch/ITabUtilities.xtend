package com.github.jknack.antlr4ide.ui.launch

import org.eclipse.swt.widgets.Shell 

/**
 * Utility functions that @see
 * com.github.jknack.antlr4ide.ui.launch.VariableButtonListener
 * will use and that 
 * @see com.github.jknack.antlr4ide.ui.launch.MainTab
 * should implement
 */
interface ITabUtilities {
	
	def Shell getAShell();
	
	def void scheduleAnUpdateJob();
	
}
