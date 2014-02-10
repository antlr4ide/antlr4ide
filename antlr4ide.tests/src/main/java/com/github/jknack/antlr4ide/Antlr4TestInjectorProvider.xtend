package com.github.jknack.antlr4ide

class Antlr4TestInjectorProvider extends Antlr4InjectorProvider {
  
  override protected internalCreateInjector() {
    new Antlr4TestStandaloneSetup().createInjectorAndDoEMFRegistration
  }
  
}