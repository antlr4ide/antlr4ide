package com.github.jknack.antlr4ide;

import com.google.inject.Injector;

import com.github.jknack.antlr4ide.Antlr4InjectorProvider;
import com.github.jknack.antlr4ide.Antlr4TestStandaloneSetup;

public class Antlr4TestInjectorProvider extends Antlr4InjectorProvider {
	
	@Override
	protected Injector internalCreateInjector() {
		Antlr4TestStandaloneSetup antlr4TestStandaloneSetup = new Antlr4TestStandaloneSetup();
		return antlr4TestStandaloneSetup.createInjectorAndDoEMFRegistration();
	}

}
