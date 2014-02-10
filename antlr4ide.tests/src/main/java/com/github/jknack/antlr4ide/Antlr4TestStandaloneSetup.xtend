package com.github.jknack.antlr4ide

import com.google.inject.Guice

class Antlr4TestStandaloneSetup extends Antlr4StandaloneSetupGenerated {

  override createInjector() {
    return Guice.createInjector(new Antlr4RuntimeTestModule())
  }

}
