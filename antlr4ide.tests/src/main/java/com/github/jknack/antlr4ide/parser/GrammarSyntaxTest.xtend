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
import com.github.jknack.antlr4ide.antlr4.GrammarType
import com.github.jknack.antlr4ide.antlr4.Options
import com.github.jknack.antlr4ide.antlr4.QualifiedOption

@RunWith(XtextRunner)
@InjectWith(Antlr4TestInjectorProvider)
class GrammarSyntaxTest {

  @Inject extension ParseHelper<Grammar>

  @Test
  def void defGrammar() {
    val grammar = '''
      grammar G;
      
      rule:;
    '''.parse
    assertNotNull(grammar)
    assertEquals("G", grammar.name)
    assertEquals(GrammarType.DEFAULT, grammar.type)
  }

  @Test
  def void lexerGrammar() {
    val grammar = '''
      lexer grammar L;
      
      rule:;
    '''.parse
    assertNotNull(grammar)
    assertEquals("L", grammar.name)
    assertEquals(GrammarType.LEXER, grammar.type)
  }

  @Test
  def void parserGrammar() {
    val grammar = '''
      parser grammar P;
      
      rule:;
    '''.parse
    assertNotNull(grammar)
    assertEquals("P", grammar.name)
    assertEquals(GrammarType.PARSER, grammar.type)
  }

  @Test
  def void treeGrammar() {
    val grammar = '''
      tree grammar T;
      
      rule:;
    '''.parse
    assertNotNull(grammar)
    assertEquals("T", grammar.name)
    assertEquals(GrammarType.TREE, grammar.type)
  }

  @Test
  def void grammarEmptyOptions() {
    val grammar = '''
      grammar G;
      
      options {}
      
      rule:;
    '''.parse
    assertNotNull(grammar)
    val options = grammar.prequels.findFirst[it instanceof Options]
    assertNotNull(options)
  }
  
  @Test
  def void grammarOptions() {
    val grammar = '''
      grammar G;
      
      options {
        language = Java;
        superClass = com.my.class.Parser;
      }
      
      rule:;
    '''.parse
    assertNotNull(grammar)
    val options = grammar.prequels.findFirst[it instanceof Options] as Options
    assertNotNull(options)
    assertQualifiedOption(options, "language", "Java")
    assertQualifiedOption(options, "superClass", "com.my.class.Parser")
  }

  def assertQualifiedOption(Options options, String name, String value) {
    val language = options.options.findFirst[it.name == name]
    assertNotNull(language)
    assertNotNull(language.value)
    assertTrue(language.value instanceof QualifiedOption)
    assertEquals(value, (language.value as QualifiedOption).value.name.join("."))
  }
}
