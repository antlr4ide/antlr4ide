package com.github.jknack.antlr4ide.validation

import com.github.jknack.antlr4ide.lang.Grammar
import com.github.jknack.antlr4ide.lang.ParserRule
import com.github.jknack.antlr4ide.lang.Rule
import java.util.Set
import org.eclipse.xtext.validation.Check
import org.eclipse.emf.ecore.EObject
import com.github.jknack.antlr4ide.lang.V3Tokens
import com.github.jknack.antlr4ide.lang.GrammarType
import com.github.jknack.antlr4ide.lang.LexerRule
import com.github.jknack.antlr4ide.lang.LabeledAlt
import com.github.jknack.antlr4ide.lang.V3Token
import com.github.jknack.antlr4ide.lang.EmptyTokens
import com.github.jknack.antlr4ide.lang.LangPackage
import com.github.jknack.antlr4ide.lang.V4Tokens
import com.google.common.base.Splitter
import com.google.common.base.CharMatcher
import com.github.jknack.antlr4ide.lang.ActionElement
import org.eclipse.xtext.nodemodel.util.NodeModelUtils
import com.github.jknack.antlr4ide.lang.ActionOption
import com.github.jknack.antlr4ide.lang.Option
import com.github.jknack.antlr4ide.lang.LabeledElement
import com.github.jknack.antlr4ide.lang.Terminal
import com.github.jknack.antlr4ide.lang.RuleRef
import com.github.jknack.antlr4ide.lang.GrammarAction
import com.github.jknack.antlr4ide.lang.Mode
import static extension org.eclipse.xtext.EcoreUtil2.*
import com.github.jknack.antlr4ide.lang.Options
import com.github.jknack.antlr4ide.lang.Imports
import com.github.jknack.antlr4ide.lang.ElementOptions
import com.github.jknack.antlr4ide.lang.ElementOption
import com.github.jknack.antlr4ide.lang.Wildcard
import com.github.jknack.antlr4ide.lang.V4Token
import com.github.jknack.antlr4ide.validation.AbstractAntlr4Validator
import com.github.jknack.antlr4ide.lang.LexerCommand
import com.google.common.collect.Sets

/**
 * Custom validation rules. 
 *
 * see http://www.eclipse.org/Xtext/documentation.html#validation
 */
class Antlr4Validator extends AbstractAntlr4Validator {

  public static val GRAMMAR_NAME_DIFFER = "grammarNameDiffer"

  public static val OPTIONS = newHashSet("superClass", "TokenLabelType", "tokenVocab", "language")

  public static val SEMPRED_OPTIONS = newHashSet("fail")

  public static val RULEREF_OPTIONS = newHashSet("fail")

  public static val TOKEN_OPTIONS = newHashSet("assoc")

  /**
   * Default modes in ANTLRv4.
   */
  public static val MODES = newHashSet("DEFAULT_MODE", "MORE", "SKIP", "HIDDEN",
      "DEFAULT_TOKEN_CHANNEL")

  /** Lexer commands without argument */
  public static val NO_ARG_COMMANDS = newHashSet("skip", "more", "popMode")

  /** Lexer commands with argument */
  public static val COMMANDS = newHashSet("type", "channel", "mode", "pushMode")

  @Check
  def checkGrammarName(Grammar grammar) {
    val resource = grammar.eResource.URI
    val filename = resource.lastSegment.replace("." + resource.fileExtension, "")
    val name = grammar.name
    if (filename != name) {
      error(
        "grammar name '" + name + "' and file name '" + resource.lastSegment + "' differ",
        LangPackage.Literals.GRAMMAR__NAME,
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

    grammar.prequels.filter(GrammarAction).forEach [
      val name = it.name
      val qname = it.scope + "::" + name
      if (!actions.add(qname)) {
        error(
          "redefinition of '" + name + "' action",
          it,
          it.eClass.getEStructuralFeature("name")
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
    if (grammar.type == GrammarType.LEXER) {
      val rules = mode.rules.filter[!fragment]
      if (rules.empty) {
        error(
          "lexer mode '" + mode.id + "' must contain at least one non-fragment rule",
          mode,
          mode.eClass.getEStructuralFeature("id")
        )
      }
    }
  }

  @Check
  def parserRulesNotAllowed(ParserRule rule) {
    val grammar = rule.getContainerOfType(Grammar)
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
    val grammar = rule.getContainerOfType(Grammar)
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
      val label = switch (prequel) {
        Options: "options"
        V4Tokens: "tokens"
        V3Tokens: "tokens"
        Imports: "import"
      }
      if (!prequels.add(label)) {
        error(
          "repeated grammar prequel spec: '" + label + "'; please merge",
          prequel,
          0,
          label.length
        )
      }
    }
  }

  @Check
  def checkRuleRedefinition(Grammar grammar) {
    val Set<String> rules = newHashSet()

    val fn = [ Rule rule |
      val name = rule.name
      if (!rules.add(name)) {
        error(
          "rule '" + name + "' redefinition",
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
    val name = option.name
    if (!OPTIONS.contains(name)) {
      warning(
        "unsupported option '" + name + "'",
        option,
        option.eClass.getEStructuralFeature("name")
      )
    }
  }

  @Check
  def commandWithUnrecognizedConstantValue(LexerCommand command) {
    val args = command.args;

    if (args != null) {
      val ref = args.ref
      val rule = command.getContainerOfType(Rule)
      val references = Sets.newHashSet(MODES)
      val constant = switch (ref) {
        Mode : {
          references.add(ref.id)
          ref.id
        }
        LexerRule : {
          references.add(ref.name)
          ref.name
        }
        V3Token : ref.id
        V4Token : ref.name
        default: null
      }
      if (!references.contains(constant)) {
        warning(
          "rule '" + rule.name + "' contains a lexer command with an unrecognized " +
          "constant value; lexer interpreters may produce incorrect output",
          args,
          args.eClass.getEStructuralFeature("ref")
        )
      }
    }
  }

  @Check
  def missingArgument(LexerCommand command) {
    val name = command.name
    val args = command.args;
    if (COMMANDS.contains(name) && args == null) {
      error(
        "missing argument for lexer command '" + name + "' ",
        command,
        command.eClass.getEStructuralFeature("name")
      )
    }
  }

  @Check
  def noArgument(LexerCommand command) {
    val name = command.name
    val args = command.args;
    if (NO_ARG_COMMANDS.contains(name) && args != null) {
      error(
        "lexer command '" + name + "' does not take any arguments",
        command,
        command.eClass.getEStructuralFeature("name")
      )
    }
  }

  @Check
  def unsupported(LexerCommand command) {
    val name = command.name

    if (!NO_ARG_COMMANDS.contains(name) && !COMMANDS.contains(name)) {
      error(
        "lexer command '" + name + "' does not exist or is not supported by the current target",
        command,
        command.eClass.getEStructuralFeature("name")
      )
    }
  }

  @Check
  def checkDuplicatedToken(Grammar grammar) {
    val Set<String> rules = newHashSet()

    val fn = [ EObject source, String name, String value |
      if (!rules.add(value)) {
        warning(
          "token name '" + value + "' is already defined",
          source,
          source.eClass.getEStructuralFeature(name)
        )
      }
    ]

    grammar.rules.filter[it instanceof LexerRule].forEach[rules.add(it.name)]

    val prequels = grammar.prequels
    prequels.filter(V3Tokens).forEach [
      it.tokens.forEach [
        fn.apply(it, "id", it.id)
      ]
    ]

    prequels.filter(V4Tokens).forEach [
      it.tokens.forEach [
        fn.apply(it, "name", it.name)
      ]
    ]
  }

  @Check
  def tokenNamesMustStartWithUppercaseLetter(V3Token token) {
    tokenNamesMustStartWithUppercaseLetter(token, "id", token.id)
  }

  @Check
  def tokenNamesMustStartWithUppercaseLetter(V4Token token) {
    tokenNamesMustStartWithUppercaseLetter(token, "name", token.name)
  }

  private def tokenNamesMustStartWithUppercaseLetter(EObject token, String name, String value) {
    if (Character.isLowerCase(value.charAt(0))) {
      error(
        "token names must start with an uppercase letter: " + value,
        token,
        token.eClass.getEStructuralFeature(name)
      )
    }
  }

  @Check
  def checkElementOptions(ElementOptions options) {
    val validator = [ ElementOption option, Set<String> validOptions |
      val qualifiedId = option.qualifiedId
      val feature = if (qualifiedId == null) {
          "id" -> option.id
        } else {
          "qualifiedId" -> qualifiedId.name.join(".")
        }
      if (!validOptions.contains(feature.value)) {
        warning(
          "unknown option: " + feature.value,
          option,
          option.eClass.getEStructuralFeature(feature.key)
        )
      }
    ]
    val validOptions = switch (options.eContainer) {
      Terminal: TOKEN_OPTIONS
      Wildcard: TOKEN_OPTIONS
      RuleRef: RULEREF_OPTIONS
      ActionElement: SEMPRED_OPTIONS
      default: newHashSet()
    }
    if (validOptions.size > 0) {
      options.options.forEach [
        validator.apply(it, validOptions)
      ]
    }
  }

  def private Set<String> locals(ParserRule rule) {
    val scope = new StringBuilder
    val append = [ String it |
      if (it != null) {
        scope.append(it, 1, it.length - 1).append(" ")
      }
    ]
    append.apply(rule.args)

    val returns = rule.^return
    if (returns != null) {
      append.apply(returns.body)
    }

    val locals = rule.locals
    if(locals != null) append.apply(locals.body)

    // local vars and/or lexer rules
    rule.body.eAllContents.filter[it instanceof LabeledElement || it instanceof Terminal].forEach [
      if (it instanceof LabeledElement) {
        scope.append(it.name).append(" ")
      } else if (it instanceof Terminal) {
        val reference = it.reference
        if (reference instanceof LexerRule) {
          scope.append(reference.name).append(" ")
        }
      }
    ]

    Splitter.on(CharMatcher.anyOf(" ,;\r\n\t=")).trimResults.omitEmptyStrings.split(scope).toSet
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
    grammar.rules.filter(ParserRule).forEach [
      val locals = locals(it)
      // iterate over actions
      it.body.eAllContents.forEach [
        if (it instanceof ActionElement) {
          checkAttributeReference(locals, it, it.body)
        } else if (it instanceof ActionOption) {
          checkAttributeReference(locals, it, it.value)
        }
      ]
    ]
  }

  @Check
  def checkRuleParameters(RuleRef ref) {
    val rule = ref.reference
    if (rule.args != null) {
      if (ref.args == null) {
        error(
          "missing arguments(s) on rule reference: " + rule.name,
          ref,
          ref.eClass.getEStructuralFeature("reference")
        )
      }
    } else {
      if (ref.args != null) {
        error(
          "rule '" + rule.name + "' has no defined parameters",
          ref,
          ref.eClass.getEStructuralFeature("args")
        )
      }
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
    val value = token.value
    if (value != null && value.length > 0) {
      error(
        "assignments in tokens{} are not supported in ANTLR 4; use lexical rule '" + token.id + ": " +
          value + "' instead",
        token,
        token.eClass.getEStructuralFeature("id")
      )
    }
  }

  @Check
  def emptyTokens(EmptyTokens tokens) {
    val grammar = tokens.eContainer as Grammar
    warning("grammar '" + grammar.name + "' has no tokens", tokens, 0, "tokens".length)
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
    val grammar = labeledAlt.rootContainer as Grammar
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
        "symbol '" + name + "' conflicts with generated code in target language or runtime",
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
  static val keywords = newHashSet(
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
