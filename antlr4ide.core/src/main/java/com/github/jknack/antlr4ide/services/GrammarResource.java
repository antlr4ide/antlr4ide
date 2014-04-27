package com.github.jknack.antlr4ide.services;

import java.io.File;

import org.eclipse.core.resources.IFile;
import org.eclipse.emf.ecore.resource.Resource;

import com.github.jknack.antlr4ide.lang.Grammar;

/**
 * Get a grammar from a {@link File} or a file from a grammar.
 *
 * @author edgar
 */
public interface GrammarResource {

  Grammar grammarFrom(IFile file);

  Resource resourceFrom(IFile file);

  IFile fileFrom(Resource resource);

  IFile fileFrom(Grammar grammar);

}
