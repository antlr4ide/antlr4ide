package com.github.jknack.antlr4ide.parser

import org.junit.runner.RunWith
import org.eclipse.xtext.junit4.XtextRunner
import org.eclipse.xtext.junit4.InjectWith
import javax.inject.Inject
import org.eclipse.xtext.junit4.util.ParseHelper
import com.github.jknack.antlr4ide.antlr4.Grammar
import org.junit.Test
import static org.junit.Assert.*
import com.github.jknack.antlr4ide.Antlr4TestInjectorProvider
import com.github.jknack.antlr4ide.antlr4.GrammarAction

@RunWith(XtextRunner)
@InjectWith(Antlr4TestInjectorProvider)
class LangActionTest {

  @Inject extension ParseHelper<Grammar>

  @Test
  def void slashInLangAction() {
    val grammar = '''
      grammar g;
      @members {
        a = a / c;
      };
    '''.parse
    val action = grammar.prequels.filter[it instanceof GrammarAction].head as GrammarAction
    assertNotNull(action)
    assertEquals('''
    {
      a = a / c;
    }'''.toString, action.action)
  }
}
