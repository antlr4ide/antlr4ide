package com.github.jknack.antlr4ide.parser;

import com.google.inject.Inject;
import com.google.inject.Singleton;

import java.io.File;
import java.io.StringReader;

import org.apache.commons.io.FileUtils;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.xtext.parser.IParseResult;
import org.eclipse.xtext.parser.IParser;

@Singleton
public class Antlr4ParseHelper<T extends EObject> {
	
	@Inject
	private IParser parser;
	
	public IParseResult parse(final CharSequence input) {
		final String content = input.toString();
		final StringReader stringReader = new StringReader(content);
		return this.parser.parse(stringReader);
	}
	
	@SuppressWarnings({ "hiding", "unchecked" })
	public <T extends Object> T build(final CharSequence input) {
		final String content = input.toString();
		final StringReader stringReader = new StringReader(content);
		final IParseResult parseResult = this.parser.parse(stringReader);
		final EObject rootAstElement = parseResult.getRootASTElement();
		return ((T) rootAstElement);
	}
	
	public String getTextFromFile(final Class<?> clazz)
			throws Exception {
		return getTextFromFile(clazz, "");
	}
	
	public String getTextFromFile(final Class<?> clazz, final String suffix)
			throws Exception {
		return getTextFromFile(clazz, suffix, ".g4");
	}
		
	public String getTextFromFile(final Class<?> clazz, final String suffix,
			final String fileExtension) throws Exception {
		final String dir = "src/main/resources/";
		final String dir2 = dir.replace("/", File.separator);
		//final Package pkg = clazz.getPackage();
		//final String pkgName = pkg.getName();
		//final String pkgName2 = pkgName.replace(".", File.separator);
		//final String pathAsString = (((dir2 + pkgName2) + File.separator) + fileName);
		final String fileName = clazz.getSimpleName() + suffix + fileExtension;
		final String pathAsString = dir2 + fileName;
		final File file = new File(pathAsString);
		final String content = FileUtils.readFileToString(file, "UTF-8");
		return content;
	}
	
}
