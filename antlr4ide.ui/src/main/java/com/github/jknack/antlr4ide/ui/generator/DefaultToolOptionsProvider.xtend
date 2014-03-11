package com.github.jknack.antlr4ide.ui.generator

import com.github.jknack.antlr4ide.generator.ToolOptionsProvider
import org.eclipse.xtext.builder.EclipseOutputConfigurationProvider
import com.google.inject.Inject
import org.eclipse.xtext.ui.editor.preferences.IPreferenceStoreAccess
import com.github.jknack.antlr4ide.generator.ToolOptions
import org.eclipse.jface.preference.IPreferenceStore
import org.eclipse.core.resources.IFile
import com.github.jknack.antlr4ide.generator.Distributions
import org.eclipse.emf.common.util.URI
import org.eclipse.xtext.ui.resource.IResourceSetProvider
import com.github.jknack.antlr4ide.lang.Grammar
import com.github.jknack.antlr4ide.lang.GrammarAction
import java.util.regex.Pattern

class DefaultToolOptionsProvider implements ToolOptionsProvider {

  @Inject
  private EclipseOutputConfigurationProvider configurationProvider

  @Inject
  private IPreferenceStoreAccess preferenceStore

  @Inject
  IResourceSetProvider resourceSetProvider

  static val PKG_NAME = Pattern.compile("package\\s+(([a-zA_Z_][\\.\\w]*))\\s*;")

  override options(IFile file) {
    val project = file.project
    val store = preferenceStore.getContextPreferenceStore(project)
    val output = configurationProvider.getOutputConfigurations(project).last
    val pkgName = try {
        val uri = URI.createFileURI(file.location.toString)
        val resourceSet = resourceSetProvider.get(file.project)
        val resource = resourceSet.getResource(uri, true)
        val grammar = resource.contents.get(0) as Grammar
        val pkgNames = grammar.prequels.filter(GrammarAction).filter[it.name == "header"].map[
          val matcher = PKG_NAME.matcher(it.action)
          return if (matcher.find) matcher.group(1).trim else null
        ]
        if (pkgNames.empty) null else pkgNames.head as String
      } catch (Exception ex) {
        return null
      }

    return new ToolOptions => [
      antlrTool = getString(ToolOptions.BUILD_TOOL_PATH, store,
        Distributions.defaultDistribution.value
      )
      outputDirectory = output.outputDirectory
      packageName = pkgName
      packageInsideAction = pkgName != null
      listener = getBoolean(ToolOptions.BUILD_LISTENER, store, true)
      visitor = getBoolean(ToolOptions.BUILD_VISITOR, store, false)
      encoding = getString(ToolOptions.BUILD_ENCODING, store, "UTF-8")
      vmArgs = getString(ToolOptions.VM_ARGS, store, "")
      derived = output.setDerivedProperty
    ]
  }

  private def getBoolean(String key, IPreferenceStore store, Boolean defaultValue) {
    if (store.contains(key)) {
      store.getBoolean(key)
    } else {
      defaultValue
    }
  }

  private def getString(String key, IPreferenceStore store, String defaultValue) {
    if (store.contains(key)) {
      store.getString(key)
    } else {
      defaultValue
    }
  }
}