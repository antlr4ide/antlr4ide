package com.github.jknack.antlr4ide.parser;

import com.github.jknack.antlr4ide.Antlr4TestInjectorProvider;
import com.github.jknack.antlr4ide.lang.Grammar;
import com.github.jknack.antlr4ide.lang.GrammarAction;
import com.github.jknack.antlr4ide.lang.PrequelConstruct;
import com.github.jknack.antlr4ide.parser.Antlr4ParseHelper;
import com.google.inject.Inject;

import org.eclipse.emf.common.util.EList;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.junit4.InjectWith;
import org.eclipse.xtext.junit4.XtextRunner;
import org.eclipse.xtext.junit4.util.ParseHelper;
import org.eclipse.xtext.parser.IParseResult;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.eclipse.xtext.xbase.lib.Extension;
import org.junit.Assert;
import org.junit.Test;
import org.junit.runner.RunWith;

@RunWith(XtextRunner.class)
@InjectWith(Antlr4TestInjectorProvider.class)
public class LangActionTest {
	
	@Inject
	@Extension
	private Antlr4ParseHelper<Grammar> parser;
	@Inject
	@Extension
	private ParseHelper<Grammar> parseHelper;
  
	@Test
	public void slashInLangAction() {
		try {
			final String content = this.parser.getTextFromFile(LangActionTest.class, "");
			final IParseResult parseResults = this.parser.parse(content);
			final boolean syntaxErrors = parseResults.hasSyntaxErrors();
			Assert.assertFalse(syntaxErrors);
			final Grammar grammar = this.parseHelper.parse(content);
			Assert.assertNotNull(grammar);
			final GrammarAction action = getAction(grammar);
			Assert.assertNotNull(action);
			final String expected = getExpectedString();
			final String actual = action.getAction();
			Assert.assertEquals(expected, actual);
		} catch (final Throwable throwable) {
			throw Exceptions.sneakyThrow(throwable);
		}
	}

	private GrammarAction getAction(Grammar grammar) {
		final EList<PrequelConstruct> prequels = grammar.getPrequels();
		for (int i = 0; i < prequels.size(); i++) {
			final PrequelConstruct it = prequels.get(i);
			if (it instanceof GrammarAction) {
				final GrammarAction result = (GrammarAction)it;
				return result;
			}
		}
		return null;
	}
	
	private String getExpectedString() {
		final StringConcatenation content = new StringConcatenation();
		content.append("{");
		content.newLine();
		content.append("  ");
		content.append("a = a / c;");
		content.newLine();
		content.append("}");
	    final String result = content.toString();
	    return result;
	}
	
}
