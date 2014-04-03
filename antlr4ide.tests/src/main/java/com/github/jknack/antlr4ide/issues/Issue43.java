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

import com.github.jknack.antlr4ide.lang.ActionElement;
import com.github.jknack.antlr4ide.lang.Grammar;
import com.github.jknack.antlr4ide.lang.LocalVars;
import com.github.jknack.antlr4ide.lang.ParserRule;
import com.github.jknack.antlr4ide.lang.Return;
import com.github.jknack.antlr4ide.lang.Rule;
import com.github.jknack.antlr4ide.lang.RuleBlock;
import com.github.jknack.antlr4ide.validation.Antlr4Validator;

public class Issue43 {

  @Test
  public void allowCtxAttribute() {
    EList<Rule> rules = new BasicEList<Rule>();
    EList<EObject> ruleBodyList = new BasicEList<EObject>();

    String localsBody = "{\n$ctx.tree;\n}";

    Grammar grammar = createMock(Grammar.class);
    ParserRule rule1 = createMock(ParserRule.class);
    Return returns = createMock(Return.class);
    LocalVars locals = createMock(LocalVars.class);
    RuleBlock ruleBody = createMock(RuleBlock.class);
    ActionElement actionElement = createMock(ActionElement.class);

    expect(grammar.getRules()).andReturn(rules);

    expect(rule1.getArgs()).andReturn(null);
    expect(rule1.getReturn()).andReturn(returns);
    expect(rule1.getLocals()).andReturn(locals);
    expect(rule1.getBody()).andReturn(ruleBody).times(2);

    expect(returns.getBody()).andReturn(null);

    expect(locals.getBody()).andReturn(localsBody);

    ruleBodyList.add(actionElement);

    expect(ruleBody.eAllContents()).andReturn(newTreeIterator(ruleBodyList));
    expect(ruleBody.eAllContents()).andReturn(newTreeIterator(ruleBodyList));

    expect(actionElement.getBody()).andReturn("{$ctx.tree;}");

    rules.add(rule1);

    Object[] mocks = {grammar, rule1, returns, locals, ruleBody, actionElement };

    replay(mocks);

    new Antlr4Validator().checkUnknownAttribute(grammar);

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
