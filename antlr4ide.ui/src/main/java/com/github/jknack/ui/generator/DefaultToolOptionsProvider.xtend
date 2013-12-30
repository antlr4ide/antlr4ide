package com.github.jknack.ui.generator

import com.github.jknack.generator.ToolOptionsProvider
import org.eclipse.xtext.builder.EclipseOutputConfigurationProvider
import com.google.inject.Inject
import org.eclipse.xtext.ui.editor.preferences.IPreferenceStoreAccess
import com.github.jknack.generator.ToolOptions
import org.eclipse.jface.preference.IPreferenceStore
import com.github.jknack.generator.BuildConfigurationProvider
import org.eclipse.core.resources.IFile

class DefaultToolOptionsProvider implements ToolOptionsProvider {

  @Inject
  private EclipseOutputConfigurationProvider configurationProvider

  @Inject
  private IPreferenceStoreAccess preferenceStore

  override options(IFile file) {
    val project = file.project
    val store = preferenceStore.getContextPreferenceStore(project)
    val output = configurationProvider.getOutputConfigurations(project).last

    return new ToolOptions => [
      antlrTool = getString(BuildConfigurationProvider.BUILD_ANTLR_TOOL, store, "embedded")
      outputDirectory = output.outputDirectory
      listener = getBoolean(BuildConfigurationProvider.BUILD_LISTENER, store, true)
      visitor = getBoolean(BuildConfigurationProvider.BUILD_VISITOR, store, false)
      encoding = getString(BuildConfigurationProvider.BUILD_ENCODING, store, "UTF-8")
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