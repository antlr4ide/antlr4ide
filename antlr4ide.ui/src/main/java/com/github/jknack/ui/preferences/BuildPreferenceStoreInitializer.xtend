package com.github.jknack.ui.preferences

import org.eclipse.xtext.ui.editor.preferences.IPreferenceStoreInitializer
import org.eclipse.xtext.ui.editor.preferences.IPreferenceStoreAccess
import com.github.jknack.generator.BuildConfigurationProvider

class BuildPreferenceStoreInitializer implements IPreferenceStoreInitializer {

  override initialize(IPreferenceStoreAccess access) {
    val store = access.getWritablePreferenceStore();
    store.setDefault(BuildConfigurationProvider.BUILD_ANTLR_TOOL, "embedded")
    store.setDefault(BuildConfigurationProvider.BUILD_LISTENER, true)
    store.setDefault(BuildConfigurationProvider.BUILD_VISITOR, false)
    store.setDefault(BuildConfigurationProvider.BUILD_ENCODING, "UTF-8")
  }

}