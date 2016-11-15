package com.github.jknack.antlr4ide.ui.preferences

import org.eclipse.xtext.ui.editor.preferences.IPreferenceStoreInitializer
import org.eclipse.xtext.ui.editor.preferences.IPreferenceStoreAccess
import static com.github.jknack.antlr4ide.generator.ToolOptions.*
import com.github.jknack.antlr4ide.generator.Distributions

class BuildPreferenceStoreInitializer implements IPreferenceStoreInitializer {

  override initialize(IPreferenceStoreAccess access) {
    val store = access.writablePreferenceStore
    val distribution = Distributions.defaultDistribution
    store.setDefault(BUILD_TOOL_PATH, distribution.value)
    store.setDefault(BUILD_ANTLR_TOOLS, Distributions.toString(distribution).toString)
    store.setDefault(BUILD_LISTENER, true)
    store.setDefault(BUILD_VISITOR, false)
    store.setDefault(BUILD_ENCODING, "UTF-8")
    store.setDefault(BUILD_LIBDIRECTORY,"")
  }

}
