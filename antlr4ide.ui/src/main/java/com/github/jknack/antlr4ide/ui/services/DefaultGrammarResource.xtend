package com.github.jknack.antlr4ide.ui.services

import com.github.jknack.antlr4ide.services.GrammarResource
import org.eclipse.core.resources.IFile
import com.google.inject.Singleton
import com.google.inject.Inject
import org.eclipse.xtext.ui.resource.IResourceSetProvider
import org.eclipse.emf.common.util.URI
import com.github.jknack.antlr4ide.lang.Grammar
import org.eclipse.core.resources.IWorkspaceRoot
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.core.runtime.Path

@Singleton
class DefaultGrammarResource implements GrammarResource {

  @Inject
  IResourceSetProvider resourceSetProvider

  @Inject
  IWorkspaceRoot workspaceRoot

  override grammarFrom(IFile file) {
    resourceFrom(file).contents.head as Grammar
  }

  override resourceFrom(IFile file) {
    val resourceSet = resourceSetProvider.get(file.project)
    val uri = URI.createURI(file.fullPath.toPortableString)
    resourceSet.getResource(uri, true)
  }

  override fileFrom(Resource resource) {
    val uri = resource.URI
    workspaceRoot.getFile(new Path(uri.toPlatformString(true)))
  }

  override fileFrom(Grammar grammar) {
    fileFrom(grammar.eResource)
  }

}