package com.github.jknack.antlr4ide.scoping;

import static org.easymock.EasyMock.createMock;
import static org.easymock.EasyMock.eq;
import static org.easymock.EasyMock.expect;
import static org.easymock.EasyMock.isA;
import static org.easymock.EasyMock.replay;
import static org.easymock.EasyMock.verify;
import static org.junit.Assert.assertEquals;

import java.util.List;

import org.eclipse.emf.common.util.BasicEList;
import org.eclipse.emf.common.util.EList;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.xtext.scoping.IScope;
import org.eclipse.xtext.scoping.Scopes;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.powermock.api.easymock.PowerMock;
import org.powermock.core.classloader.annotations.PrepareForTest;
import org.powermock.modules.junit4.PowerMockRunner;

import com.github.jknack.antlr4ide.lang.EmptyTokens;
import com.github.jknack.antlr4ide.lang.Grammar;
import com.github.jknack.antlr4ide.lang.GrammarAction;
import com.github.jknack.antlr4ide.lang.Import;
import com.github.jknack.antlr4ide.lang.Imports;
import com.github.jknack.antlr4ide.lang.LexerRule;
import com.github.jknack.antlr4ide.lang.Mode;
import com.github.jknack.antlr4ide.lang.Option;
import com.github.jknack.antlr4ide.lang.Options;
import com.github.jknack.antlr4ide.lang.ParserRule;
import com.github.jknack.antlr4ide.lang.PrequelConstruct;
import com.github.jknack.antlr4ide.lang.Rule;
import com.github.jknack.antlr4ide.lang.TokenVocab;
import com.github.jknack.antlr4ide.lang.V3Token;
import com.github.jknack.antlr4ide.lang.V3Tokens;
import com.github.jknack.antlr4ide.lang.V4Token;
import com.github.jknack.antlr4ide.lang.V4Tokens;
import com.google.common.collect.Lists;

@RunWith(PowerMockRunner.class)
@PrepareForTest({Antlr4ScopeProvider.class, Scopes.class })
public class Antlr4ScopeProviderTest {

  @SuppressWarnings({"unchecked", "rawtypes" })
  @Test
  public void scopeForParserRule() {
    List<EObject> scopes = Lists.newArrayList();

    EList<Rule> rules = new BasicEList<Rule>();

    EList<PrequelConstruct> prequels = new BasicEList<PrequelConstruct>();

    Grammar grammar = createMock(Grammar.class);
    ParserRule rule = createMock(ParserRule.class);
    ParserRule ref = createMock(ParserRule.class);
    IScope scope = createMock(IScope.class);

    Antlr4ScopeProvider scopeProvider = PowerMock.createPartialMock(Antlr4ScopeProvider.class,
        "scopeFor", PrequelConstruct.class, List.class, Class.class);

    Class[] prequelTypes = {Imports.class, Options.class, V3Tokens.class, V4Tokens.class,
        EmptyTokens.class, GrammarAction.class };
    for (Class prequelType : prequelTypes) {
      PrequelConstruct prequel = createMock(prequelType);
      prequels.add(prequel);
      scopeProvider.scopeFor(eq(prequel), isA(List.class), eq(Rule.class));
    }

    rules.add(ref);

    scopes.add(ref);

    expect(rule.eContainer()).andReturn(grammar);

    expect(grammar.getRules()).andReturn(rules);
    expect(grammar.getPrequels()).andReturn(prequels);

    PowerMock.mockStatic(Scopes.class);

    expect(Scopes.scopeFor(eq(scopes), eq(Antlr4NameProvider.nameFn), eq(IScope.NULLSCOPE)))
        .andReturn(scope);

    Object[] mocks = {rule, grammar, scope };

    replay(mocks);
    PowerMock.replay(Scopes.class, scopeProvider);

    assertEquals(scope, scopeProvider.scopeFor(rule));

    verify(mocks);
    PowerMock.verify(Scopes.class, scopeProvider);
  }

  @SuppressWarnings({"unchecked", "rawtypes" })
  @Test
  public void scopeForLexerRule() {
    List<EObject> scopes = Lists.newArrayList();

    EList<Rule> rules = new BasicEList<Rule>();

    EList<PrequelConstruct> prequels = new BasicEList<PrequelConstruct>();

    EList<LexerRule> modeRules = new BasicEList<LexerRule>();
    EList<Mode> modes = new BasicEList<Mode>();

    Grammar grammar = createMock(Grammar.class);
    LexerRule rule = createMock(LexerRule.class);
    LexerRule ref = createMock(LexerRule.class);
    IScope scope = createMock(IScope.class);
    Mode mode = createMock(Mode.class);
    LexerRule modeRule = createMock(LexerRule.class);

    Antlr4ScopeProvider scopeProvider = PowerMock.createPartialMock(Antlr4ScopeProvider.class,
        "scopeFor", PrequelConstruct.class, List.class, Class.class);

    Class[] prequelTypes = {Imports.class, Options.class, V3Tokens.class, V4Tokens.class,
        EmptyTokens.class, GrammarAction.class };
    for (Class prequelType : prequelTypes) {
      PrequelConstruct prequel = createMock(prequelType);
      prequels.add(prequel);
      scopeProvider.scopeFor(eq(prequel), isA(List.class), eq(LexerRule.class));
    }

    rules.add(ref);

    modeRules.add(modeRule);
    modes.add(mode);

    scopes.add(ref);
    scopes.add(mode);
    scopes.add(modeRule);

    expect(rule.eContainer()).andReturn(grammar);

    expect(grammar.eContainer()).andReturn(null);
    expect(grammar.getRules()).andReturn(rules);
    expect(grammar.getPrequels()).andReturn(prequels);
    expect(grammar.getModes()).andReturn(modes);

    expect(mode.getRules()).andReturn(modeRules);

    PowerMock.mockStatic(Scopes.class);

    expect(Scopes.scopeFor(eq(scopes), eq(Antlr4NameProvider.nameFn), eq(IScope.NULLSCOPE)))
        .andReturn(scope);

    Object[] mocks = {rule, grammar, scope, mode, modeRule };

    replay(mocks);
    PowerMock.replay(Scopes.class, scopeProvider);

    assertEquals(scope, scopeProvider.scopeFor(rule));

    verify(mocks);
    PowerMock.verify(Scopes.class, scopeProvider);
  }

  @Test
  public void scopeForImports() {
    EList<Import> importList = new BasicEList<Import>();

    EList<Rule> rules = new BasicEList<Rule>();

    Imports imports = createMock(Imports.class);
    Import delegate = createMock(Import.class);
    Grammar grammar = createMock(Grammar.class);
    Rule r1 = createMock(ParserRule.class);
    Rule r2 = createMock(LexerRule.class);

    expect(imports.getImports()).andReturn(importList).times(3);

    expect(delegate.getImportURI()).andReturn(grammar).times(3);

    expect(grammar.getRules()).andReturn(rules).times(3);

    importList.add(delegate);

    rules.add(r1);
    rules.add(r2);

    Object[] mocks = {imports, delegate, grammar, r1, r2 };

    replay(mocks);

    List<EObject> ALL = Lists.newArrayList();
    new Antlr4ScopeProvider().scopeFor(imports, ALL, Rule.class);
    assertEquals(Lists.newArrayList(r1, r2), ALL);

    List<EObject> PARSER_RULES = Lists.newArrayList();
    new Antlr4ScopeProvider().scopeFor(imports, PARSER_RULES, ParserRule.class);
    assertEquals(Lists.newArrayList(r1), PARSER_RULES);

    List<EObject> LEXER_RULES = Lists.newArrayList();
    new Antlr4ScopeProvider().scopeFor(imports, LEXER_RULES, LexerRule.class);
    assertEquals(Lists.newArrayList(r2), LEXER_RULES);

    verify(mocks);
  }

  @Test
  public void scopeForOptions() {
    EList<Option> optionList = new BasicEList<Option>();
    EList<Rule> rules = new BasicEList<Rule>();
    EList<LexerRule> mRules = new BasicEList<LexerRule>();
    EList<Mode> modes = new BasicEList<Mode>();
    EList<PrequelConstruct> prequels = new BasicEList<PrequelConstruct>();

    Options options = createMock(Options.class);
    TokenVocab tokenVocab = createMock(TokenVocab.class);
    Grammar grammar = createMock(Grammar.class);
    Rule r1 = createMock(LexerRule.class);
    Mode mode = createMock(Mode.class);
    LexerRule mr1 = createMock(LexerRule.class);

    expect(options.getOptions()).andReturn(optionList);

    expect(tokenVocab.getImportURI()).andReturn(grammar);

    expect(grammar.getRules()).andReturn(rules);
    expect(grammar.getModes()).andReturn(modes);
    expect(grammar.getPrequels()).andReturn(prequels);

    expect(mode.getRules()).andReturn(mRules);

    optionList.add(tokenVocab);

    rules.add(r1);
    modes.add(mode);
    mRules.add(mr1);

    Object[] mocks = {options, tokenVocab, grammar, r1, mode, mr1 };

    replay(mocks);

    List<EObject> scopes = Lists.newArrayList();
    new Antlr4ScopeProvider().scopeFor(options, scopes, LexerRule.class);
    assertEquals(Lists.<EObject> newArrayList(r1, mode, mr1), scopes);

    verify(mocks);
  }

  @Test
  public void scopeForV3Tokens() {
    EList<V3Token> tokenList = new BasicEList<V3Token>();

    V3Tokens tokens = createMock(V3Tokens.class);
    V3Token token = createMock(V3Token.class);

    expect(tokens.getTokens()).andReturn(tokenList);
    tokenList.add(token);

    Object[] mocks = {tokens, token };

    replay(mocks);

    List<EObject> scopes = Lists.newArrayList();
    new Antlr4ScopeProvider().scopeFor(tokens, scopes, Rule.class);
    assertEquals(Lists.newArrayList(token), scopes);

    verify(mocks);
  }

  @Test
  public void scopeForV4Tokens() {
    EList<V4Token> tokenList = new BasicEList<V4Token>();

    V4Tokens tokens = createMock(V4Tokens.class);
    V4Token token = createMock(V4Token.class);

    expect(tokens.getTokens()).andReturn(tokenList);
    tokenList.add(token);

    Object[] mocks = {tokens, token };

    replay(mocks);

    List<EObject> scopes = Lists.newArrayList();
    new Antlr4ScopeProvider().scopeFor(tokens, scopes, Rule.class);
    assertEquals(Lists.newArrayList(token), scopes);

    verify(mocks);
  }
}
