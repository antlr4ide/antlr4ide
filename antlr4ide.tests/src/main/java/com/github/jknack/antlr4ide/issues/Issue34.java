package com.github.jknack.antlr4ide.issues;

import static org.easymock.EasyMock.createMock;
import static org.easymock.EasyMock.expect;
import static org.easymock.EasyMock.replay;
import static org.easymock.EasyMock.verify;

import java.util.Iterator;

import org.eclipse.emf.common.util.BasicEList;
import org.eclipse.emf.common.util.EList;
import org.eclipse.emf.common.util.TreeIterator;
import org.eclipse.emf.ecore.EObject;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.powermock.api.easymock.PowerMock;
import org.powermock.core.classloader.annotations.PrepareForTest;
import org.powermock.modules.junit4.PowerMockRunner;

import com.github.jknack.antlr4ide.lang.ActionElement;
import com.github.jknack.antlr4ide.lang.Grammar;
import com.github.jknack.antlr4ide.lang.LocalVars;
import com.github.jknack.antlr4ide.lang.ParserRule;
import com.github.jknack.antlr4ide.lang.Return;
import com.github.jknack.antlr4ide.lang.Rule;
import com.github.jknack.antlr4ide.lang.RuleBlock;
import com.github.jknack.antlr4ide.lang.RuleRef;
import com.github.jknack.antlr4ide.validation.Antlr4Validator;

@RunWith(PowerMockRunner.class)
@PrepareForTest({Antlr4Validator.class })
public class Issue34 {

  @Test
  public void ruleRefAttributeIsOK() throws Exception {
    EList<Rule> rules = new BasicEList<Rule>();
    EList<EObject> ruleBodyList = new BasicEList<EObject>();

    Grammar grammar = createMock(Grammar.class);
    ParserRule rule1 = createMock(ParserRule.class);
    Return returns = createMock(Return.class);
    LocalVars locals = createMock(LocalVars.class);
    RuleBlock ruleBody = createMock(RuleBlock.class);
    RuleRef ruleRef = createMock(RuleRef.class);
    ParserRule expr = createMock(ParserRule.class);
    ActionElement actionElement = createMock(ActionElement.class);
    Antlr4Validator validator = PowerMock.createPartialMock(Antlr4Validator.class, "error");

    expect(grammar.getRules()).andReturn(rules).times(2);

    expect(rule1.getName()).andReturn("rule1");
    expect(rule1.getArgs()).andReturn(null);
    expect(rule1.getReturn()).andReturn(returns);
    expect(rule1.getLocals()).andReturn(locals);
    expect(rule1.getBody()).andReturn(ruleBody).times(3);
    expect(rule1.eContainer()).andReturn(grammar);

    expect(returns.getBody()).andReturn(null);

    expect(locals.getBody()).andReturn(null);

    ruleBodyList.add(ruleRef);
    ruleBodyList.add(actionElement);

    expect(ruleBody.eAllContents()).andReturn(newTreeIterator(ruleBodyList));
    expect(ruleBody.eAllContents()).andReturn(newTreeIterator(ruleBodyList));
    expect(ruleBody.eAllContents()).andReturn(newTreeIterator(ruleBodyList));

    expect(ruleRef.getReference()).andReturn(expr).times(2);

    expect(expr.getName()).andReturn("expr");

    expect(actionElement.getBody()).andReturn("{int v = $expr.v;}");

    rules.add(rule1);

    Object[] mocks = {grammar, validator, rule1, returns, locals, ruleBody, actionElement,
        ruleRef, expr };

    replay(mocks);

    validator.checkUnknownAttribute(grammar);

    verify(mocks);
  }

  @Test
  public void ruleRefAttributeIsMissing() throws Exception {
    EList<Rule> rules = new BasicEList<Rule>();
    EList<EObject> ruleBodyList = new BasicEList<EObject>();

    Grammar grammar = createMock(Grammar.class);
    ParserRule rule1 = createMock(ParserRule.class);
    Return returns = createMock(Return.class);
    LocalVars locals = createMock(LocalVars.class);
    RuleBlock ruleBody = createMock(RuleBlock.class);
    ActionElement actionElement = createMock(ActionElement.class);
    Antlr4Validator validator = PowerMock.createPartialMock(Antlr4Validator.class, "error");

    expect(grammar.getRules()).andReturn(rules).times(2);

    expect(rule1.getName()).andReturn("rule1");
    expect(rule1.getArgs()).andReturn(null);
    expect(rule1.getReturn()).andReturn(returns);
    expect(rule1.getLocals()).andReturn(locals);
    expect(rule1.getBody()).andReturn(ruleBody).times(3);
    expect(rule1.eContainer()).andReturn(grammar);

    expect(returns.getBody()).andReturn(null);

    expect(locals.getBody()).andReturn(null);

    ruleBodyList.add(actionElement);

    expect(ruleBody.eAllContents()).andReturn(newTreeIterator(ruleBodyList));
    expect(ruleBody.eAllContents()).andReturn(newTreeIterator(ruleBodyList));
    expect(ruleBody.eAllContents()).andReturn(newTreeIterator(ruleBodyList));

    expect(actionElement.getBody()).andReturn("{int v = $expr.v;}");

    PowerMock.expectPrivate(validator, "error", "unknown attribute reference 'expr' in '$expr'",
        actionElement, 9, 5);

    rules.add(rule1);

    Object[] mocks = {grammar, validator, rule1, returns, locals, ruleBody, actionElement };

    replay(mocks);

    validator.checkUnknownAttribute(grammar);

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
}
