package com.github.jknack.antlr4ide.generator

import org.eclipse.xtext.generator.IFileSystemAccess
import org.eclipse.xtext.generator.OutputConfiguration
import org.eclipse.xtext.generator.IOutputConfigurationProvider

/**
 * Override default output folder.
 */
class Antlr4OutputConfigurationProvider implements IOutputConfigurationProvider {

  /**
   * @return a set of {@link OutputConfiguration} available for the generator
   */
  override getOutputConfigurations() {
    val defaultOutput = new OutputConfiguration(IFileSystemAccess.DEFAULT_OUTPUT)
    defaultOutput.description = "Options"
    defaultOutput.outputDirectory = "./target/generated-sources/antlr4"
    defaultOutput.overrideExistingResources = true
    defaultOutput.createOutputDirectory = true
    defaultOutput.cleanUpDerivedResources = true
    defaultOutput.setDerivedProperty = true
    defaultOutput.keepLocalHistory = true
    newHashSet(defaultOutput)
  }
  
}