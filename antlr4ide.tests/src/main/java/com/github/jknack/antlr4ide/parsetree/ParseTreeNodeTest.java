package com.github.jknack.antlr4ide.parsetree;

import static org.easymock.EasyMock.createMock;
import static org.easymock.EasyMock.expect;
import static org.easymock.EasyMock.replay;
import static org.easymock.EasyMock.verify;
import static org.junit.Assert.assertEquals;

import org.junit.Test;

import com.github.jknack.antlr4ide.lang.LexerRule;
import com.github.jknack.antlr4ide.lang.ParserRule;
import com.github.jknack.antlr4ide.lang.Rule;
import com.github.jknack.antlr4ide.lang.Terminal;

public class ParseTreeNodeTest {

  @Test
  public void parserRuleSource() {
    Rule element = createMock(ParserRule.class);
    expect(element.getName()).andReturn("rule");

    Object[] mocks = {element };

    replay(mocks);

    ParseTreeNode node = new ParseTreeNode(element);
    assertEquals(element, node.getElement());
    assertEquals("rule", node.getText());

    verify(mocks);
  }

  @Test
  public void lexerRuleSource() {
    Rule element = createMock(LexerRule.class);
    expect(element.getName()).andReturn("WS");

    Object[] mocks = {element };

    replay(mocks);

    ParseTreeNode node = new ParseTreeNode(element);
    assertEquals(element, node.getElement());
    assertEquals("WS", node.getText());

    verify(mocks);
  }

  @Test
  public void terminalSource() {
    Terminal element = createMock(Terminal.class);
    expect(element.getLiteral()).andReturn("'hello'");

    Object[] mocks = {element };

    replay(mocks);

    ParseTreeNode node = new ParseTreeNode(element);
    assertEquals(element, node.getElement());
    assertEquals("'hello'", node.getText());

    verify(mocks);
  }

  @Test
  public void toStringSource() {
    Object element = new Object() {
      @Override
      public String toString() {
        return "toString";
      }
    };

    ParseTreeNode node = new ParseTreeNode(element);
    assertEquals(element, node.getElement());
    assertEquals("toString", node.getText());
  }

  @Test(expected = NullPointerException.class)
  public void failOnNullSource() {
    new ParseTreeNode(null);
  }
}
