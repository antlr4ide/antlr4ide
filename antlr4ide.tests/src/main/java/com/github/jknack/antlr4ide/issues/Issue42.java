package com.github.jknack.antlr4ide.issues;

import com.github.jknack.antlr4ide.Antlr4TestInjectorProvider;
import com.github.jknack.antlr4ide.lang.Grammar;
import com.github.jknack.antlr4ide.parser.Antlr4ParseHelper;
import com.google.inject.Inject;
import org.eclipse.xtext.junit4.InjectWith;
import org.eclipse.xtext.junit4.XtextRunner;
import org.eclipse.xtext.parser.IParseResult;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.eclipse.xtext.xbase.lib.Extension;
import org.junit.Assert;
import org.junit.Test;
import org.junit.runner.RunWith;

@RunWith(XtextRunner.class)
@InjectWith(Antlr4TestInjectorProvider.class)
public class Issue42 {
	
	@Inject
	@Extension
	private Antlr4ParseHelper<Grammar> parser;
  
	@Test
	public void doubleQuote() {
		try {
			final String content = this.parser.getTextFromFile(Issue42.class);
			final IParseResult parseResults = this.parser.parse(content);
			final boolean syntaxErrors = parseResults.hasSyntaxErrors();
			Assert.assertFalse(syntaxErrors);
		} catch (final Throwable throwable) {
			throw Exceptions.sneakyThrow(throwable);
		}
	}
	
}
