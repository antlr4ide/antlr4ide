package com.github.jknack.antlr4ide.generator;

import org.eclipse.core.resources.IFile;

public interface CodeGeneratorListener {
	
	public void beforeProcess(IFile file, ToolOptions options);

	public void afterProcess(IFile file, ToolOptions options);
	
}
