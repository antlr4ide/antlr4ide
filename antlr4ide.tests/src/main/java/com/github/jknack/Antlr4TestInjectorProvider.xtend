package com.github.jknack

import com.github.jknack.Antlr4InjectorProvider

class Antlr4TestInjectorProvider extends Antlr4InjectorProvider {
  
  override protected internalCreateInjector() {
    new Antlr4TestStandaloneSetup().createInjectorAndDoEMFRegistration
  }
  
}