package com.github.jknack.antlr4ide.ui.highlighting

import org.eclipse.xtext.ui.editor.syntaxcoloring.ISemanticHighlightingCalculator
import org.eclipse.xtext.resource.XtextResource
import org.eclipse.xtext.ui.editor.syntaxcoloring.IHighlightedPositionAcceptor
import com.github.jknack.antlr4ide.lang.Grammar
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EStructuralFeature
import org.eclipse.xtext.nodemodel.util.NodeModelUtils
import org.eclipse.xtext.nodemodel.INode
import org.eclipse.xtext.nodemodel.ILeafNode
import com.github.jknack.antlr4ide.lang.ParserRule
import com.github.jknack.antlr4ide.lang.Imports
import com.github.jknack.antlr4ide.lang.Options
import com.github.jknack.antlr4ide.lang.LexerRule
import com.github.jknack.antlr4ide.lang.RuleAction
import com.github.jknack.antlr4ide.lang.V4Tokens
import com.github.jknack.antlr4ide.lang.V4Token
import com.github.jknack.antlr4ide.lang.V3Tokens
import com.github.jknack.antlr4ide.lang.V3Token
import com.github.jknack.antlr4ide.lang.LabeledAlt
import com.github.jknack.antlr4ide.lang.LabeledElement
import com.github.jknack.antlr4ide.lang.EmptyTokens
import com.github.jknack.antlr4ide.lang.LexerCommand
import com.github.jknack.antlr4ide.lang.LexerCommands
import com.github.jknack.antlr4ide.lang.Mode
import com.github.jknack.antlr4ide.lang.ModeOrLexerRule
import com.github.jknack.antlr4ide.lang.LexerCharSet
import org.eclipse.xtext.util.ITextRegion
import com.google.common.base.Function
import org.eclipse.xtext.util.TextRegion
import com.github.jknack.antlr4ide.lang.RuleRef
import com.github.jknack.antlr4ide.lang.Terminal
import com.github.jknack.antlr4ide.lang.EbnfSuffix
import com.github.jknack.antlr4ide.lang.GrammarAction
import com.github.jknack.antlr4ide.lang.ElementOption
import com.github.jknack.antlr4ide.lang.ElementOptions
import com.github.jknack.antlr4ide.lang.Wildcard
import static com.github.jknack.antlr4ide.ui.highlighting.AntlrHighlightingConfiguration.*
import java.util.regex.Pattern
import com.github.jknack.antlr4ide.lang.ActionOption
import com.github.jknack.antlr4ide.lang.ActionElement
import org.eclipse.xtext.EcoreUtil2
import org.eclipse.xtext.xbase.lib.Procedures.Procedure2
import java.util.Set
import com.github.jknack.antlr4ide.lang.SetElement
import com.github.jknack.antlr4ide.lang.QualifiedOption
import com.google.inject.Inject
import org.eclipse.xtext.documentation.IEObjectDocumentationProviderExtension
import org.eclipse.xtext.documentation.IEObjectDocumentationProvider

class AntlrHighlightingCalculator implements ISemanticHighlightingCalculator {

  @Inject
  IEObjectDocumentationProvider documentationProvider

  val C_LIKE_COMMENT = Pattern.compile("(//.*?\n)|(?s)/\\*.*?\\*/")

  val C_LIKE_STRING = Pattern.compile("(\".*?\")|(\'.*?\')")

  val C_LIKE_REF = Pattern.compile("[$]([\\p{L}_$][\\p{L}\\p{N}_$]*\\.)*[\\p{L}_$][\\p{L}\\p{N}_$]*")

  val LANG = #{
    "java" -> #[
      LANG_COMMENT -> C_LIKE_COMMENT,
      LANG_STRING_LITERAL -> C_LIKE_STRING,
      LANG_REF -> C_LIKE_REF,
      LANG_KEYWORD -> Pattern.compile(
        "(" + newHashSet(
          "abstract",
          "true",
          "false",
          "continue",
          "for",
          "while",
          "new",
          "switch",
          "assert",
          "default",
          "goto",
          "package",
          "synchronized",
          "boolean",
          "do",
          "if",
          "private",
          "this",
          "break",
          "double",
          "implements",
          "protected",
          "throw",
          "byte",
          "else",
          "import",
          "public",
          "throws",
          "case",
          "enum",
          "instanceof",
          "return",
          "transient",
          "catch",
          "extends",
          "int",
          "short",
          "try",
          "char",
          "final",
          "interface",
          "static",
          "void",
          "class",
          "finally",
          "long",
          "strictfp",
          "volatile",
          "const",
          "null"
        ).join("\\b)|(\\b") + ")")
    ]
  }

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

    highlightDoc(acceptor, grammar)
  }

  def dispatch void highlight(IHighlightedPositionAcceptor acceptor, GrammarAction object) {
    highlightObjectAtFeature(acceptor, object, "atSymbol", ACTION)
    highlightObjectAtFeature(acceptor, object, "scope", ACTION)
    highlightObjectAtFeature(acceptor, object, "name", ACTION)
    highlightObjectAtFeature(acceptor, object, "colonSymbol", ACTION)

    // action code
    highlightAction(acceptor, object, "action", object.action)
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

    highlightDoc(acceptor, rule)
  }

  def private highlightDoc(IHighlightedPositionAcceptor acceptor,EObject source) {
    val docs = (documentationProvider as IEObjectDocumentationProviderExtension).getDocumentationNodes(source)
    if (docs != null && docs.size > 0) {
      val doc = docs.head
      acceptor.addPosition(doc.offset, doc.length, DOC_COMMENT)
    }
  }

  def dispatch void highlight(IHighlightedPositionAcceptor acceptor, ElementOptions object) {
    highlightObjectAtFeature(acceptor, object, "begin", ELEMENT_OPTION_DELIMITER)
    highlightObjectAtFeature(acceptor, object, "end", ELEMENT_OPTION_DELIMITER)
  }

  def dispatch void highlight(IHighlightedPositionAcceptor acceptor, ActionOption object) {
    highlightAction(acceptor, object, "value", object.value)
  }

  def dispatch void highlight(IHighlightedPositionAcceptor acceptor, ActionElement object) {
    val body = object.body
    highlightAction(acceptor, object, "body", body)
    if (body.endsWith("?")) {
      highlightObjectAtFeature(acceptor, object, "body", SEM_PRED)[region |
        new TextRegion(region.offset, 1)
      ]
      highlightObjectAtFeature(acceptor, object, "body", SEM_PRED)[region |
        new TextRegion(region.offset + region.length - 2, 2)
      ]
    }
  }

  def private void highlightAction(IHighlightedPositionAcceptor acceptor, EObject object, String featureName,
    String body) {
    val Set<Pair<Integer, Integer>> sections = newHashSet()
    val Procedure2<Pattern, String> highlighter = [ pattern, type |
      val matcher = pattern.matcher(body?: "")
      while (matcher.find) {
        highlightObjectAtFeature(acceptor, object, featureName, type) [ region |
          val offset = region.offset + matcher.start
          val existing = sections.findFirst[it|offset >= it.key && offset <= it.value]
          if (existing == null) {
            val len = matcher.group.length
            sections.add(offset -> offset + len)
            new TextRegion(offset, len)
          }
        ]
      }
    ]
    val grammar = EcoreUtil2.getContainerOfType(object, Grammar)
    val options = grammar.prequels.findFirst[it instanceof Options] as Options
    val langOption = if(options != null) options.options.findFirst[it.name == "language"]
    val language = if(langOption == null)
        "java"
      else
        (langOption.value as QualifiedOption).value.name.join(".")

    val partitions = LANG.get(language.toLowerCase)
    if (partitions != null) {
      partitions.forEach [ it |
        highlighter.apply(it.value, it.key)
      ]
    }
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

    highlightAction(acceptor, object, "body", object.body)
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

    highlightDoc(acceptor, rule)
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
      if (ref instanceof ModeOrLexerRule) {
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

  def dispatch void highlight(IHighlightedPositionAcceptor acceptor, SetElement object) {
    val charSet = object.charSet
    if (charSet != null) {
      highlightObjectAtFeature(acceptor, object, "charSet", CHARSET) [ region |
        new TextRegion(region.offset + 1, region.length - 2)
      ]
    }
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
      if (result != null) {
        acceptor.addPosition(result.offset, result.length, id)
      }
    }
  }

  private def Function<ITextRegion, TextRegion> keyword(String keyword) {
    [ region |
      new TextRegion(region.offset, keyword.length)
    ]
  }
}
