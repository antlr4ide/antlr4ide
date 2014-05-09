package com.github.jknack.antlr4ide.services

import com.google.common.collect.Maps
import com.github.jknack.antlr4ide.lang.Grammar
import org.eclipse.emf.ecore.EObject
import com.github.jknack.antlr4ide.lang.ParserRule
import com.github.jknack.antlr4ide.lang.LexerRule
import com.github.jknack.antlr4ide.lang.Terminal
import com.google.common.collect.Sets
import com.google.common.base.Objects
import org.eclipse.xtext.EcoreUtil2
import java.util.Map
import com.github.jknack.antlr4ide.lang.Imports
import java.util.Set
import com.github.jknack.antlr4ide.lang.Import
import org.eclipse.emf.ecore.EReference
import org.eclipse.xtext.nodemodel.util.NodeModelUtils

/**
 * Utility methods for model objects.
 */
class ModelExtensions {

  /**
   * Build a map with rule names as keys and rule as values. If literals is true, all the literals
   * will be included too.
   */
  def static Map<String, EObject> ruleMap(Grammar grammar, boolean literals) {
    val rules = Maps.<String, EObject>newHashMap

    grammar.rules.forEach [
      rules.put(it.name, it)
      if (literals) {
        switch (it) {
          ParserRule: it.body
          LexerRule: it.body
        }.eAllContents.forEach [
          if (it instanceof Terminal) {
            val literal = it.literal
            if (literal != null) {
              rules.put("'" + literal + "'", it)
            }
          }
        ]
      }
    ]
    return rules
  }

  /**
   * Collect all literals from grammar.
   */
  def static literals(Grammar grammar) {
    val literals = Sets.<String>newLinkedHashSet
    grammar.rules.forEach [
      switch (it) {
        ParserRule: it.body
        LexerRule: it.body
      }.eAllContents.forEach [
        if (it instanceof Terminal) {
          val literal = it.literal
          if (literal != null) {
            literals.add(literal)
          }
        }
      ]
    ]
    return literals;
  }

  /**
   * Build a hash code for source object base on content.
   */
  def static hash(EObject object) {
    Objects.hashCode(EcoreUtil2.eAllContentsAsList(object).toArray)
  }

  def static Set<Import> imports(Grammar grammar) {
    val Set<Import> imports = Sets.newLinkedHashSet
    grammar.prequels.filter(Imports).forEach[
      it.imports.forEach[
        imports.add(it)
      ]
    ]
    return imports
  }

  def static String unresolvedName(EObject source, EReference reference) {
    val refs = NodeModelUtils.findNodesForFeature(source, reference)
    return refs?.head?.text
  }
}
