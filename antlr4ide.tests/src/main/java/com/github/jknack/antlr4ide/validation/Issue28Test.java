package com.github.jknack.antlr4ide.validation;

import static org.easymock.EasyMock.createMock;
import static org.easymock.EasyMock.expect;
import static org.easymock.EasyMock.replay;
import static org.easymock.EasyMock.verify;

import org.eclipse.emf.common.util.BasicEList;
import org.eclipse.emf.common.util.EList;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.powermock.api.easymock.PowerMock;
import org.powermock.core.classloader.annotations.PrepareForTest;
import org.powermock.modules.junit4.PowerMockRunner;

import com.github.jknack.antlr4ide.lang.Grammar;
import com.github.jknack.antlr4ide.lang.GrammarAction;
import com.github.jknack.antlr4ide.lang.PrequelConstruct;

@RunWith(PowerMockRunner.class)
@PrepareForTest({Antlr4Validator.class })
public class Issue28Test {

  @Test
  public void actionOnDiffScopesMustNotFail() throws Exception {
    EList<PrequelConstruct> prequels = new BasicEList<PrequelConstruct>();

    Grammar grammar = createMock(Grammar.class);
    GrammarAction action1 = createMock(GrammarAction.class);
    GrammarAction action2 = createMock(GrammarAction.class);
    Antlr4Validator validator = PowerMock.createPartialMock(Antlr4Validator.class, "error");

    expect(grammar.getPrequels()).andReturn(prequels);

    expect(action1.getScope()).andReturn("lexer");
    expect(action1.getName()).andReturn("header");

    expect(action2.getScope()).andReturn("parser");
    expect(action2.getName()).andReturn("header");

    prequels.add(action1);
    prequels.add(action2);

    Object[] mocks = {grammar, validator, action1, action2 };

    replay(mocks);

    validator.checkActionRedefinition(grammar);

    verify(mocks);
  }
}
