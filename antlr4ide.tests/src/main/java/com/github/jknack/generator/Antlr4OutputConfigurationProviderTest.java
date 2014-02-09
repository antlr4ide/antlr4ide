package com.github.jknack.generator;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;

import java.util.Set;

import org.eclipse.xtext.generator.OutputConfiguration;
import org.junit.Test;

public class Antlr4OutputConfigurationProviderTest {

  @Test
  public void outputConfigurations() {
    Set<OutputConfiguration> configs = new Antlr4OutputConfigurationProvider()
        .getOutputConfigurations();

    assertNotNull(configs);
    assertEquals(1, configs.size());

    OutputConfiguration config = configs.iterator().next();
    assertNotNull(config);
    assertEquals("Options", config.getDescription());
    assertEquals("DEFAULT_OUTPUT", config.getName());
    assertEquals("./target/generated-sources/antlr4", config.getOutputDirectory());
    assertEquals(false, config.isCanClearOutputDirectory());
    assertEquals(true, config.isCreateOutputDirectory());
    assertEquals(true, config.isHideSyntheticLocalVariables());
    assertEquals(false, config.isInstallDslAsPrimarySource());
    assertEquals(true, config.isKeepLocalHistory());
    assertEquals(true, config.isOverrideExistingResources());
    assertEquals(true, config.isSetDerivedProperty());
  }
}
