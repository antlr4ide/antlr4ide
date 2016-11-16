package com.github.jknack.antlr4ide.ui.wizard;

import org.eclipse.core.runtime.IPath;

public class Antlr4ProjectInfo extends org.eclipse.xtext.ui.wizard.DefaultProjectInfo {
	private IPath locationPath;
	
	public void setLocationPath(IPath locationPath) {
		this.locationPath = locationPath;
	}
	
	public IPath getLocationPath() { return locationPath; }
}
