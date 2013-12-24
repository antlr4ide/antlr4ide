package com.github.jknack.generator

import org.eclipse.xtext.generator.IOutputConfigurationProvider
import org.eclipse.xtext.generator.IFileSystemAccess
import org.eclipse.xtext.generator.OutputConfiguration

class BuildConfigurationProvider implements IOutputConfigurationProvider {

  public static final String BUILD_LISTENER = "antlr4.listener"

  public static final String BUILD_VISITOR = "antlr4.visitor"

  public static final String BUILD_ANTLR_TOOL = "antlr4.antlrTool"

  public static final String BUILD_ENCODING = "antlr4.encoding"

  override getOutputConfigurations() {
    val defaultOutput = new OutputConfiguration(IFileSystemAccess.DEFAULT_OUTPUT)
    defaultOutput.description = "Options"
    defaultOutput.outputDirectory = "./generated-sources/antlr4"
    defaultOutput.overrideExistingResources = true
    defaultOutput.createOutputDirectory = true
    defaultOutput.cleanUpDerivedResources = true
    defaultOutput.setDerivedProperty = true
    defaultOutput.keepLocalHistory = true
    defaultOutput.keepLocalHistory = true

    return newHashSet(defaultOutput);
  }
}
