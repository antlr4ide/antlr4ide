package com.github.jknack.antlr4ide.ui.launch

import com.github.jknack.antlr4ide.generator.Antlr4Generator
import com.github.jknack.antlr4ide.generator.ToolOptionsProvider
import com.google.inject.Inject
import org.eclipse.core.resources.IWorkspaceRoot
import org.eclipse.core.runtime.IProgressMonitor
import org.eclipse.core.runtime.Path
import org.eclipse.debug.core.ILaunch
import org.eclipse.debug.core.ILaunchConfiguration
import org.eclipse.debug.core.model.LaunchConfigurationDelegate
import com.github.jknack.antlr4ide.generator.ToolOptions
import com.github.jknack.antlr4ide.console.Console
import com.github.jknack.antlr4ide.generator.LaunchConstants

/**
 * The ANTLR Tool launch configuration delegate, part of the launch API of Eclipse.
 */
class Antlr4ToolLaunchConfigurationDelegate extends LaunchConfigurationDelegate {

  /** The code generator. */
  @Inject
  Antlr4Generator generator

  /** The workspace root. */
  @Inject
  IWorkspaceRoot workspaceRoot

  /** The tool options provider. */
  @Inject
  ToolOptionsProvider optionsProvider

  /** The console. */
  @Inject
  Console console

  /**
   * Launch ANTLR.
   */
  override launch(ILaunchConfiguration config, String mode, ILaunch launch, IProgressMonitor monitor) {
    val path = Path.fromOSString(config.getAttribute(LaunchConstants.GRAMMAR, ""))
    val args = config.getAttribute(LaunchConstants.ARGUMENTS, "")
    val vmArgs = config.getAttribute(LaunchConstants.VM_ARGUMENTS, "")
    val file = workspaceRoot.getFile(path)
    val defaults = optionsProvider.options(file)
    val options = ToolOptions.parse(args) [ message |
      console.error(message)
    ]

    // set some defaults if they are missing
    if (options.outputDirectory == null) {
      options.outputDirectory = defaults.outputDirectory
    }
    options.antlrTool = defaults.antlrTool
    options.vmArgs = vmArgs
    options.cleanUpDerivedResources = defaults.cleanUpDerivedResources
    generator.generate(file, options)
  }

}
