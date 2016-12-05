package com.github.jknack.antlr4ide.parser;

import com.github.jknack.antlr4ide.Antlr4TestInjectorProvider;
import com.github.jknack.antlr4ide.lang.Grammar;
import com.github.jknack.antlr4ide.lang.GrammarType;
import com.github.jknack.antlr4ide.lang.Option;
import com.github.jknack.antlr4ide.lang.OptionValue;
import com.github.jknack.antlr4ide.lang.Options;
import com.github.jknack.antlr4ide.lang.PrequelConstruct;
import com.github.jknack.antlr4ide.lang.QualifiedId;
import com.github.jknack.antlr4ide.lang.QualifiedOption;
import com.github.jknack.antlr4ide.parser.Antlr4ParseHelper;
import com.google.inject.Inject;
import java.io.File;
import org.eclipse.emf.common.util.EList;
import org.eclipse.xtext.junit4.InjectWith;
import org.eclipse.xtext.junit4.XtextRunner;
import org.eclipse.xtext.junit4.util.ParseHelper;
import org.eclipse.xtext.parser.IParseResult;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.junit.Assert;
import org.junit.Test;
import org.junit.runner.RunWith;

@RunWith(XtextRunner.class)
@InjectWith(Antlr4TestInjectorProvider.class)
public class GrammarSyntaxTest {
	
	@Inject
	@Extension
	private Antlr4ParseHelper<Grammar> helper;
	
	@Inject
	@Extension
	private ParseHelper<Grammar> parser;
  
	@Test
	public void defGrammar() {
		try {
			final String suffix = File.separator + "defGrammar" + File.separator + "G";
			final String content = this.helper.getTextFromFile(GrammarSyntaxTest.class, suffix);
			final IParseResult parseResult = this.helper.parse(content);
			final boolean hasSyntaxErrors = parseResult.hasSyntaxErrors();
			Assert.assertFalse(hasSyntaxErrors);
			final Grammar grammar = this.parser.parse(content);
			Assert.assertNotNull(grammar);
			Assert.assertEquals("G", grammar.getName());
			Assert.assertEquals(GrammarType.DEFAULT, grammar.getType());
		} catch (final Throwable throwable) {
			throw Exceptions.sneakyThrow(throwable);
		}
	}

	@Test
	public void lexerGrammar() {
		try {
			final String suffix = File.separator + "lexerGrammar" + File.separator + "L";
			//final String content = this.parser.getTextFromFile(GrammarSyntaxTest.class, suffix);
			final String content = this.helper.getTextFromFile(GrammarSyntaxTest.class, suffix);
			final IParseResult parseResult = this.helper.parse(content);
			final boolean hasSyntaxErrors = parseResult.hasSyntaxErrors();
			Assert.assertFalse(hasSyntaxErrors);
			final Grammar grammar = this.parser.parse(content);
			Assert.assertNotNull(grammar);
			Assert.assertEquals("L", grammar.getName());
			Assert.assertEquals(GrammarType.LEXER, grammar.getType());
		} catch (final Throwable throwable) {
			throw Exceptions.sneakyThrow(throwable);
		}
	}


	@Test
	public void parserGrammar() {
		try {
			final String suffix = File.separator + "parserGrammar" + File.separator + "P";
			//final String content = this.parser.getTextFromFile(GrammarSyntaxTest.class, suffix);
			final String content = this.helper.getTextFromFile(GrammarSyntaxTest.class, suffix);
			final IParseResult parseResult = this.helper.parse(content);
			final boolean hasSyntaxErrors = parseResult.hasSyntaxErrors();
			Assert.assertFalse(hasSyntaxErrors);
			final Grammar grammar = this.parser.parse(content);
			Assert.assertNotNull(grammar);
			Assert.assertEquals("P", grammar.getName());
			Assert.assertEquals(GrammarType.PARSER, grammar.getType());
		} catch (final Throwable throwable) {
			throw Exceptions.sneakyThrow(throwable);
		}
	}


	@Test
	public void treeGrammar() {
		try {
			final String suffix = File.separator + "treeGrammar" + File.separator + "T";
			//final String content = this.parser.getTextFromFile(GrammarSyntaxTest.class, suffix);
			final String content = this.helper.getTextFromFile(GrammarSyntaxTest.class, suffix, ".txt");
			final IParseResult parseResult = this.helper.parse(content);
			final boolean hasSyntaxErrors = parseResult.hasSyntaxErrors();
			Assert.assertFalse(hasSyntaxErrors);
			final Grammar grammar = this.parser.parse(content);
			Assert.assertNotNull(grammar);
			Assert.assertEquals("T", grammar.getName());
			Assert.assertEquals(GrammarType.TREE, grammar.getType());
		} catch (final Throwable throwable) {
			throw Exceptions.sneakyThrow(throwable);
		}
	}

	
	@Test
	public void grammarEmptyOptions() {
		try {
			final String suffix = File.separator + "grammarEmptyOptions" + File.separator + "G";
			final String content = this.helper.getTextFromFile(GrammarSyntaxTest.class, suffix);
			final IParseResult parseResult = this.helper.parse(content);
			final boolean hasSyntaxErrors = parseResult.hasSyntaxErrors();
			Assert.assertFalse(hasSyntaxErrors);
			final Grammar grammar = this.parser.parse(content);
			Assert.assertNotNull(grammar);
			final Options options = getOptions(grammar);
			Assert.assertNotNull(options);
		} catch (final Throwable throwable) {
			throw Exceptions.sneakyThrow(throwable);
		}
	}


	@Test
	public void grammarOptions() {
		try {
			final String suffix = File.separator + "grammarOptions" + File.separator + "G";
			final String content = this.helper.getTextFromFile(GrammarSyntaxTest.class, suffix);
			final IParseResult parseResult = this.helper.parse(content);
			final boolean hasSyntaxErrors = parseResult.hasSyntaxErrors();
			Assert.assertFalse(hasSyntaxErrors);
			final Grammar grammar = this.parser.parse(content);
			Assert.assertNotNull(grammar);
			final Options options = getOptions(grammar);
			Assert.assertNotNull(options);
			this.assertQualifiedOption(options, "language", "Java");
			this.assertQualifiedOption(options, "superClass", "com.my.class.Parser");
		} catch (final Throwable throwable) {
			throw Exceptions.sneakyThrow(throwable);
		}
	}
	
	private Options getOptions(Grammar grammar) {
		final EList<PrequelConstruct> prequels = grammar.getPrequels();
		for (int i = 0; i < prequels.size(); i++) {
			PrequelConstruct it = prequels.get(i);
			if (it instanceof Options) {
				final Options result = (Options)it;
				return result;
			}
		}
		return null;
	}

	
	
	private void assertQualifiedOption(final Options options, final String name, 
			final String expectedValue) {
		final Option language = getOptionWithName(options, name);
		Assert.assertNotNull(language);
		final OptionValue value = language.getValue();
		Assert.assertNotNull(value);
		final OptionValue value2 = language.getValue();
		Assert.assertTrue((value2 instanceof QualifiedOption));
		final OptionValue value3 = language.getValue();
		final QualifiedId value4 = ((QualifiedOption) value3).getValue();
		final EList<String> valName = value4.getName();
		final String join = IterableExtensions.join(valName, ".");
		Assert.assertEquals(expectedValue, join);
	}
	
	private Option getOptionWithName(final Options options, final String name) {
		final EList<Option> optionList = options.getOptions();
		for (int i = 0; i < optionList.size(); i++) {
			Option it = optionList.get(i);
			final Option result = it;
			if (name.equals(it.getName())) {
				return result;
			}
		}
		return null;
	}
	
}
