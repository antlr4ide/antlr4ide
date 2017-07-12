package com.github.jknack.antlr4ide.generator;

import java.util.HashSet;
import java.util.Set;

import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.generator.IOutputConfigurationProvider;
import org.eclipse.xtext.generator.OutputConfiguration;

/**
 * Override default output folder.
 */
public class Antlr4OutputConfigurationProvider
		implements IOutputConfigurationProvider {
	
	@Override
	/**
	 * @return a set of {@link OutputConfiguration} available for the generator
	 */
	public Set<OutputConfiguration> getOutputConfigurations() {
		final OutputConfiguration defaultOutput = new OutputConfiguration(
				IFileSystemAccess.DEFAULT_OUTPUT);
		defaultOutput.setDescription("Options");
		defaultOutput.setOutputDirectory("./target/generated-sources/antlr4");
		defaultOutput.setOverrideExistingResources(true);
		defaultOutput.setCreateOutputDirectory(true);
		defaultOutput.setCleanUpDerivedResources(true);
		defaultOutput.setSetDerivedProperty(true);
		defaultOutput.setKeepLocalHistory(true);
		final Set<OutputConfiguration> result = new HashSet<OutputConfiguration>();
		result.add(defaultOutput);
		return result;
	}

}
