package com.github.jknack.antlr4ide.services;

import static org.easymock.EasyMock.createMock;
import static org.easymock.EasyMock.expect;
import static org.easymock.EasyMock.replay;
import static org.easymock.EasyMock.verify;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;

import java.util.Arrays;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;

import org.eclipse.emf.common.util.BasicEList;
import org.eclipse.emf.common.util.EList;
import org.eclipse.emf.common.util.TreeIterator;
import org.eclipse.emf.ecore.EObject;
import org.junit.Test;

import com.github.jknack.antlr4ide.lang.Grammar;
import com.github.jknack.antlr4ide.lang.LexerRule;
import com.github.jknack.antlr4ide.lang.LexerRuleBlock;
import com.github.jknack.antlr4ide.lang.ParserRule;
import com.github.jknack.antlr4ide.lang.Rule;
import com.github.jknack.antlr4ide.lang.RuleBlock;
import com.github.jknack.antlr4ide.lang.Terminal;

public class ModelExtensionsTest {

  @Test
  public void ruleMapWithoutLiterals() {
    EList<Rule> rules = rules(parserRule("prog", null), lexerRule("WS", null));

    Grammar grammar = createMock(Grammar.class);
    expect(grammar.getRules()).andReturn(rules);

    Object[] mocks = {grammar };

    replay(mocks);
    replayRules(rules);

    Map<String, EObject> map = ModelExtensions.ruleMap(grammar, false);
    assertNotNull(map);
    assertNotNull(map.remove("prog"));
    assertNotNull(map.remove("WS"));
    assertTrue(map.isEmpty());

    verify(mocks);
    verifyRules(rules);
  }

  @Test
  public void ruleMapWithLiterals() {
    EList<Rule> rules = rules(parserRule("prog", literal("hello")),
        lexerRule("WS", lexerBlock("\"")));

    Grammar grammar = createMock(Grammar.class);
    expect(grammar.getRules()).andReturn(rules);

    Object[] mocks = {grammar };

    replay(mocks);
    replayRules(rules);

    Map<String, EObject> map = ModelExtensions.ruleMap(grammar, true);
    assertNotNull(map);
    assertNotNull(map.remove("prog"));
    assertNotNull(map.remove("WS"));
    assertNotNull(map.remove("'hello'"));
    assertNotNull(map.remove("'\"'"));
    assertTrue(map.isEmpty());

    verify(mocks);
    verifyRules(rules);
  }

  @Test
  public void literals() {
    EList<Rule> rules = rules(parserRule("prog", literal("hello")),
        lexerRule("WS", lexerBlock("\"")));

    Grammar grammar = createMock(Grammar.class);
    expect(grammar.getRules()).andReturn(rules);

    Object[] mocks = {grammar };

    replay(mocks);
    replayRules(rules);

    Set<String> literals = ModelExtensions.literals(grammar);
    assertNotNull(literals);
    assertNotNull(literals.remove("hello"));
    assertNotNull(literals.remove("\""));
    assertTrue(literals.isEmpty());

    verify(mocks);
  }

  @Test
  public void hash() {
    Rule e1 = createMock(ParserRule.class);
    Rule e2 = createMock(ParserRule.class);

    Grammar source1 = createMock(Grammar.class);
    expect(source1.eAllContents()).andReturn(newTreeIterator(elist(e1)));
    expect(source1.eAllContents()).andReturn(newTreeIterator(elist(e1)));
    expect(source1.eAllContents()).andReturn(newTreeIterator(elist(e1)));
    expect(source1.eAllContents()).andReturn(newTreeIterator(elist(e1)));

    Grammar source2 = createMock(Grammar.class);
    expect(source2.eAllContents()).andReturn(newTreeIterator(elist(e1, e2)));
    expect(source2.eAllContents()).andReturn(newTreeIterator(elist(e1, e2)));
    expect(source2.eAllContents()).andReturn(newTreeIterator(elist(e1, e2)));
    expect(source2.eAllContents()).andReturn(newTreeIterator(elist(e1, e2)));

    Object[] mocks = {source1, source2, e1, e2 };

    replay(mocks);

    assertTrue(ModelExtensions.hash(source1) != 0);
    assertEquals(ModelExtensions.hash(source1), ModelExtensions.hash(source1));

    assertTrue(ModelExtensions.hash(source2) != 0);
    assertEquals(ModelExtensions.hash(source2), ModelExtensions.hash(source2));

    assertTrue(ModelExtensions.hash(source1) != ModelExtensions.hash(source2));

    verify(mocks);
  }

  private RuleBlock literal(final String literal) {
    Terminal terminal = createMock(Terminal.class);
    expect(terminal.getLiteral()).andReturn(literal);

    EList<EObject> body = new BasicEList<EObject>();
    RuleBlock block = createMock(RuleBlock.class);

    body.add(terminal);

    expect(block.eAllContents()).andReturn(newTreeIterator(body));

    replay(terminal, block);

    return block;
  }

  private LexerRuleBlock lexerBlock(final String literal) {
    Terminal terminal = createMock(Terminal.class);
    expect(terminal.getLiteral()).andReturn(literal);

    EList<EObject> body = new BasicEList<EObject>();
    LexerRuleBlock block = createMock(LexerRuleBlock.class);

    body.add(terminal);

    expect(block.eAllContents()).andReturn(newTreeIterator(body));

    replay(terminal, block);

    return block;
  }

  private BasicEList<Rule> rules(final Rule... rules) {
    return new BasicEList<Rule>(Arrays.asList(rules));
  }

  private BasicEList<EObject> elist(final EObject... elements) {
    return new BasicEList<EObject>(Arrays.asList(elements));
  }

  private void replayRules(final EList<Rule> rules) {
    for (Rule rule : rules) {
      replay(rule);
    }
  }

  private void verifyRules(final EList<Rule> rules) {
    for (Rule rule : rules) {
      verify(rule);
    }
  }

  private Rule parserRule(final String name, final RuleBlock block) {
    ParserRule rule = createMock(ParserRule.class);

    expect(rule.getName()).andReturn(name);
    if (block != null) {
      expect(rule.getBody()).andReturn(block);
    }

    return rule;
  }

  private Rule lexerRule(final String name, final LexerRuleBlock block) {
    LexerRule rule = createMock(LexerRule.class);

    expect(rule.getName()).andReturn(name);
    if (block != null) {
      expect(rule.getBody()).andReturn(block);
    }

    return rule;
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
}
