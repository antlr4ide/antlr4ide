package com.github.jknack.ui.generator

import com.github.jknack.generator.ToolOptionsProvider
import org.eclipse.core.resources.IProject
import org.eclipse.xtext.builder.EclipseOutputConfigurationProvider
import com.google.inject.Inject
import org.eclipse.xtext.ui.editor.preferences.IPreferenceStoreAccess
import com.github.jknack.generator.ToolOptions
import org.eclipse.jface.preference.IPreferenceStore
import com.github.jknack.generator.BuildConfigurationProvider

class DefaultToolOptionsProvider implements ToolOptionsProvider {

  @Inject
  private EclipseOutputConfigurationProvider configurationProvider

  @Inject
  private IPreferenceStoreAccess preferenceStore

  override options(IProject project) {
    val store = preferenceStore.getContextPreferenceStore(project)

    val output = configurationProvider.getOutputConfigurations(project).last
    val antlrTool = getString(BuildConfigurationProvider.BUILD_ANTLR_TOOL, store, "embedded")
    val listener = getBoolean(BuildConfigurationProvider.BUILD_LISTENER, store, true)
    val visitor = getBoolean(BuildConfigurationProvider.BUILD_VISITOR, store, false)
    val derived = output.setDerivedProperty
    val encoding = getString(BuildConfigurationProvider.BUILD_ENCODING, store, "UTF-8")

    return new ToolOptions(
      antlrTool,
      output.outputDirectory,
      listener,
      visitor,
      derived,
      encoding
    )
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