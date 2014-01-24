package com.github.jknack

import com.google.inject.Guice

class Antlr4TestStandaloneSetup extends Antlr4StandaloneSetupGenerated {

  override createInjector() {
    return Guice.createInjector(new Antlr4RuntimeTestModule())
  }

}
