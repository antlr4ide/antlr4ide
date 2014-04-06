package com.github.jknack.antlr4ide.parser

import com.google.inject.Inject
import org.eclipse.xtext.parser.IParser
import java.io.StringReader
import com.google.inject.Singleton
import org.eclipse.emf.ecore.EObject

@Singleton
class Antlr4ParseHelper<T extends EObject> {
  @Inject IParser parser

  def parse(CharSequence input) {
    parser.parse(new StringReader(input.toString))
  }

  def <T> T build(CharSequence input) {
    parser.parse(new StringReader(input.toString)).rootASTElement as T
  }
}
