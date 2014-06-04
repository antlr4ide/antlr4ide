package com.github.jknack.antlr4ide.ui.preferences

import org.eclipse.xtext.ui.editor.preferences.IPreferenceStoreInitializer
import org.eclipse.xtext.ui.editor.preferences.IPreferenceStoreAccess
import java.util.List
import com.google.inject.Inject
import com.github.jknack.antlr4ide.ui.folding.Antlr4FoldingPreferenceStoreInitializer

class Antlr4PreferenceStoreInitializer implements IPreferenceStoreInitializer {

  val List<IPreferenceStoreInitializer> initializer

  @Inject
  new(Antlr4FoldingPreferenceStoreInitializer foldingInitializer,
    BuildPreferenceStoreInitializer buildInitializer) {
    this.initializer = newArrayList(foldingInitializer, buildInitializer)
  }

  override initialize(IPreferenceStoreAccess access) {
    this.initializer.forEach[it.initialize(access)]
  }

}
