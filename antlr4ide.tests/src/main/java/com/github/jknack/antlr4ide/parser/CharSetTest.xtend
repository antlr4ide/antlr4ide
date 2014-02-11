package com.github.jknack.antlr4ide.parser

import org.junit.runner.RunWith
import org.eclipse.xtext.junit4.XtextRunner
import org.eclipse.xtext.junit4.InjectWith
import javax.inject.Inject
import org.eclipse.xtext.junit4.util.ParseHelper
import com.github.jknack.antlr4ide.lang.Grammar
import org.junit.Test
import static org.junit.Assert.*
import com.github.jknack.antlr4ide.Antlr4TestInjectorProvider
import static extension org.eclipse.xtext.EcoreUtil2.*
import com.github.jknack.antlr4ide.lang.LexerCharSet

@RunWith(XtextRunner)
@InjectWith(Antlr4TestInjectorProvider)
class CharSetTest {

  @Inject extension ParseHelper<Grammar>

  @Test
  def void doubleQuote() {
    val grammar = '''
      grammar g;
      CharSet: ["];
    '''.parse
    val rule = grammar.rules.head
    assertNotNull(rule)
    val charSets = rule.eAllOfType(LexerCharSet)
    assertNotNull(charSets)
    val charSet = charSets.head
    assertNotNull(charSet)
    assertEquals('["]', charSet.body)
  }
}
