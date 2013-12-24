package com.github.jknack.ui.syntaxcoloring

import org.eclipse.xtext.ui.editor.syntaxcoloring.ISemanticHighlightingCalculator
import org.eclipse.xtext.resource.XtextResource
import org.eclipse.xtext.ui.editor.syntaxcoloring.IHighlightedPositionAcceptor
import com.github.jknack.antlr4.Action
import com.github.jknack.antlr4.Grammar
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EStructuralFeature
import org.eclipse.xtext.nodemodel.util.NodeModelUtils
import org.eclipse.xtext.nodemodel.INode
import org.eclipse.xtext.nodemodel.ILeafNode
import com.github.jknack.antlr4.ParserRule
import com.github.jknack.antlr4.Imports
import com.github.jknack.antlr4.Options
import com.github.jknack.antlr4.LexerRule
import com.github.jknack.antlr4.RuleAction
import com.github.jknack.antlr4.V4Tokens
import com.github.jknack.antlr4.V4Token
import com.github.jknack.antlr4.V3Tokens
import com.github.jknack.antlr4.V3Token
import com.github.jknack.antlr4.LabeledAlt
import com.github.jknack.antlr4.LabeledElement

class AntlrHighlightingCalculator implements ISemanticHighlightingCalculator {

  override provideHighlightingFor(XtextResource resource, IHighlightedPositionAcceptor acceptor) {
    if (resource == null) {
      return
    }
    val parseResult = resource.parseResult
    if (parseResult == null || parseResult.getRootASTElement() == null) {
      return
    }
    // iterate over elements and calculate highlighting
    val grammar = resource.contents.get(0) as Grammar;

    for (prequel : grammar.prequels) {
      highlight(acceptor, prequel)
    }

    for (rule : grammar.rules) {
      highlight(acceptor, rule)
    }
  }

  def dispatch void highlight(IHighlightedPositionAcceptor acceptor, Action object) {
    val at = object.eClass.getEStructuralFeature("atSymbol");
    val scope = object.eClass.getEStructuralFeature("scope");
    val name = object.eClass.getEStructuralFeature("name");
    val colon = object.eClass.getEStructuralFeature("colonSymbol");
    highlightObjectAtFeature(acceptor, object, at, AntlrHighlightingConfiguration.ACTION);
    highlightObjectAtFeature(acceptor, object, scope, AntlrHighlightingConfiguration.ACTION);
    highlightObjectAtFeature(acceptor, object, name, AntlrHighlightingConfiguration.ACTION);
    highlightObjectAtFeature(acceptor, object, colon, AntlrHighlightingConfiguration.ACTION);
  }

  def dispatch void highlight(IHighlightedPositionAcceptor acceptor, Imports object) {
  }

  def dispatch void highlight(IHighlightedPositionAcceptor acceptor, Options object) {
  }

  def dispatch void highlight(IHighlightedPositionAcceptor acceptor, V4Tokens object) {
    for(token : object.tokens) {
      highlight(acceptor, token)
    }
  }

  def dispatch void highlight(IHighlightedPositionAcceptor acceptor, V4Token object) {
    val name = object.eClass.getEStructuralFeature("name")
    highlightObjectAtFeature(acceptor, object, name, AntlrHighlightingConfiguration.TOKEN)
  }

  def dispatch void highlight(IHighlightedPositionAcceptor acceptor, V3Tokens object) {
    for(token : object.tokens) {
      highlight(acceptor, token)
    }
  }

  def dispatch void highlight(IHighlightedPositionAcceptor acceptor, V3Token object) {
    val name = object.eClass.getEStructuralFeature("id")
    highlightObjectAtFeature(acceptor, object, name, AntlrHighlightingConfiguration.TOKEN)
  }

  def dispatch void highlight(IHighlightedPositionAcceptor acceptor, ParserRule rule) {
    val name = rule.eClass.getEStructuralFeature("name")
    highlightObjectAtFeature(acceptor, rule, name, AntlrHighlightingConfiguration.RULE)

    for(prequel: rule.prequels) {
      highlight(acceptor, prequel)
    }

    if (rule.body == null) {
      return
    }
    val children = rule.body.eAllContents
    while(children.hasNext) {
      try {
        highlight(acceptor, children.next)
      } catch(IllegalArgumentException ex) {
        // not all the rule elements have highlighting
      }
    }
  }

  def dispatch void highlight(IHighlightedPositionAcceptor acceptor, LabeledAlt object) {
    val pound = object.eClass.getEStructuralFeature("poundSymbol")
    val label = object.eClass.getEStructuralFeature("label")
    highlightObjectAtFeature(acceptor, object, pound, AntlrHighlightingConfiguration.LABEL)
    highlightObjectAtFeature(acceptor, object, label, AntlrHighlightingConfiguration.LABEL)
  }

  def dispatch void highlight(IHighlightedPositionAcceptor acceptor, LabeledElement object) {
    val name = object.eClass.getEStructuralFeature("name")
    highlightObjectAtFeature(acceptor, object, name, AntlrHighlightingConfiguration.LOCAL_VAR)
  }

  def dispatch void highlight(IHighlightedPositionAcceptor acceptor, RuleAction object) {
    val at = object.eClass.getEStructuralFeature("atSymbol")
    val name = object.eClass.getEStructuralFeature("name")
    highlightObjectAtFeature(acceptor, object, at, AntlrHighlightingConfiguration.ACTION)
    highlightObjectAtFeature(acceptor, object, name, AntlrHighlightingConfiguration.ACTION)
  }

  def dispatch void highlight(IHighlightedPositionAcceptor acceptor, LexerRule object) {
    val name = object.eClass.getEStructuralFeature("name")
    highlightObjectAtFeature(acceptor, object, name, AntlrHighlightingConfiguration.TOKEN)
  }

  /**
   * Highlights an object at the position of the given {@link EStructuralFeature}
   */
  def highlightObjectAtFeature(IHighlightedPositionAcceptor acceptor, EObject object,
    EStructuralFeature feature, String id) {
    val children = NodeModelUtils.findNodesForFeature(object, feature)
    if (children.size() > 0) {
      highlightNode(children.get(0), id, acceptor)
    }
  }

  /**
   * Highlights the non-hidden parts of {@code node} with the style that is associated with {@code id}.
   */
  def highlightNode(INode node, String id, IHighlightedPositionAcceptor acceptor) {
    if (node == null) {
      return
    }
    if (node instanceof ILeafNode) {
      val textRegion = node.textRegion
      acceptor.addPosition(textRegion.offset, textRegion.length, id)
    } else {
      for (ILeafNode leaf : node.leafNodes) {
        if (!leaf.hidden) {
          val leafRegion = leaf.textRegion
          acceptor.addPosition(leafRegion.offset, leafRegion.length, id)
        }
      }
    }
  }
}
