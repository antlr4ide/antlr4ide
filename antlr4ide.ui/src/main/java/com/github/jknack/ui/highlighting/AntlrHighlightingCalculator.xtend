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
import com.github.jknack.antlr4.ElementOption
import com.github.jknack.antlr4.ElementOptions
import com.github.jknack.antlr4.Wildcard
import static com.github.jknack.ui.highlighting.AntlrHighlightingConfiguration.*

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
    highlightObjectAtFeature(acceptor, object, "atSymbol", ACTION)
    highlightObjectAtFeature(acceptor, object, "scope", ACTION)
    highlightObjectAtFeature(acceptor, object, "name", ACTION)
    highlightObjectAtFeature(acceptor, object, "colonSymbol", ACTION)
  }

  def dispatch void highlight(IHighlightedPositionAcceptor acceptor, Imports object) {
  }

  def dispatch void highlight(IHighlightedPositionAcceptor acceptor, Options object) {
    highlightObjectAtFeature(acceptor, object, "keyword", KEYWORD_ID, keyword("options"))
  }

  def dispatch void highlight(IHighlightedPositionAcceptor acceptor, EmptyTokens object) {
    highlightObjectAtFeature(acceptor, object, "keyword", KEYWORD_ID, keyword("tokens"))
  }

  def dispatch void highlight(IHighlightedPositionAcceptor acceptor, V4Tokens object) {
    highlightObjectAtFeature(acceptor, object, "keyword", KEYWORD_ID, keyword("tokens"))

    for (token : object.tokens) {
      highlight(acceptor, token)
    }
  }

  def dispatch void highlight(IHighlightedPositionAcceptor acceptor, V4Token object) {
    highlightObjectAtFeature(acceptor, object, "name", TOKEN)
  }

  def dispatch void highlight(IHighlightedPositionAcceptor acceptor, V3Tokens object) {
    highlightObjectAtFeature(acceptor, object, "keyword", KEYWORD_ID, keyword("tokens"))

    for (token : object.tokens) {
      highlight(acceptor, token)
    }
  }

  def dispatch void highlight(IHighlightedPositionAcceptor acceptor, V3Token object) {
    highlightObjectAtFeature(acceptor, object, "id", TOKEN)
  }

  def dispatch void highlight(IHighlightedPositionAcceptor acceptor, Mode mode) {
    highlightObjectAtFeature(acceptor, mode, "id", MODE)

    for (rule : mode.rules) {
      highlight(acceptor, rule)
    }
  }

  def dispatch void highlight(IHighlightedPositionAcceptor acceptor, ParserRule rule) {
    highlightObjectAtFeature(acceptor, rule, "name", RULE)

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

  def dispatch void highlight(IHighlightedPositionAcceptor acceptor, ElementOptions object) {
    highlightObjectAtFeature(acceptor, object, "begin", ELEMENT_OPTION_DELIMITER)
    highlightObjectAtFeature(acceptor, object, "end", ELEMENT_OPTION_DELIMITER)
  }

  def dispatch void highlight(IHighlightedPositionAcceptor acceptor, Wildcard object) {
    highlightObjectAtFeature(acceptor, object, "dot", WILDCARD)
  }

  def dispatch void highlight(IHighlightedPositionAcceptor acceptor, ElementOption object) {
    val name = if(object.qualifiedId == null) "id" else "qualifiedId"

    highlightObjectAtFeature(acceptor, object, name, KEYWORD_ID)
    highlightObjectAtFeature(acceptor, object, "assign", ELEMENT_OPTION_ASSIGN_OP)
  }

  def dispatch void highlight(IHighlightedPositionAcceptor acceptor, LabeledAlt object) {
    highlightObjectAtFeature(acceptor, object, "poundSymbol", LABEL)
    highlightObjectAtFeature(acceptor, object, "label", LABEL)
  }

  def dispatch void highlight(IHighlightedPositionAcceptor acceptor, LabeledElement object) {
    highlightObjectAtFeature(acceptor, object, "name", LOCAL_VAR)
  }

  def dispatch void highlight(IHighlightedPositionAcceptor acceptor, RuleAction object) {
    highlightObjectAtFeature(acceptor, object, "atSymbol", ACTION)
    highlightObjectAtFeature(acceptor, object, "name", ACTION)
  }

  def dispatch void highlight(IHighlightedPositionAcceptor acceptor, LexerRule rule) {
    highlightObjectAtFeature(acceptor, rule, "name", TOKEN)

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
    highlightObjectAtFeature(acceptor, object, "keyword", MODE_OPERATOR)
  }

  def dispatch void highlight(IHighlightedPositionAcceptor acceptor, RuleRef object) {
    highlightObjectAtFeature(acceptor, object, "reference", RULE_REF)
  }

  def dispatch void highlight(IHighlightedPositionAcceptor acceptor, Terminal object) {
    highlightObjectAtFeature(acceptor, object, "reference", TOKEN_REF)
  }

  def dispatch void highlight(IHighlightedPositionAcceptor acceptor, EbnfSuffix object) {
    highlightObjectAtFeature(acceptor, object, "operator", EBNF)

    highlightObjectAtFeature(acceptor, object, "nongreedy", EBNF)
  }

  def dispatch void highlight(IHighlightedPositionAcceptor acceptor, LexerCommand object) {
    highlightObjectAtFeature(acceptor, object, "name", LEXER_COMMAND)
    val expr = object.args
    if (expr != null) {
      val ref = expr.ref
      if (ref instanceof Mode || ref instanceof ModeOrLexerRule) {
        highlightObjectAtFeature(acceptor, expr, "ref", MODE)
      } else if (ref instanceof LexerRule) {
        highlightObjectAtFeature(acceptor, expr, "ref", TOKEN)
      } else {

        // int reference
        highlightObjectAtFeature(acceptor, expr, "value", NUMBER_ID)
      }
    }
  }

  def dispatch void highlight(IHighlightedPositionAcceptor acceptor, LexerCharSet object) {
    highlightObjectAtFeature(acceptor, object, "body", CHARSET) [ region |
      new TextRegion(region.offset + 1, region.length - 2)
    ]
  }

  /**
   * Highlights an object at the position of the given {@link EStructuralFeature}
   */
  def highlightObjectAtFeature(IHighlightedPositionAcceptor acceptor, EObject object, String featureName, String id) {
    highlightObjectAtFeature(acceptor, object, featureName, id) [ region |
      region as TextRegion
    ]
  }

  /**
   * Highlights an object at the position of the given {@link EStructuralFeature}
   */
  def highlightObjectAtFeature(IHighlightedPositionAcceptor acceptor, EObject object, String featureName, String id,
    Function<ITextRegion, TextRegion> fn) {
    val feature = object.eClass.getEStructuralFeature(featureName)
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
    [ region |
      new TextRegion(region.offset, keyword.length)
    ]
  }
}
