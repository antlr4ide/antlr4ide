package com.github.jknack.ui.highlighting

import org.eclipse.xtext.ui.editor.syntaxcoloring.ISemanticHighlightingCalculator
import org.eclipse.xtext.resource.XtextResource
import org.eclipse.xtext.ui.editor.syntaxcoloring.IHighlightedPositionAcceptor
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
import com.github.jknack.antlr4.EmptyTokens
import org.eclipse.xtext.ui.editor.syntaxcoloring.DefaultHighlightingConfiguration
import com.github.jknack.antlr4.LexerCommand
import com.github.jknack.antlr4.LexerCommands
import com.github.jknack.antlr4.Mode
import com.github.jknack.antlr4.ModeOrLexerRule
import com.github.jknack.antlr4.LexerCharSet
import org.eclipse.xtext.util.ITextRegion
import com.google.common.base.Function
import org.eclipse.xtext.util.TextRegion
import com.github.jknack.antlr4.RuleRef
import com.github.jknack.antlr4.Terminal
import com.github.jknack.antlr4.EbnfSuffix
import com.github.jknack.antlr4.GrammarAction

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

    for (rule : grammar.rules) {
      highlight(acceptor, rule)
    }

    for (prequel : grammar.prequels) {
      highlight(acceptor, prequel)
    }

    for (mode : grammar.modes) {
      highlight(acceptor, mode)
    }
  }

  def dispatch void highlight(IHighlightedPositionAcceptor acceptor, GrammarAction object) {
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
    val keyword = object.eClass.getEStructuralFeature("keyword")
    highlightObjectAtFeature(
      acceptor,
      object,
      keyword,
      DefaultHighlightingConfiguration.KEYWORD_ID,
      keyword("options")
    )
  }

  def dispatch void highlight(IHighlightedPositionAcceptor acceptor, EmptyTokens object) {
    val keyword = object.eClass.getEStructuralFeature("keyword")
    highlightObjectAtFeature(
      acceptor,
      object,
      keyword,
      DefaultHighlightingConfiguration.KEYWORD_ID,
      keyword("tokens")
    )
  }

  def dispatch void highlight(IHighlightedPositionAcceptor acceptor, V4Tokens object) {
    val keyword = object.eClass.getEStructuralFeature("keyword")
    highlightObjectAtFeature(
      acceptor,
      object,
      keyword,
      DefaultHighlightingConfiguration.KEYWORD_ID,
      keyword("tokens")
    )
    for (token : object.tokens) {
      highlight(acceptor, token)
    }
  }

  def dispatch void highlight(IHighlightedPositionAcceptor acceptor, V4Token object) {
    val name = object.eClass.getEStructuralFeature("name")
    highlightObjectAtFeature(acceptor, object, name, AntlrHighlightingConfiguration.TOKEN)
  }

  def dispatch void highlight(IHighlightedPositionAcceptor acceptor, V3Tokens object) {
    val keyword = object.eClass.getEStructuralFeature("keyword")
    highlightObjectAtFeature(
      acceptor,
      object,
      keyword,
      DefaultHighlightingConfiguration.KEYWORD_ID,
      keyword("tokens")
    )
    for (token : object.tokens) {
      highlight(acceptor, token)
    }
  }

  def dispatch void highlight(IHighlightedPositionAcceptor acceptor, V3Token object) {
    val name = object.eClass.getEStructuralFeature("id")
    highlightObjectAtFeature(acceptor, object, name, AntlrHighlightingConfiguration.TOKEN)
  }

  def dispatch void highlight(IHighlightedPositionAcceptor acceptor, Mode mode) {
    val id = mode.eClass.getEStructuralFeature("id")
    highlightObjectAtFeature(acceptor, mode, id, AntlrHighlightingConfiguration.MODE)

    for (rule : mode.rules) {
      highlight(acceptor, rule)
    }
  }

  def dispatch void highlight(IHighlightedPositionAcceptor acceptor, ParserRule rule) {
    val name = rule.eClass.getEStructuralFeature("name")
    highlightObjectAtFeature(acceptor, rule, name, AntlrHighlightingConfiguration.RULE)

    for (prequel : rule.prequels) {
      highlight(acceptor, prequel)
    }

    if (rule.body == null) {
      return
    }
    val children = rule.body.eAllContents
    while (children.hasNext) {
      try {
        highlight(acceptor, children.next)
      } catch (IllegalArgumentException ex) {
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

  def dispatch void highlight(IHighlightedPositionAcceptor acceptor, LexerRule rule) {
    val name = rule.eClass.getEStructuralFeature("name")
    highlightObjectAtFeature(acceptor, rule, name, AntlrHighlightingConfiguration.TOKEN)

    if (rule.body == null) {
      return
    }
    val children = rule.body.eAllContents
    while (children.hasNext) {
      try {
        highlight(acceptor, children.next)
      } catch (IllegalArgumentException ex) {
        // not all the rule elements have highlighting
      }
    }
  }

  def dispatch void highlight(IHighlightedPositionAcceptor acceptor, LexerCommands object) {
    val keyword = object.eClass.getEStructuralFeature("keyword")
    highlightObjectAtFeature(acceptor, object, keyword, AntlrHighlightingConfiguration.MODE_OPERATOR)
  }

  def dispatch void highlight(IHighlightedPositionAcceptor acceptor, RuleRef object) {
    val name = object.eClass.getEStructuralFeature("reference")
    highlightObjectAtFeature(acceptor, object, name, AntlrHighlightingConfiguration.RULE_REF)
  }

  def dispatch void highlight(IHighlightedPositionAcceptor acceptor, Terminal object) {
    val name = object.eClass.getEStructuralFeature("reference")
    if (name != null) {
      highlightObjectAtFeature(acceptor, object, name, AntlrHighlightingConfiguration.TOKEN_REF)
    }
  }

  def dispatch void highlight(IHighlightedPositionAcceptor acceptor, EbnfSuffix object) {
    val operator = object.eClass.getEStructuralFeature("operator")
    if (operator != null) {
      highlightObjectAtFeature(acceptor, object, operator, AntlrHighlightingConfiguration.EBNF)
    }

    val nongreedy = object.eClass.getEStructuralFeature("nongreedy")
    if (nongreedy != null) {
      highlightObjectAtFeature(acceptor, object, nongreedy, AntlrHighlightingConfiguration.EBNF)
    }
  }

  def dispatch void highlight(IHighlightedPositionAcceptor acceptor, LexerCommand object) {
    val name = object.eClass.getEStructuralFeature("name")
    highlightObjectAtFeature(acceptor, object, name, AntlrHighlightingConfiguration.LEXER_COMMAND)
    val expr = object.args
    if (expr != null) {
      val ref = expr.ref
      if (ref instanceof Mode || ref instanceof ModeOrLexerRule) {
        highlightObjectAtFeature(acceptor, expr, expr.eClass.getEStructuralFeature("ref"),
          AntlrHighlightingConfiguration.MODE)
      } else if (ref instanceof LexerRule) {
        highlightObjectAtFeature(acceptor, expr, expr.eClass.getEStructuralFeature("ref"),
          AntlrHighlightingConfiguration.TOKEN)
      } else {

        // int reference
        highlightObjectAtFeature(acceptor, expr, expr.eClass.getEStructuralFeature("value"),
          DefaultHighlightingConfiguration.NUMBER_ID)
      }
    }
  }

  def dispatch void highlight(IHighlightedPositionAcceptor acceptor, LexerCharSet object) {
    val body = object.eClass.getEStructuralFeature("body")
    highlightObjectAtFeature(acceptor, object, body, AntlrHighlightingConfiguration.CHARSET,
      [region|
        new TextRegion(region.offset + 1, region.length - 2)
      ]
    )
  }

  /**
   * Highlights an object at the position of the given {@link EStructuralFeature}
   */
  def highlightObjectAtFeature(IHighlightedPositionAcceptor acceptor, EObject object, EStructuralFeature feature,
    String id) {
    highlightObjectAtFeature(acceptor, object, feature, id, [
      region|region as TextRegion
    ])
  }

  /**
   * Highlights an object at the position of the given {@link EStructuralFeature}
   */
  def highlightObjectAtFeature(IHighlightedPositionAcceptor acceptor, EObject object, EStructuralFeature feature,
    String id, Function<ITextRegion, TextRegion> fn) {
    val children = NodeModelUtils.findNodesForFeature(object, feature)
    if (children.size() > 0) {
      highlightNode(children.get(0), id, acceptor, fn)
    }
  }

  /**
   * Highlights the non-hidden parts of {@code node} with the style that is associated with {@code id}.
   */
  def highlightNode(INode node, String id, IHighlightedPositionAcceptor acceptor, Function<ITextRegion, TextRegion> fn) {
    if (node == null) {
      return
    }
    var ITextRegion region = null
    if (node instanceof ILeafNode) {
      region = node.textRegion
    } else {
      for (ILeafNode leaf : node.leafNodes) {
        if (!leaf.hidden) {
          region = leaf.textRegion
        }
      }
    }
    if (region != null) {
      val result = fn.apply(region)
      acceptor.addPosition(result.offset, result.length, id)
    }
  }

  private def Function<ITextRegion, TextRegion> keyword(String keyword) {
    [region|
      new TextRegion(region.offset, keyword.length)
    ]
  }
}
