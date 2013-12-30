package com.github.jknack.parser

import org.junit.runner.RunWith
import org.eclipse.xtext.junit4.XtextRunner
import org.eclipse.xtext.junit4.InjectWith
import javax.inject.Inject
import org.eclipse.xtext.junit4.util.ParseHelper
import com.github.jknack.antlr4.Grammar
import org.junit.Test
import org.junit.Assert
import com.github.jknack.Antlr4InjectorProvider
import com.github.jknack.antlr4.ParserRule

@RunWith(typeof(XtextRunner))
@InjectWith(typeof(Antlr4InjectorProvider))
class CharSetTest {

  @Inject extension ParseHelper<Grammar>

  @Test
  def void testParsing() {
    val model = '''
grammar g;
charSet: ["];
'''.parse
    val rule = model.rules.get(0) as ParserRule
    Assert::assertNotNull(rule)
    var alts = rule.body.body.alternatives;
    Assert::assertNotNull(alts)
    var alt = alts.get(0);
    Assert::assertNotNull(alt.body)
    var e = alt.body.elements.get(0);
    Assert::assertNotNull(e)
  }
}
