package com.github.jknack.antlr4ide.parser

import org.junit.runner.RunWith
import org.eclipse.xtext.junit4.XtextRunner
import org.eclipse.xtext.junit4.InjectWith
import javax.inject.Inject
import com.github.jknack.antlr4ide.parser.Antlr4ParseHelper
import com.github.jknack.antlr4ide.lang.Grammar
import org.junit.Test
import static org.junit.Assert.*
import com.github.jknack.antlr4ide.Antlr4TestInjectorProvider

@RunWith(XtextRunner)
@InjectWith(Antlr4TestInjectorProvider)
class CharSetTest {

  @Inject extension Antlr4ParseHelper<Grammar>

  @Test
  def void doubleQuote() {
    val hasSyntaxErrors = '''
      grammar g;
      CharSet: ["];
    '''.parse.hasSyntaxErrors
    assertFalse(hasSyntaxErrors)
  }
}
