package com.github.jknack.ui.preferences

import org.eclipse.xtext.ui.editor.preferences.IPreferenceStoreInitializer
import org.eclipse.xtext.ui.editor.preferences.IPreferenceStoreAccess
import com.github.jknack.generator.ToolOptions

class BuildPreferenceStoreInitializer implements IPreferenceStoreInitializer {

  override initialize(IPreferenceStoreAccess access) {
    val store = access.getWritablePreferenceStore();
    store.setDefault(ToolOptions.BUILD_ANTLR_TOOL, "embedded")
    store.setDefault(ToolOptions.BUILD_LISTENER, true)
    store.setDefault(ToolOptions.BUILD_VISITOR, false)
    store.setDefault(ToolOptions.BUILD_ENCODING, "UTF-8")
  }

}