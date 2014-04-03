package com.github.jknack.antlr4ide.ui.views

import com.google.inject.Singleton
import static com.github.jknack.antlr4ide.ui.highlighting.AntlrHighlightingConfiguration.*
import org.eclipse.xtext.ui.editor.preferences.IPreferenceStoreAccess
import javax.inject.Inject
import org.eclipse.jface.resource.JFaceResources
import com.github.jknack.antlr4ide.lang.Terminal
import com.github.jknack.antlr4ide.lang.ParserRule
import com.github.jknack.antlr4ide.lang.LexerRule
import org.eclipse.draw2d.ColorConstants

@Singleton
class ColorProvider {

  @Inject
  IPreferenceStoreAccess preferenceStoreAccess

  def bestFor(Object candidate) {
    val tokenId = switch (candidate) {
      String case candidate == "EOF": KEYWORD_ID
      String case candidate.startsWith("'"): STRING_ID
      String case candidate.startsWith("["): STRING_ID
      String case Character.isUpperCase(candidate.charAt(0)): TOKEN_REF
      String case Character.isLowerCase(candidate.charAt(0)): RULE_REF
      ParserRule: RULE_REF
      LexerRule: TOKEN_REF
      Terminal: STRING_ID
      default:  candidate.toString
    }
    get(tokenId)
  }

  def get(String tokenId) {
    if (tokenId == null) {
      return ColorConstants.black
    } else if (tokenId.startsWith("<")) {
      return ColorConstants.red
    }
    val preferenceStore = preferenceStoreAccess.preferenceStore
    val rgb = preferenceStore.getString(qualifiedId(tokenId))
    JFaceResources.colorRegistry.get(rgb)
  }
}