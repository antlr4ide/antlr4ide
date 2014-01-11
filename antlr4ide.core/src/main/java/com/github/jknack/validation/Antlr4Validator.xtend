package com.github.jknack.validation

import com.github.jknack.antlr4.Grammar
import com.github.jknack.antlr4.ParserRule
import com.github.jknack.antlr4.Rule
import java.util.Set
import org.eclipse.xtext.validation.Check
import org.eclipse.emf.ecore.EObject
import com.github.jknack.antlr4.V3Tokens
import com.github.jknack.antlr4.GrammarType
import com.github.jknack.antlr4.LexerRule
import com.github.jknack.antlr4.LabeledAlt
import org.eclipse.emf.ecore.util.EcoreUtil
import com.github.jknack.antlr4.V3Token
import com.github.jknack.antlr4.EmptyTokens
import com.github.jknack.antlr4.Antlr4Package
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1
import com.github.jknack.antlr4.V4Tokens
import org.eclipse.xtext.xbase.lib.Procedures.Procedure3
import com.google.common.base.Splitter
import com.google.common.base.CharMatcher
import com.github.jknack.antlr4.ActionElement
import org.eclipse.xtext.nodemodel.util.NodeModelUtils
import com.github.jknack.antlr4.ActionOption
import com.github.jknack.antlr4.Option
import com.github.jknack.antlr4.LabeledElement
import com.github.jknack.antlr4.Terminal
import com.github.jknack.antlr4.RuleRef
import com.github.jknack.antlr4.GrammarAction
import com.github.jknack.antlr4.Mode
import static extension org.eclipse.xtext.EcoreUtil2.*
import com.github.jknack.antlr4.Options
import com.github.jknack.antlr4.Imports

/**
 * Custom validation rules. 
 *
 * see http://www.eclipse.org/Xtext/documentation.html#validation
 */
class Antlr4Validator extends AbstractAntlr4Validator {

  public static val GRAMMAR_NAME_DIFFER = "grammarNameDiffer"

  public static val OPTIONS = newHashSet("superClass", "TokenLabelType", "tokenVocab", "language")

  @Check
  def checkGrammarName(Grammar grammar) {
    val resource = grammar.eResource.URI
    val filename = resource.lastSegment.replace("." + resource.fileExtension, "")
    val name = grammar.name
    if (filename != name) {
      error(
        "grammar name '" + name + "' and file name '" + resource.lastSegment + "' differ",
        Antlr4Package.Literals.GRAMMAR__NAME,
        GRAMMAR_NAME_DIFFER,
        name,
        filename
      )
    }
  }

  @Check
  def checkTreeGrammar(Grammar grammar) {
    if (grammar.type == GrammarType.TREE) {
      error(
        "tree grammars are not supported in ANTLR 4",
        grammar,
        grammar.eClass.getEStructuralFeature("name")
      )
    }
  }

  @Check
  def checkActionRedefinition(Grammar grammar) {
    val Set<String> actions = newHashSet()

    grammar.prequels.filter[it instanceof GrammarAction].forEach [ it |
      val action = it as GrammarAction
      if (!actions.add(action.name)) {
        error(
          "redefinition of '" + action.name + "' action",
          action,
          action.eClass.getEStructuralFeature("name")
        )
      }
    ]
  }

  @Check
  def modeNotInLexer(Mode mode) {
    val grammar = mode.eContainer as Grammar
    if (grammar.type != GrammarType.LEXER) {
      error(
        "lexical modes are only allowed in lexer grammars",
        mode,
        mode.eClass.getEStructuralFeature("id")
      )
    }
  }

  @Check
  def modeWithoutRules(Mode mode) {
    val grammar = mode.eContainer as Grammar
    val rules = mode.rules.filter[!it.fragment]
    if (grammar.type == GrammarType.LEXER && rules.empty) {
      error(
        "lexer mode '" + mode.id + "' must contain at least one non-fragment rule",
        mode,
        mode.eClass.getEStructuralFeature("id")
      )
    }
  }

  @Check
  def parserRulesNotAllowed(ParserRule rule) {
    val grammar = rule.getContainerOfType(Grammar) as Grammar
    if (grammar.type == GrammarType.LEXER) {
      error(
        "parser rule '" + rule.name + "' not allowed in lexer",
        rule,
        rule.eClass.getEStructuralFeature("name")
      )
    }
  }

  @Check
  def lexerRulesNotAllowed(LexerRule rule) {
    val grammar = rule.getContainerOfType(Grammar) as Grammar
    if (grammar.type == GrammarType.PARSER) {
      error(
        "lexer rule '" + rule.name + "' not allowed in parser",
        rule,
        rule.eClass.getEStructuralFeature("name")
      )
    }
  }

  @Check
  def repeatedPrequel(Grammar grammar) {
    val Set<String> prequels = newHashSet()
    for (prequel : grammar.prequels) {
      if (!prequels.add(prequel.eClass.name)) {
        val keyword = switch (prequel) {
          Options: "options"
          V4Tokens: "tokens"
          V3Tokens: "tokens"
          Imports: "import"
        }
        error(
          "repeated grammar prequel spec: '" + keyword + "'; please merge",
          prequel,
          0,
          keyword.length
        )
      }
    }
  }

  @Check
  def checkRuleRedefinition(Grammar grammar) {
    val Set<String> rules = newHashSet()

    val Procedure1<Rule> fn = [ rule |
      if (!rules.add(rule.name)) {
        error(
          "rule '" + rule.name + "' redefinition",
          rule,
          rule.eClass.getEStructuralFeature("name")
        )
      }
    ]
    grammar.rules.forEach(fn)

    grammar.modes.forEach [ mode |
      mode.rules.forEach(fn)
    ]
  }

  @Check
  def unsupportedOption(Option option) {
    if (!OPTIONS.contains(option.name)) {
      warning(
        "unsupported option '" + option.name + "'",
        option,
        option.eClass.getEStructuralFeature("name")
      )
    }
  }

  @Check
  def checkDuplicatedToken(Grammar grammar) {
    val Procedure3<EObject, String, String> fn = [ source, name, value |
      warning(
        "token name '" + value + "' is already defined",
        source,
        source.eClass.getEStructuralFeature(name)
      )
    ]

    val Set<String> rules = newHashSet()

    grammar.rules.filter[it instanceof LexerRule].forEach[it|rules.add(it.name)]

    grammar.prequels.filter[it instanceof V3Tokens].forEach [ it |
      (it as V3Tokens).tokens.forEach [ it |
        if (!rules.add(it.id)) {
          fn.apply(it, "id", it.id)
        }
      ]
    ]

    grammar.prequels.filter[it instanceof V4Tokens].forEach [ it |
      (it as V4Tokens).tokens.forEach [ it |
        if (!rules.add(it.name)) {
          fn.apply(it, "name", it.name)
        }
      ]
    ]
  }

  @Check
  def checkTokenName(Grammar grammar) {
    val Procedure3<EObject, String, String> fn = [ source, name, value |
      error(
        "token names must start with an uppercase letter: " + value,
        source,
        source.eClass.getEStructuralFeature(name)
      )
    ]

    grammar.prequels.filter[it instanceof V3Tokens].forEach [ it |
      (it as V3Tokens).tokens.forEach [ it |
        if (Character.isLowerCase(it.id.charAt(0))) {
          fn.apply(it, "id", it.id)
        }
      ]
    ]

    grammar.prequels.filter[it instanceof V4Tokens].forEach [ it |
      (it as V4Tokens).tokens.forEach [ it |
        if (Character.isLowerCase(it.name.charAt(0))) {
          fn.apply(it, "name", it.name)
        }
      ]
    ]
  }

  def private Set<String> locals(ParserRule rule) {
    val scope = new StringBuilder
    val Procedure1<String> append = [ content |
      if (content != null) {
        scope.append(content, 1, content.length - 1).append(" ")
      }
    ]
    append.apply(rule.args)

    if (rule.^return != null) {
      append.apply(rule.^return.body)
    }

    if(rule.locals != null) append.apply(rule.locals.body)

    // local vars and/or lexer rules
    rule.body.eAllContents.filter[it instanceof LabeledElement || it instanceof Terminal].forEach [ it |
      if (it instanceof LabeledElement) {
        scope.append(it.name).append(" ")
      } else if (it instanceof Terminal) {
        if (it.reference instanceof LexerRule) {
          scope.append((it.reference as LexerRule ).name).append(" ")
        }
      }
    ]

    newHashSet(
      Splitter.on(CharMatcher.anyOf(" ,;\r\n\t=")).trimResults.omitEmptyStrings.split(scope)
    )
  }

  private def checkAttributeReference(Set<String> locals, EObject action, String body) {
    var start = body.indexOf("$")
    while (start >= 0) {
      var i = start + 1
      val ref = new StringBuilder
      while (Character.isJavaIdentifierPart(body.charAt(i))) {
        ref.append(body.charAt(i))
        i = i + 1
      }
      if (!locals.contains(ref.toString)) {
        error(
          "unknown attribute reference '" + ref + "' in '$" + ref + "'",
          action,
          start,
          ref.length + 1
        )
      }
      start = body.indexOf("$", i)
    }
  }

  @Check
  def checkUnknownAttribute(Grammar grammar) {
    val rules = grammar.rules.filter[it instanceof ParserRule]

    rules.forEach [ it |
      val rule = it as ParserRule
      val locals = locals(rule)
      // iterate over actions
      val actions = rule.body.eAllContents.filter [
        it instanceof ActionElement || it instanceof ActionOption
      ]
      actions.forEach [ it |
        if (it instanceof ActionElement) {
          checkAttributeReference(locals, it, it.body)
        } else if (it instanceof ActionOption) {
          checkAttributeReference(locals, it, it.value)
        }
      ]
    ]
  }

  @Check
  def checkRuleRef(RuleRef ref) {
    val rule = ref.reference
    if (rule.args != null && ref.args == null) {
      error(
        "missing arguments(s) on rule reference: " + rule.name,
        ref,
        ref.eClass.getEStructuralFeature("reference")
      )
    }

    if (rule.args == null && ref.args != null) {
      error(
        "rule '" + rule.name + "' has no defined parameters",
        ref,
        ref.eClass.getEStructuralFeature("args")
      )
    }
  }

  @Check
  def checkEmptyRules(Grammar grammar) {
    val filter = if(grammar.type == GrammarType.LEXER) LexerRule else ParserRule
    val rules = grammar.rules
    if (rules == null || rules.filter(filter).length == 0) {
      error(
        "grammar '" + grammar.name + "' has no rules",
        grammar,
        grammar.eClass.getEStructuralFeature("name")
      )
    }
  }

  @Check
  def v3Tokens(V3Tokens tokens) {
    warning(
      "tokens {A; B;}' syntax is now 'tokens {A, B}' in ANTLR 4",
      tokens,
      0,
      "tokens".length
    )
  }

  @Check
  def v3Token(V3Token token) {
    if (token.value != null && token.value.length > 0) {
      error(
        "assignments in tokens{} are not supported in ANTLR 4; use lexical rule '" + token.id + ": " +
          token.value + "' instead",
        token,
        token.eClass.getEStructuralFeature("id")
      )
    }
  }

  @Check
  def emptyTokens(EmptyTokens tokens) {
    warning(
      "empty tokens",
      tokens,
      0,
      "tokens".length
    )
  }

  @Check
  def deprecateGatedSemanticPredicate(ActionElement action) {
    val body = action.body.trim
    val gated = "=>"
    val idx = body.indexOf(gated)

    if (idx > 0) {
      warning(
      "{...}?=> explicitly gated semantic predicates are deprecated in ANTLR 4; use {...}? instead",
      action,
      idx,
      gated.length
    )
    }
  }

  @Check
  def nameConflict(Rule rule) {
    val name = rule.name
    nameConflict(name, rule)
  }

  @Check
  def nameConflict(LabeledAlt labeledAlt) {
    val grammar = EcoreUtil.getRootContainer(labeledAlt) as Grammar
    val name = labeledAlt.label
    if (grammar.rules.exists[it.name == name]) {
      error(
        "rule alt label '" + name + "' conflicts with rule '" + name + "'",
        labeledAlt,
        labeledAlt.eClass.getEStructuralFeature("label")
      )
    }
  }

  private def nameConflict(String name, EObject source) {
    if (keywords.contains(name)) {
      error(
        "symbol '" + name + "'conflicts with generated code in target language or runtime",
        source,
        source.eClass.getEStructuralFeature("name")
      )
    }
  }

  private def error(String message, EObject source, int offset, int len) {
    val node = NodeModelUtils.getNode(source)
    if (node != null) {
      messageAcceptor.acceptError(message, source, node.offset + offset, len, null)
    }
  }

  private def warning(String message, EObject source, int offset, int len) {
    val node = NodeModelUtils.getNode(source)
    if (node != null) {
      messageAcceptor.acceptWarning(message, source, node.offset + offset, len, null)
    }
  }

  // Java conflicts
  private static final Set<String> keywords = newHashSet(
    "rule",
    "parserRule",
    "abstract",
    "assert",
    "boolean",
    "break",
    "byte",
    "case",
    "catch",
    "char",
    "class",
    "const",
    "continue",
    "default",
    "do",
    "double",
    "else",
    "enum",
    "extends",
    "false",
    "final",
    "finally",
    "float",
    "for",
    "if",
    "implements",
    "import",
    "instanceof",
    "int",
    "interface",
    "long",
    "native",
    "new",
    "null",
    "package",
    "private",
    "protected",
    "public",
    "return",
    "short",
    "static",
    "strictfp",
    "super",
    "switch",
    "synchronized",
    "this",
    "throw",
    "throws",
    "transient",
    "true",
    "try",
    "void",
    "volatile",
    "while"
  )
}
