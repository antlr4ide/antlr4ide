package com.github.jknack.validation

import org.eclipse.xtext.validation.Check
import com.github.jknack.antlr4.Grammar

/**
 * Custom validation rules. 
 *
 * see http://www.eclipse.org/Xtext/documentation.html#validation
 */
class Antlr4Validator extends AbstractAntlr4Validator {

  @Check
  def checkGrammarName(Grammar grammar) {
    val resource = grammar.eResource.URI
    val filename = resource.lastSegment.replace("." + resource.fileExtension, "")
    val name = grammar.name
    if (filename != name) {
      error("grammar name '" + name + "' and file name '" + resource.lastSegment + "' differ",
        grammar, grammar.eClass.getEStructuralFeature("name")
      )
    }
  }
}
