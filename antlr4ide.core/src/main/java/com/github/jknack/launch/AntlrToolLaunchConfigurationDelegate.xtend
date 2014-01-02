package com.github.jknack.launch

import com.github.jknack.generator.Antlr4Generator
import com.github.jknack.generator.ToolOptionsProvider
import com.google.inject.Inject
import org.eclipse.core.resources.IWorkspaceRoot
import org.eclipse.core.runtime.IProgressMonitor
import org.eclipse.core.runtime.Path
import org.eclipse.debug.core.ILaunch
import org.eclipse.debug.core.ILaunchConfiguration
import org.eclipse.debug.core.model.LaunchConfigurationDelegate
import com.github.jknack.generator.ToolOptions
import com.github.jknack.console.Console

/**
 * The ANTLR Tool launch configuration delegate, part of the launch API of Eclipse.
 */
class AntlrToolLaunchConfigurationDelegate extends LaunchConfigurationDelegate {

  /** The code generator. */
  @Inject
  static Antlr4Generator generator

  /** The workspace root. */
  @Inject
  static IWorkspaceRoot workspaceRoot

  /** The tool options provider. */
  @Inject
  static ToolOptionsProvider optionsProvider

  /** The console. */
  @Inject
  static Console console

  /**
   * Launch ANTLR.
   */
  override launch(ILaunchConfiguration config, String mode, ILaunch launch, IProgressMonitor monitor) {
    val path = Path.fromOSString(config.getAttribute(AntlrToolLaunchConstants.GRAMMAR, ""))
    val args = config.getAttribute(AntlrToolLaunchConstants.ARGUMENTS, "")
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
    generator.generate(file, options)
  }

}
