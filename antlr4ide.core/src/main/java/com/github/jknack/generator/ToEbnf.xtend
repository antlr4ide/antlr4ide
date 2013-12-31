package com.github.jknack.generator

import com.github.jknack.antlr4.Rule
import com.github.jknack.antlr4.ParserRule
import com.github.jknack.antlr4.RuleAltList
import com.github.jknack.antlr4.Range
import com.github.jknack.antlr4.Terminal
import com.github.jknack.antlr4.RuleRef

class ToEbnf {
  static val String SPACE = " "

  static val String QUOTE = "\'"

  static val String RANGE = ".."

  def static toEbnf(ParserRule rule) {
    val buffer = new StringBuilder

    buffer.append(rule.name + " ::= ")

    val iterator = rule.body.eAllContents
    while (iterator.hasNext) {
      toEbnf(buffer, iterator.next)
    }

    buffer.toString
  }

  def static dispatch void toEbnf(StringBuilder buff, RuleAltList list) {
  }

  def static dispatch void toEbnf(StringBuilder buff, Range range) {
    literal(buff, removeQuotes(range.from), RANGE, removeQuotes(range.to)).append(SPACE)
  }

  def static dispatch void toEbnf(StringBuilder buff, Terminal terminal) {
    val reference = terminal.reference
    if (reference != null) {
      buff.append(reference)
    } else {
      buff.append(terminal.literal)
    }
    buff.append(SPACE)
  }
  
  def static dispatch void toEbnf(StringBuilder buff, RuleRef ruleRef) {
    buff.append(ruleRef.reference.name).append(SPACE)
  }

  private static def literal(StringBuilder buff, String... values) {
    buff.append(QUOTE)
    values.forEach[value |
      buff.append(value)
    ]
    buff.append(QUOTE)
    buff
  }

  private static def removeQuotes(String statement) {
    statement.replace("\'", "")
  }
}
