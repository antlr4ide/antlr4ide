package com.github.jknack.antlr4ide;

import com.github.jknack.antlr4ide.Antlr4RuntimeTestModule;
import com.github.jknack.antlr4ide.Antlr4StandaloneSetupGenerated;
import com.google.inject.Guice;
import com.google.inject.Injector;

public class Antlr4TestStandaloneSetup extends Antlr4StandaloneSetupGenerated {
	@Override
	public Injector createInjector() {
		Antlr4RuntimeTestModule antlr4RuntimeTestModule = new Antlr4RuntimeTestModule();
		return Guice.createInjector(antlr4RuntimeTestModule);
	}
	
}
