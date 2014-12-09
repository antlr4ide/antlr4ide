package com.github.jknack.antlr4ide.validation;

import static org.easymock.EasyMock.createMock;
import static org.easymock.EasyMock.expect;
import static org.easymock.EasyMock.replay;
import static org.easymock.EasyMock.verify;
import static org.junit.Assert.assertEquals;

import java.util.Iterator;

import org.eclipse.emf.common.util.BasicEList;
import org.eclipse.emf.common.util.EList;
import org.eclipse.emf.common.util.TreeIterator;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EClass;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EStructuralFeature;
import org.eclipse.emf.ecore.resource.Resource;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.powermock.api.easymock.PowerMock;
import org.powermock.core.classloader.annotations.PrepareForTest;
import org.powermock.modules.junit4.PowerMockRunner;

import com.github.jknack.antlr4ide.lang.ActionElement;
import com.github.jknack.antlr4ide.lang.ActionOption;
import com.github.jknack.antlr4ide.lang.ElementOption;
import com.github.jknack.antlr4ide.lang.ElementOptions;
import com.github.jknack.antlr4ide.lang.EmptyTokens;
import com.github.jknack.antlr4ide.lang.Grammar;
import com.github.jknack.antlr4ide.lang.GrammarAction;
import com.github.jknack.antlr4ide.lang.GrammarType;
import com.github.jknack.antlr4ide.lang.Imports;
import com.github.jknack.antlr4ide.lang.LabeledAlt;
import com.github.jknack.antlr4ide.lang.LabeledElement;
import com.github.jknack.antlr4ide.lang.LangPackage;
import com.github.jknack.antlr4ide.lang.LexerRule;
import com.github.jknack.antlr4ide.lang.LocalVars;
import com.github.jknack.antlr4ide.lang.Mode;
import com.github.jknack.antlr4ide.lang.NotSet;
import com.github.jknack.antlr4ide.lang.Option;
import com.github.jknack.antlr4ide.lang.Options;
import com.github.jknack.antlr4ide.lang.ParserRule;
import com.github.jknack.antlr4ide.lang.PrequelConstruct;
import com.github.jknack.antlr4ide.lang.QualifiedId;
import com.github.jknack.antlr4ide.lang.Return;
import com.github.jknack.antlr4ide.lang.Rule;
import com.github.jknack.antlr4ide.lang.RuleBlock;
import com.github.jknack.antlr4ide.lang.RuleRef;
import com.github.jknack.antlr4ide.lang.Terminal;
import com.github.jknack.antlr4ide.lang.V3Token;
import com.github.jknack.antlr4ide.lang.V3Tokens;
import com.github.jknack.antlr4ide.lang.V4Token;
import com.github.jknack.antlr4ide.lang.V4Tokens;
import com.github.jknack.antlr4ide.lang.Wildcard;
import com.google.common.collect.Sets;

@RunWith(PowerMockRunner.class)
@PrepareForTest({Antlr4Validator.class })
public class Antlr4ValidatorTest {

  @Test
  public void checkGrammarName() throws Exception {
    URI uri = URI.createURI("/home/project/G.g4");

    Grammar grammar = createMock(Grammar.class);
    Resource resource = createMock(Resource.class);
    Antlr4Validator validator = PowerMock.createPartialMock(Antlr4Validator.class, "error");

    expect(grammar.eResource()).andReturn(resource);
    expect(grammar.getName()).andReturn("H");
    expect(resource.getURI()).andReturn(uri);

    PowerMock.expectPrivate(validator, "error", "grammar name 'H' and file name 'G.g4' differ",
        LangPackage.Literals.GRAMMAR__NAME, Antlr4Validator.GRAMMAR_NAME_DIFFER, "H", "G");

    Object[] mocks = {grammar, resource, validator };

    replay(mocks);

    validator.checkGrammarName(grammar);

    verify(mocks);
  }

  @Test
  public void checkTreeGrammar() throws Exception {

    Grammar grammar = createMock(Grammar.class);
    EClass eClass = createMock(EClass.class);
    EStructuralFeature feature = createMock(EStructuralFeature.class);
    Antlr4Validator validator = PowerMock.createPartialMock(Antlr4Validator.class, "error");

    expect(grammar.getType()).andReturn(GrammarType.TREE);
    expect(grammar.eClass()).andReturn(eClass);
    expect(eClass.getEStructuralFeature("name")).andReturn(feature);

    PowerMock.expectPrivate(validator, "error", "tree grammars are not supported in ANTLR 4",
        grammar, feature);

    Object[] mocks = {grammar, validator, eClass, feature };

    replay(mocks);

    validator.checkTreeGrammar(grammar);

    verify(mocks);
  }

  @Test
  public void checkActionRedefinition() throws Exception {
    EList<PrequelConstruct> prequels = new BasicEList<PrequelConstruct>();

    Grammar grammar = createMock(Grammar.class);
    GrammarAction action1 = createMock(GrammarAction.class);
    GrammarAction action2 = createMock(GrammarAction.class);
    EClass eClass = createMock(EClass.class);
    EStructuralFeature feature = createMock(EStructuralFeature.class);
    Antlr4Validator validator = PowerMock.createPartialMock(Antlr4Validator.class, "error");

    expect(grammar.getPrequels()).andReturn(prequels);

    expect(action1.getScope()).andReturn(null);
    expect(action1.getName()).andReturn("members");

    expect(action2.getScope()).andReturn(null);
    expect(action2.getName()).andReturn("members");
    expect(action2.eClass()).andReturn(eClass);
    expect(eClass.getEStructuralFeature("name")).andReturn(feature);

    PowerMock.expectPrivate(validator, "error", "redefinition of 'members' action",
        action2, feature);

    prequels.add(action1);
    prequels.add(action2);

    Object[] mocks = {grammar, validator, eClass, feature, action1, action2 };

    replay(mocks);

    validator.checkActionRedefinition(grammar);

    verify(mocks);
  }

  @Test
  public void modeNotInLexer() throws Exception {

    Grammar grammar = createMock(Grammar.class);
    Mode mode = createMock(Mode.class);
    EClass eClass = createMock(EClass.class);
    EStructuralFeature feature = createMock(EStructuralFeature.class);
    Antlr4Validator validator = PowerMock.createPartialMock(Antlr4Validator.class, "error");

    expect(mode.eContainer()).andReturn(grammar);

    expect(grammar.getType()).andReturn(GrammarType.DEFAULT);

    expect(mode.eClass()).andReturn(eClass);
    expect(eClass.getEStructuralFeature("id")).andReturn(feature);

    PowerMock.expectPrivate(validator, "error", "lexical modes are only allowed in lexer grammars",
        mode, feature);

    Object[] mocks = {grammar, mode, validator, eClass, feature };

    replay(mocks);

    validator.modeNotInLexer(mode);

    verify(mocks);
  }

  @Test
  public void modeWithoutRules() throws Exception {
    EList<LexerRule> rules = new BasicEList<LexerRule>();

    Grammar grammar = createMock(Grammar.class);
    Mode mode = createMock(Mode.class);
    EClass eClass = createMock(EClass.class);
    EStructuralFeature feature = createMock(EStructuralFeature.class);
    LexerRule rule = createMock(LexerRule.class);
    Antlr4Validator validator = PowerMock.createPartialMock(Antlr4Validator.class, "error");

    expect(mode.eContainer()).andReturn(grammar);
    expect(mode.getId()).andReturn("MODE");

    expect(grammar.getType()).andReturn(GrammarType.LEXER);

    expect(mode.getRules()).andReturn(rules);
    expect(mode.eClass()).andReturn(eClass);
    expect(eClass.getEStructuralFeature("id")).andReturn(feature);

    expect(rule.isFragment()).andReturn(true);

    PowerMock.expectPrivate(validator, "error",
        "lexer mode 'MODE' must contain at least one non-fragment rule",
        mode, feature);

    rules.add(rule);

    Object[] mocks = {grammar, mode, validator, eClass, feature, rule };

    replay(mocks);

    validator.modeWithoutRules(mode);

    verify(mocks);
  }

  @Test
  public void parserRulesNotAllowed() throws Exception {

    Grammar grammar = createMock(Grammar.class);
    ParserRule rule = createMock(ParserRule.class);
    EClass eClass = createMock(EClass.class);
    EStructuralFeature feature = createMock(EStructuralFeature.class);
    Antlr4Validator validator = PowerMock.createPartialMock(Antlr4Validator.class, "error");

    expect(grammar.getType()).andReturn(GrammarType.LEXER);

    expect(rule.eContainer()).andReturn(grammar);
    expect(rule.eClass()).andReturn(eClass);
    expect(rule.getName()).andReturn("rule");
    expect(eClass.getEStructuralFeature("name")).andReturn(feature);

    PowerMock.expectPrivate(validator, "error", "parser rule 'rule' not allowed in lexer",
        rule, feature);

    Object[] mocks = {grammar, rule, validator, eClass, feature };

    replay(mocks);

    validator.parserRulesNotAllowed(rule);

    verify(mocks);
  }

  @Test
  public void lexerRulesNotAllowed() throws Exception {

    Grammar grammar = createMock(Grammar.class);
    LexerRule rule = createMock(LexerRule.class);
    EClass eClass = createMock(EClass.class);
    EStructuralFeature feature = createMock(EStructuralFeature.class);
    Antlr4Validator validator = PowerMock.createPartialMock(Antlr4Validator.class, "error");

    expect(grammar.getType()).andReturn(GrammarType.PARSER);

    expect(rule.eContainer()).andReturn(grammar);
    expect(rule.eClass()).andReturn(eClass);
    expect(rule.getName()).andReturn("RULE");
    expect(eClass.getEStructuralFeature("name")).andReturn(feature);

    PowerMock.expectPrivate(validator, "error", "lexer rule 'RULE' not allowed in parser",
        rule, feature);

    Object[] mocks = {grammar, rule, validator, eClass, feature };

    replay(mocks);

    validator.lexerRulesNotAllowed(rule);

    verify(mocks);
  }

  @Test
  public void repeatedOptionsPrequel() throws Exception {
    repeatedPrequel(Options.class, "options");
  }

  @Test
  public void repeatedImportsPrequel() throws Exception {
    repeatedPrequel(Imports.class, "import");
  }

  @Test
  public void repeatedV3TokensPrequel() throws Exception {
    repeatedPrequel(V3Tokens.class, "tokens");
  }

  @Test
  public void repeatedV4TokensPrequel() throws Exception {
    repeatedPrequel(V4Tokens.class, "tokens");
  }

  private void repeatedPrequel(final Class<? extends PrequelConstruct> clazz, final String label)
      throws Exception {
    EList<PrequelConstruct> prequels = new BasicEList<PrequelConstruct>();

    Grammar grammar = createMock(Grammar.class);
    PrequelConstruct prequel1 = createMock(clazz);
    PrequelConstruct prequel2 = createMock(clazz);
    EClass eClass = createMock(EClass.class);
    Antlr4Validator validator = PowerMock.createPartialMock(Antlr4Validator.class, "error");

    expect(grammar.getPrequels()).andReturn(prequels);

    prequels.add(prequel1);
    prequels.add(prequel2);

    PowerMock.expectPrivate(validator, "error",
        "repeated grammar prequel spec: '" + label + "'; please merge",
        prequel2,
        0,
        label.length());

    Object[] mocks = {grammar, validator, eClass, prequel1, prequel2 };

    replay(mocks);

    validator.repeatedPrequel(grammar);

    verify(mocks);
  }

  @Test
  public void checkRuleRedefinition() throws Exception {
    EList<Rule> rules = new BasicEList<Rule>();

    Grammar grammar = createMock(Grammar.class);
    Rule rule1 = createMock(ParserRule.class);
    Rule rule2 = createMock(ParserRule.class);
    EClass eClass = createMock(EClass.class);
    EStructuralFeature feature = createMock(EStructuralFeature.class);
    Antlr4Validator validator = PowerMock.createPartialMock(Antlr4Validator.class, "error");

    expect(grammar.getRules()).andReturn(rules);
    expect(grammar.getModes()).andReturn(new BasicEList<Mode>());

    expect(rule1.getName()).andReturn("rule");

    expect(rule2.getName()).andReturn("rule");
    expect(rule2.eClass()).andReturn(eClass);

    expect(eClass.getEStructuralFeature("name")).andReturn(feature);

    PowerMock.expectPrivate(validator, "error", "rule 'rule' redefinition", rule2, feature);

    rules.add(rule1);
    rules.add(rule2);

    Object[] mocks = {grammar, validator, eClass, rule1, rule2, feature };

    replay(mocks);

    validator.checkRuleRedefinition(grammar);

    verify(mocks);
  }

  @Test
  public void checkRuleRedefinitionInModes() throws Exception {
    EList<Mode> modes = new BasicEList<Mode>();
    EList<LexerRule> rules = new BasicEList<LexerRule>();

    Grammar grammar = createMock(Grammar.class);
    LexerRule rule1 = createMock(LexerRule.class);
    LexerRule rule2 = createMock(LexerRule.class);
    EClass eClass = createMock(EClass.class);
    EStructuralFeature feature = createMock(EStructuralFeature.class);
    Mode mode = createMock(Mode.class);
    Antlr4Validator validator = PowerMock.createPartialMock(Antlr4Validator.class, "error");

    expect(grammar.getRules()).andReturn(new BasicEList<Rule>());
    expect(grammar.getModes()).andReturn(modes);

    expect(mode.getRules()).andReturn(rules);

    expect(rule1.getName()).andReturn("Rule");

    expect(rule2.getName()).andReturn("Rule");
    expect(rule2.eClass()).andReturn(eClass);

    expect(eClass.getEStructuralFeature("name")).andReturn(feature);

    PowerMock.expectPrivate(validator, "error", "rule 'Rule' redefinition", rule2, feature);

    rules.add(rule1);
    rules.add(rule2);

    modes.add(mode);

    Object[] mocks = {grammar, validator, eClass, rule1, rule2, feature, mode };

    replay(mocks);

    validator.checkRuleRedefinition(grammar);

    verify(mocks);
  }

  @Test
  public void unsupportedOption() throws Exception {

    Option option = createMock(Option.class);
    EClass eClass = createMock(EClass.class);
    EStructuralFeature feature = createMock(EStructuralFeature.class);
    Antlr4Validator validator = PowerMock.createPartialMock(Antlr4Validator.class, "warning");

    expect(option.getName()).andReturn("Some");
    expect(option.eClass()).andReturn(eClass);
    expect(eClass.getEStructuralFeature("name")).andReturn(feature);

    PowerMock.expectPrivate(validator, "warning", "unsupported option 'Some'",
        option, feature);

    Object[] mocks = {option, validator, eClass, feature };

    replay(mocks);

    validator.unsupportedOption(option);

    verify(mocks);
  }

  @Test
  public void superClassOption() throws Exception {
    validOption("superClass");
  }

  @Test
  public void tokenLabelTypeOption() throws Exception {
    validOption("TokenLabelType");
  }

  @Test
  public void tokenVocabOption() throws Exception {
    validOption("tokenVocab");
  }

  @Test
  public void languageOption() throws Exception {
    validOption("language");
  }

  private void validOption(final String name) throws Exception {
    Option option = createMock(Option.class);

    expect(option.getName()).andReturn(name);

    replay(option);

    new Antlr4Validator().unsupportedOption(option);

    verify(option);
  }

  @Test
  public void checkDuplicatedV3Token() throws Exception {
    EList<Rule> rules = new BasicEList<Rule>();
    EList<PrequelConstruct> prequels = new BasicEList<PrequelConstruct>();
    EList<V3Token> tokenList = new BasicEList<V3Token>();

    Grammar grammar = createMock(Grammar.class);
    LexerRule rule = createMock(LexerRule.class);
    V3Tokens tokens = createMock(V3Tokens.class);
    V3Token v3Token = createMock(V3Token.class);
    EClass eClass = createMock(EClass.class);
    EStructuralFeature feature = createMock(EStructuralFeature.class);
    Antlr4Validator validator = PowerMock.createPartialMock(Antlr4Validator.class, "warning");

    expect(grammar.getRules()).andReturn(rules);
    expect(grammar.getPrequels()).andReturn(prequels);

    expect(tokens.getTokens()).andReturn(tokenList);

    expect(rule.getName()).andReturn("R");

    expect(v3Token.getId()).andReturn("R");

    expect(v3Token.eClass()).andReturn(eClass);
    expect(eClass.getEStructuralFeature("id")).andReturn(feature);

    PowerMock.expectPrivate(validator, "warning", "token name 'R' is already defined",
        v3Token, feature);

    Object[] mocks = {grammar, validator, eClass, feature, rule, tokens, v3Token };

    replay(mocks);

    prequels.add(tokens);
    rules.add(rule);
    tokenList.add(v3Token);

    validator.checkDuplicatedToken(grammar);

    verify(mocks);
  }

  @Test
  public void checkDuplicatedV4Token() throws Exception {
    EList<Rule> rules = new BasicEList<Rule>();
    EList<PrequelConstruct> prequels = new BasicEList<PrequelConstruct>();
    EList<V4Token> tokenList = new BasicEList<V4Token>();

    Grammar grammar = createMock(Grammar.class);
    LexerRule rule = createMock(LexerRule.class);
    V4Tokens tokens = createMock(V4Tokens.class);
    V4Token v4Token = createMock(V4Token.class);
    EClass eClass = createMock(EClass.class);
    EStructuralFeature feature = createMock(EStructuralFeature.class);
    Antlr4Validator validator = PowerMock.createPartialMock(Antlr4Validator.class, "warning");

    expect(grammar.getRules()).andReturn(rules);
    expect(grammar.getPrequels()).andReturn(prequels);

    expect(tokens.getTokens()).andReturn(tokenList);

    expect(rule.getName()).andReturn("R");

    expect(v4Token.getName()).andReturn("R");

    expect(v4Token.eClass()).andReturn(eClass);
    expect(eClass.getEStructuralFeature("name")).andReturn(feature);

    PowerMock.expectPrivate(validator, "warning", "token name 'R' is already defined",
        v4Token, feature);

    Object[] mocks = {grammar, validator, eClass, feature, rule, tokens, v4Token };

    replay(mocks);

    prequels.add(tokens);
    rules.add(rule);
    tokenList.add(v4Token);

    validator.checkDuplicatedToken(grammar);

    verify(mocks);
  }

  @Test
  public void v3TokenMustStartWithUppercaseLetter() throws Exception {
    V3Token token = createMock(V3Token.class);
    EClass eClass = createMock(EClass.class);
    EStructuralFeature feature = createMock(EStructuralFeature.class);
    Antlr4Validator validator = PowerMock.createPartialMock(Antlr4Validator.class, "error");

    expect(token.getId()).andReturn("t");

    expect(token.eClass()).andReturn(eClass);
    expect(eClass.getEStructuralFeature("id")).andReturn(feature);

    PowerMock.expectPrivate(validator, "error",
        "token names must start with an uppercase letter: t",
        token, feature);

    Object[] mocks = {token, feature, eClass };

    replay(mocks);

    validator.tokenNamesMustStartWithUppercaseLetter(token);

    verify(mocks);
  }

  @Test
  public void v4TokenMustStartWithUppercaseLetter() throws Exception {
    V4Token token = createMock(V4Token.class);
    EClass eClass = createMock(EClass.class);
    EStructuralFeature feature = createMock(EStructuralFeature.class);
    Antlr4Validator validator = PowerMock.createPartialMock(Antlr4Validator.class, "error");

    expect(token.getName()).andReturn("t");

    expect(token.eClass()).andReturn(eClass);
    expect(eClass.getEStructuralFeature("name")).andReturn(feature);

    PowerMock.expectPrivate(validator, "error",
        "token names must start with an uppercase letter: t",
        token, feature);

    Object[] mocks = {token, feature, eClass };

    replay(mocks);

    validator.tokenNamesMustStartWithUppercaseLetter(token);

    verify(mocks);
  }

  @Test
  public void checkQualifiedTokenElementOptions() throws Exception {
    EList<ElementOption> optionList = new BasicEList<ElementOption>();

    EObject container = createMock(Terminal.class);
    ElementOptions options = createMock(ElementOptions.class);
    ElementOption option = createMock(ElementOption.class);
    EClass eClass = createMock(EClass.class);
    EStructuralFeature feature = createMock(EStructuralFeature.class);
    Antlr4Validator validator = PowerMock.createPartialMock(Antlr4Validator.class, "warning");

    expect(options.eContainer()).andReturn(container);
    expect(options.getOptions()).andReturn(optionList);

    expect(option.getQualifiedId()).andReturn(null);
    expect(option.getId()).andReturn("some");
    optionList.add(option);

    expect(option.eClass()).andReturn(eClass);
    expect(eClass.getEStructuralFeature("id")).andReturn(feature);

    PowerMock.expectPrivate(validator, "warning", "unknown option: some", option, feature);

    Object[] mocks = {options, option, container, feature, eClass };

    replay(mocks);

    validator.checkElementOptions(options);

    verify(mocks);
  }

  @Test
  public void checkSimpleTokenElementOptions() throws Exception {
    EList<ElementOption> optionList = new BasicEList<ElementOption>();
    EList<String> names = new BasicEList<String>();
    names.add("some");

    EObject container = createMock(Terminal.class);
    ElementOptions options = createMock(ElementOptions.class);
    ElementOption option = createMock(ElementOption.class);
    QualifiedId qualifiedId = createMock(QualifiedId.class);
    EClass eClass = createMock(EClass.class);
    EStructuralFeature feature = createMock(EStructuralFeature.class);
    Antlr4Validator validator = PowerMock.createPartialMock(Antlr4Validator.class, "warning");

    expect(options.eContainer()).andReturn(container);
    expect(options.getOptions()).andReturn(optionList);

    expect(option.getQualifiedId()).andReturn(qualifiedId);
    expect(qualifiedId.getName()).andReturn(names);
    optionList.add(option);

    expect(option.eClass()).andReturn(eClass);
    expect(eClass.getEStructuralFeature("qualifiedId")).andReturn(feature);

    PowerMock.expectPrivate(validator, "warning", "unknown option: some", option, feature);

    Object[] mocks = {options, option, container, feature, eClass, qualifiedId };

    replay(mocks);

    validator.checkElementOptions(options);

    verify(mocks);
  }

  @Test
  public void checkQualifiedWilcardElementOptions() throws Exception {
    EList<ElementOption> optionList = new BasicEList<ElementOption>();

    EObject container = createMock(Wildcard.class);
    ElementOptions options = createMock(ElementOptions.class);
    ElementOption option = createMock(ElementOption.class);
    EClass eClass = createMock(EClass.class);
    EStructuralFeature feature = createMock(EStructuralFeature.class);
    Antlr4Validator validator = PowerMock.createPartialMock(Antlr4Validator.class, "warning");

    expect(options.eContainer()).andReturn(container);
    expect(options.getOptions()).andReturn(optionList);

    expect(option.getQualifiedId()).andReturn(null);
    expect(option.getId()).andReturn("some");
    optionList.add(option);

    expect(option.eClass()).andReturn(eClass);
    expect(eClass.getEStructuralFeature("id")).andReturn(feature);

    PowerMock.expectPrivate(validator, "warning", "unknown option: some", option, feature);

    Object[] mocks = {options, option, container, feature, eClass };

    replay(mocks);

    validator.checkElementOptions(options);

    verify(mocks);
  }

  @Test
  public void checkSimpleWilcardElementOptions() throws Exception {
    EList<ElementOption> optionList = new BasicEList<ElementOption>();
    EList<String> names = new BasicEList<String>();
    names.add("some");

    EObject container = createMock(Wildcard.class);
    ElementOptions options = createMock(ElementOptions.class);
    ElementOption option = createMock(ElementOption.class);
    QualifiedId qualifiedId = createMock(QualifiedId.class);
    EClass eClass = createMock(EClass.class);
    EStructuralFeature feature = createMock(EStructuralFeature.class);
    Antlr4Validator validator = PowerMock.createPartialMock(Antlr4Validator.class, "warning");

    expect(options.eContainer()).andReturn(container);
    expect(options.getOptions()).andReturn(optionList);

    expect(option.getQualifiedId()).andReturn(qualifiedId);
    expect(qualifiedId.getName()).andReturn(names);
    optionList.add(option);

    expect(option.eClass()).andReturn(eClass);
    expect(eClass.getEStructuralFeature("qualifiedId")).andReturn(feature);

    PowerMock.expectPrivate(validator, "warning", "unknown option: some", option, feature);

    Object[] mocks = {options, option, container, feature, eClass, qualifiedId };

    replay(mocks);

    validator.checkElementOptions(options);

    verify(mocks);
  }

  @Test
  public void checkQualifiedRuleReferenceElementOptions() throws Exception {
    EList<ElementOption> optionList = new BasicEList<ElementOption>();

    EObject container = createMock(RuleRef.class);
    ElementOptions options = createMock(ElementOptions.class);
    ElementOption option = createMock(ElementOption.class);
    EClass eClass = createMock(EClass.class);
    EStructuralFeature feature = createMock(EStructuralFeature.class);
    Antlr4Validator validator = PowerMock.createPartialMock(Antlr4Validator.class, "warning");

    expect(options.eContainer()).andReturn(container);
    expect(options.getOptions()).andReturn(optionList);

    expect(option.getQualifiedId()).andReturn(null);
    expect(option.getId()).andReturn("some");
    optionList.add(option);

    expect(option.eClass()).andReturn(eClass);
    expect(eClass.getEStructuralFeature("id")).andReturn(feature);

    PowerMock.expectPrivate(validator, "warning", "unknown option: some", option, feature);

    Object[] mocks = {options, option, container, feature, eClass };

    replay(mocks);

    validator.checkElementOptions(options);

    verify(mocks);
  }

  @Test
  public void checkSimpleRuleReferenceElementOptions() throws Exception {
    EList<ElementOption> optionList = new BasicEList<ElementOption>();
    EList<String> names = new BasicEList<String>();
    names.add("some");

    EObject container = createMock(RuleRef.class);
    ElementOptions options = createMock(ElementOptions.class);
    ElementOption option = createMock(ElementOption.class);
    QualifiedId qualifiedId = createMock(QualifiedId.class);
    EClass eClass = createMock(EClass.class);
    EStructuralFeature feature = createMock(EStructuralFeature.class);
    Antlr4Validator validator = PowerMock.createPartialMock(Antlr4Validator.class, "warning");

    expect(options.eContainer()).andReturn(container);
    expect(options.getOptions()).andReturn(optionList);

    expect(option.getQualifiedId()).andReturn(qualifiedId);
    expect(qualifiedId.getName()).andReturn(names);
    optionList.add(option);

    expect(option.eClass()).andReturn(eClass);
    expect(eClass.getEStructuralFeature("qualifiedId")).andReturn(feature);

    PowerMock.expectPrivate(validator, "warning", "unknown option: some", option, feature);

    Object[] mocks = {options, option, container, feature, eClass, qualifiedId };

    replay(mocks);

    validator.checkElementOptions(options);

    verify(mocks);
  }

  @Test
  public void checkQualifiedActionElementElementOptions() throws Exception {
    EList<ElementOption> optionList = new BasicEList<ElementOption>();

    EObject container = createMock(ActionElement.class);
    ElementOptions options = createMock(ElementOptions.class);
    ElementOption option = createMock(ElementOption.class);
    EClass eClass = createMock(EClass.class);
    EStructuralFeature feature = createMock(EStructuralFeature.class);
    Antlr4Validator validator = PowerMock.createPartialMock(Antlr4Validator.class, "warning");

    expect(options.eContainer()).andReturn(container);
    expect(options.getOptions()).andReturn(optionList);

    expect(option.getQualifiedId()).andReturn(null);
    expect(option.getId()).andReturn("some");
    optionList.add(option);

    expect(option.eClass()).andReturn(eClass);
    expect(eClass.getEStructuralFeature("id")).andReturn(feature);

    PowerMock.expectPrivate(validator, "warning", "unknown option: some", option, feature);

    Object[] mocks = {options, option, container, feature, eClass };

    replay(mocks);

    validator.checkElementOptions(options);

    verify(mocks);
  }

  @Test
  public void checkSimpleActionElementElementOptions() throws Exception {
    EList<ElementOption> optionList = new BasicEList<ElementOption>();
    EList<String> names = new BasicEList<String>();
    names.add("some");

    EObject container = createMock(ActionElement.class);
    ElementOptions options = createMock(ElementOptions.class);
    ElementOption option = createMock(ElementOption.class);
    QualifiedId qualifiedId = createMock(QualifiedId.class);
    EClass eClass = createMock(EClass.class);
    EStructuralFeature feature = createMock(EStructuralFeature.class);
    Antlr4Validator validator = PowerMock.createPartialMock(Antlr4Validator.class, "warning");

    expect(options.eContainer()).andReturn(container);
    expect(options.getOptions()).andReturn(optionList);

    expect(option.getQualifiedId()).andReturn(qualifiedId);
    expect(qualifiedId.getName()).andReturn(names);
    optionList.add(option);

    expect(option.eClass()).andReturn(eClass);
    expect(eClass.getEStructuralFeature("qualifiedId")).andReturn(feature);

    PowerMock.expectPrivate(validator, "warning", "unknown option: some", option, feature);

    Object[] mocks = {options, option, container, feature, eClass, qualifiedId };

    replay(mocks);

    validator.checkElementOptions(options);

    verify(mocks);
  }

  @Test
  public void checkQualifiedNoElementOptions() throws Exception {
    EObject container = createMock(NotSet.class);
    ElementOptions options = createMock(ElementOptions.class);

    expect(options.eContainer()).andReturn(container);

    Object[] mocks = {options, container };

    replay(mocks);

    new Antlr4Validator().checkElementOptions(options);

    verify(mocks);
  }

  @Test
  public void checkSimpleNoElementOptions() throws Exception {
    EList<String> names = new BasicEList<String>();
    names.add("some");

    EObject container = createMock(NotSet.class);
    ElementOptions options = createMock(ElementOptions.class);

    expect(options.eContainer()).andReturn(container);

    Object[] mocks = {options, container };

    replay(mocks);

    new Antlr4Validator().checkElementOptions(options);

    verify(mocks);
  }

  @Test
  public void elementOptions() {
    assertEquals(Sets.newHashSet("assoc"), Antlr4Validator.TOKEN_OPTIONS);
    assertEquals(Sets.newHashSet("superClass", "TokenLabelType", "tokenVocab", "language"),
        Antlr4Validator.OPTIONS);
    assertEquals(Sets.newHashSet("fail"), Antlr4Validator.RULEREF_OPTIONS);
    assertEquals(Sets.newHashSet("fail"), Antlr4Validator.SEMPRED_OPTIONS);
  }

  @Test
  public void checkUnknownAttribute() throws Exception {
    EList<Rule> rules = new BasicEList<Rule>();
    EList<EObject> ruleBodyList = new BasicEList<EObject>();

    String args = "[Arg a, Arg b]";
    String returnBody = "[Return r;]";
    String localsBody = "{\nLocal l;\n}";

    Grammar grammar = createMock(Grammar.class);
    ParserRule rule1 = createMock(ParserRule.class);
    Return returns = createMock(Return.class);
    LocalVars locals = createMock(LocalVars.class);
    RuleBlock ruleBody = createMock(RuleBlock.class);
    LabeledElement labeledElement = createMock(LabeledElement.class);
    Terminal terminal = createMock(Terminal.class);
    LexerRule ID = createMock(LexerRule.class);
    ActionElement actionElement = createMock(ActionElement.class);
    ActionOption actionOption = createMock(ActionOption.class);
    Antlr4Validator validator = PowerMock.createPartialMock(Antlr4Validator.class, "error");

    expect(grammar.getRules()).andReturn(rules).times(2);

    expect(rule1.getName()).andReturn("rule1");
    expect(rule1.getArgs()).andReturn(args);
    expect(rule1.getReturn()).andReturn(returns);
    expect(rule1.getLocals()).andReturn(locals);
    expect(rule1.getBody()).andReturn(ruleBody).times(3);
    expect(rule1.eContainer()).andReturn(grammar);

    expect(returns.getBody()).andReturn(returnBody);

    expect(locals.getBody()).andReturn(localsBody);

    ruleBodyList.add(labeledElement);
    ruleBodyList.add(terminal);
    ruleBodyList.add(actionElement);
    ruleBodyList.add(actionOption);

    expect(ruleBody.eAllContents()).andReturn(newTreeIterator(ruleBodyList));
    expect(ruleBody.eAllContents()).andReturn(newTreeIterator(ruleBodyList));
    expect(ruleBody.eAllContents()).andReturn(newTreeIterator(ruleBodyList));

    expect(terminal.getReference()).andReturn(ID);

    expect(labeledElement.getName()).andReturn("var");

    expect(ID.getName()).andReturn("ID");

    expect(actionElement.getBody()).andReturn("{$undefined = 0;}");

    expect(actionOption.getValue()).andReturn("{$z = 0;}");

    PowerMock.expectPrivate(validator, "error",
        "unknown attribute reference 'undefined' in '$undefined'",
        actionElement, 1, 10);

    PowerMock.expectPrivate(validator, "error",
        "unknown attribute reference 'z' in '$z'", actionOption, 1, 2);

    rules.add(rule1);

    Object[] mocks = {grammar, validator, rule1, returns, locals, ruleBody, labeledElement,
        terminal, ID, actionElement, actionOption };

    replay(mocks);

    validator.checkUnknownAttribute(grammar);

    verify(mocks);
  }

  @Test
  public void checkValidAttribute() throws Exception {
    EList<Rule> rules = new BasicEList<Rule>();
    EList<EObject> ruleBodyList = new BasicEList<EObject>();

    String args = "[Arg a, Arg b]";
    String returnBody = "[Return r;]";
    String localsBody = "{\nLocal l;\n}";

    Grammar grammar = createMock(Grammar.class);
    ParserRule rule1 = createMock(ParserRule.class);
    Return returns = createMock(Return.class);
    LocalVars locals = createMock(LocalVars.class);
    RuleBlock ruleBody = createMock(RuleBlock.class);
    LabeledElement labeledElement = createMock(LabeledElement.class);
    Terminal terminal = createMock(Terminal.class);
    LexerRule ID = createMock(LexerRule.class);
    ActionElement actionElement = createMock(ActionElement.class);
    ActionOption actionOption = createMock(ActionOption.class);
    Antlr4Validator validator = PowerMock.createPartialMock(Antlr4Validator.class, "error");

    expect(grammar.getRules()).andReturn(rules).times(2);

    expect(rule1.getName()).andReturn("rule1");
    expect(rule1.getArgs()).andReturn(args);
    expect(rule1.getReturn()).andReturn(returns);
    expect(rule1.getLocals()).andReturn(locals);
    expect(rule1.getBody()).andReturn(ruleBody).times(3);
    expect(rule1.eContainer()).andReturn(grammar);

    expect(returns.getBody()).andReturn(returnBody);

    expect(locals.getBody()).andReturn(localsBody);

    ruleBodyList.add(labeledElement);
    ruleBodyList.add(terminal);
    ruleBodyList.add(actionElement);
    ruleBodyList.add(actionOption);

    expect(ruleBody.eAllContents()).andReturn(newTreeIterator(ruleBodyList));
    expect(ruleBody.eAllContents()).andReturn(newTreeIterator(ruleBodyList));
    expect(ruleBody.eAllContents()).andReturn(newTreeIterator(ruleBodyList));

    expect(terminal.getReference()).andReturn(ID);

    expect(labeledElement.getName()).andReturn("var");

    expect(ID.getName()).andReturn("ID");

    expect(actionElement.getBody()).andReturn("{$a = 0; $b = 3; text = $ID.text;}");

    expect(actionOption.getValue()).andReturn("{$r = 0; $l = null; v = $var;}");

    rules.add(rule1);

    Object[] mocks = {grammar, validator, rule1, returns, locals, ruleBody, labeledElement,
        terminal, ID, actionElement, actionOption };

    replay(mocks);

    validator.checkUnknownAttribute(grammar);

    verify(mocks);
  }

  @Test
  public void missingArgumentsOnRuleReference() throws Exception {
    ParserRule reference = createMock(ParserRule.class);
    RuleRef ruleRef = createMock(RuleRef.class);
    EClass eClass = createMock(EClass.class);
    EStructuralFeature feature = createMock(EStructuralFeature.class);
    Antlr4Validator validator = PowerMock.createPartialMock(Antlr4Validator.class, "error");

    expect(ruleRef.getReference()).andReturn(reference);
    expect(ruleRef.getArgs()).andReturn(null);
    expect(ruleRef.eClass()).andReturn(eClass);

    expect(reference.getName()).andReturn("rule");
    expect(reference.getArgs()).andReturn("[int a, int b]");

    expect(eClass.getEStructuralFeature("reference")).andReturn(feature);

    PowerMock.expectPrivate(validator, "error", "missing arguments(s) on rule reference: rule",
        ruleRef, feature);

    Object[] mocks = {ruleRef, validator, eClass, feature, reference };

    replay(mocks);

    validator.checkRuleParameters(ruleRef);

    verify(mocks);
  }

  @Test
  public void ruleHasNoDefinedParameters() throws Exception {
    ParserRule reference = createMock(ParserRule.class);
    RuleRef ruleRef = createMock(RuleRef.class);
    EClass eClass = createMock(EClass.class);
    EStructuralFeature feature = createMock(EStructuralFeature.class);
    Antlr4Validator validator = PowerMock.createPartialMock(Antlr4Validator.class, "error");

    expect(ruleRef.getReference()).andReturn(reference);
    expect(ruleRef.getArgs()).andReturn("[a, b]");
    expect(ruleRef.eClass()).andReturn(eClass);

    expect(reference.getName()).andReturn("rule");
    expect(reference.getArgs()).andReturn(null);

    expect(eClass.getEStructuralFeature("args")).andReturn(feature);

    PowerMock.expectPrivate(validator, "error", "rule 'rule' has no defined parameters",
        ruleRef, feature);

    Object[] mocks = {ruleRef, validator, eClass, feature, reference };

    replay(mocks);

    validator.checkRuleParameters(ruleRef);

    verify(mocks);
  }

  private static TreeIterator<EObject> newTreeIterator(final EList<EObject> ruleBodyList) {
    return new TreeIterator<EObject>() {
      Iterator<EObject> it = (ruleBodyList).iterator();

      @Override
      public boolean hasNext() {
        return it.hasNext();
      }

      @Override
      public EObject next() {
        return it.next();
      }

      @Override
      public void remove() {
      }

      @Override
      public void prune() {
      }
    };
  }

  @Test
  public void checkEmptyLexerGrammar() throws Exception {
    EList<Rule> rules = new BasicEList<Rule>();

    Grammar grammar = createMock(Grammar.class);
    EClass eClass = createMock(EClass.class);
    EStructuralFeature feature = createMock(EStructuralFeature.class);
    Antlr4Validator validator = PowerMock.createPartialMock(Antlr4Validator.class, "error");

    expect(grammar.getType()).andReturn(GrammarType.LEXER);
    expect(grammar.getRules()).andReturn(rules);
    expect(grammar.getName()).andReturn("G");
    expect(grammar.eClass()).andReturn(eClass);
    expect(eClass.getEStructuralFeature("name")).andReturn(feature);

    PowerMock.expectPrivate(validator, "error", "grammar 'G' has no rules",
        grammar, feature);

    Object[] mocks = {grammar, validator, eClass, feature };

    replay(mocks);

    validator.checkEmptyRules(grammar);

    verify(mocks);
  }

  @Test
  public void checkEmptyLexerGrammarWithParserRules() throws Exception {
    EList<Rule> rules = new BasicEList<Rule>();

    Grammar grammar = createMock(Grammar.class);
    Rule rule = createMock(Rule.class);
    EClass eClass = createMock(EClass.class);
    EStructuralFeature feature = createMock(EStructuralFeature.class);
    Antlr4Validator validator = PowerMock.createPartialMock(Antlr4Validator.class, "error");

    expect(grammar.getType()).andReturn(GrammarType.LEXER);
    expect(grammar.getRules()).andReturn(rules);
    expect(grammar.getName()).andReturn("G");
    expect(grammar.eClass()).andReturn(eClass);
    expect(eClass.getEStructuralFeature("name")).andReturn(feature);

    PowerMock.expectPrivate(validator, "error", "grammar 'G' has no rules",
        grammar, feature);

    rules.add(rule);

    Object[] mocks = {grammar, validator, eClass, feature, rule };

    replay(mocks);

    validator.checkEmptyRules(grammar);

    verify(mocks);
  }

  @Test
  public void checkEmptyGrammar() throws Exception {
    EList<Rule> rules = new BasicEList<Rule>();

    Grammar grammar = createMock(Grammar.class);
    EClass eClass = createMock(EClass.class);
    EStructuralFeature feature = createMock(EStructuralFeature.class);
    Antlr4Validator validator = PowerMock.createPartialMock(Antlr4Validator.class, "error");

    expect(grammar.getType()).andReturn(GrammarType.DEFAULT);
    expect(grammar.getRules()).andReturn(rules);
    expect(grammar.getName()).andReturn("G");
    expect(grammar.eClass()).andReturn(eClass);
    expect(eClass.getEStructuralFeature("name")).andReturn(feature);

    PowerMock.expectPrivate(validator, "error", "grammar 'G' has no rules",
        grammar, feature);

    Object[] mocks = {grammar, validator, eClass, feature };

    replay(mocks);

    validator.checkEmptyRules(grammar);

    verify(mocks);
  }

  @Test
  public void checkEmptyGrammarWithLexerRules() throws Exception {
    EList<Rule> rules = new BasicEList<Rule>();

    Grammar grammar = createMock(Grammar.class);
    Rule rule = createMock(LexerRule.class);
    EClass eClass = createMock(EClass.class);
    EStructuralFeature feature = createMock(EStructuralFeature.class);
    Antlr4Validator validator = PowerMock.createPartialMock(Antlr4Validator.class, "error");

    expect(grammar.getType()).andReturn(GrammarType.DEFAULT);
    expect(grammar.getRules()).andReturn(rules);
    expect(grammar.getName()).andReturn("G");
    expect(grammar.eClass()).andReturn(eClass);
    expect(eClass.getEStructuralFeature("name")).andReturn(feature);

    PowerMock.expectPrivate(validator, "error", "grammar 'G' has no rules",
        grammar, feature);

    rules.add(rule);

    Object[] mocks = {grammar, validator, eClass, feature, rule };

    replay(mocks);

    validator.checkEmptyRules(grammar);

    verify(mocks);
  }

  @Test
  public void v3Tokens() throws Exception {
    V3Tokens tokens = createMock(V3Tokens.class);
    Antlr4Validator validator = PowerMock.createPartialMock(Antlr4Validator.class, "warning");

    PowerMock.expectPrivate(validator, "warning",
        "tokens {A; B;}' syntax is now 'tokens {A, B}' in ANTLR 4",
        tokens, 0, "tokens".length());

    Object[] mocks = {tokens, validator };

    replay(mocks);

    validator.v3Tokens(tokens);

    verify(mocks);
  }

  @Test
  public void v3Token() throws Exception {
    V3Token token = createMock(V3Token.class);
    EClass eClass = createMock(EClass.class);
    EStructuralFeature feature = createMock(EStructuralFeature.class);

    expect(token.getValue()).andReturn("'ID'");
    expect(token.getId()).andReturn("ID");
    expect(token.eClass()).andReturn(eClass);

    expect(eClass.getEStructuralFeature("id")).andReturn(feature);

    Antlr4Validator validator = PowerMock.createPartialMock(Antlr4Validator.class, "error");

    PowerMock
        .expectPrivate(
            validator,
            "error",
            "assignments in tokens{} are not supported in ANTLR 4; use lexical rule 'ID: 'ID'' instead",
            token, feature);

    Object[] mocks = {token, validator, eClass, feature };

    replay(mocks);

    validator.v3Token(token);

    verify(mocks);
  }

  @Test
  public void emptyTokens() throws Exception {
    Grammar grammar = createMock(Grammar.class);
    EmptyTokens tokens = createMock(EmptyTokens.class);

    expect(tokens.eContainer()).andReturn(grammar);

    expect(grammar.getName()).andReturn("G");

    Antlr4Validator validator = PowerMock.createPartialMock(Antlr4Validator.class, "warning");

    PowerMock
        .expectPrivate(
            validator,
            "warning",
            "grammar 'G' has no tokens",
            tokens, 0, "tokens".length());

    Object[] mocks = {tokens, grammar, validator };

    replay(mocks);

    validator.emptyTokens(tokens);

    verify(mocks);
  }

  @Test
  public void deprecateGatedSemanticPredicate() throws Exception {
    ActionElement action = createMock(ActionElement.class);

    expect(action.getBody()).andReturn("{predicate}=>");

    Antlr4Validator validator = PowerMock.createPartialMock(Antlr4Validator.class, "warning");

    PowerMock
        .expectPrivate(
            validator,
            "warning",
            "{...}?=> explicitly gated semantic predicates are deprecated in ANTLR 4; use {...}? instead",
            action, 11, 2);

    Object[] mocks = {action, validator };

    replay(mocks);

    validator.deprecateGatedSemanticPredicate(action);

    verify(mocks);
  }

  @Test
  public void ruleNameConflict() throws Exception {
    Rule rule = createMock(ParserRule.class);
    EClass eClass = createMock(EClass.class);
    EStructuralFeature feature = createMock(EStructuralFeature.class);

    expect(rule.getName()).andReturn("rule");
    expect(rule.eClass()).andReturn(eClass);

    expect(eClass.getEStructuralFeature("name")).andReturn(feature);

    Antlr4Validator validator = PowerMock.createPartialMock(Antlr4Validator.class, "error");

    PowerMock
        .expectPrivate(
            validator,
            "error",
            "symbol 'rule' conflicts with generated code in target language or runtime",
            rule, feature);

    Object[] mocks = {rule, validator, eClass, feature };

    replay(mocks);

    validator.nameConflict(rule);

    verify(mocks);
  }

  @Test
  public void labelNameConflict() throws Exception {
    EList<Rule> rules = new BasicEList<Rule>();
    Grammar grammar = createMock(Grammar.class);
    LabeledAlt label = createMock(LabeledAlt.class);
    Rule rule = createMock(ParserRule.class);
    EClass eClass = createMock(EClass.class);
    EStructuralFeature feature = createMock(EStructuralFeature.class);

    expect(label.eContainer()).andReturn(grammar);
    expect(label.getLabel()).andReturn("div");
    expect(label.eClass()).andReturn(eClass);

    expect(grammar.getRules()).andReturn(rules);
    expect(grammar.eContainer()).andReturn(null);

    expect(rule.getName()).andReturn("div");

    expect(eClass.getEStructuralFeature("label")).andReturn(feature);

    Antlr4Validator validator = PowerMock.createPartialMock(Antlr4Validator.class, "error");

    PowerMock
        .expectPrivate(
            validator,
            "error",
            "rule alt label 'div' conflicts with rule 'div'",
            label, feature);

    Object[] mocks = {rule, validator, eClass, feature, label, grammar };

    rules.add(rule);

    replay(mocks);

    validator.nameConflict(label);

    verify(mocks);
  }
}
