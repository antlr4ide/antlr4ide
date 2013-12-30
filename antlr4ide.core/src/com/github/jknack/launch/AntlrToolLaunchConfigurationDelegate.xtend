package com.github.jknack.launch

import com.github.jknack.console.ConsoleListener
import com.github.jknack.generator.Antlr4Generator
import com.github.jknack.generator.ToolOptionsProvider
import com.google.inject.Inject
import org.eclipse.core.resources.IWorkspaceRoot
import org.eclipse.core.runtime.CoreException
import org.eclipse.core.runtime.IProgressMonitor
import org.eclipse.core.runtime.Path
import org.eclipse.debug.core.ILaunch
import org.eclipse.debug.core.ILaunchConfiguration
import org.eclipse.debug.core.model.LaunchConfigurationDelegate
import com.github.jknack.generator.ToolOptions

class AntlrToolLaunchConfigurationDelegate extends LaunchConfigurationDelegate {

  @Inject
  static Antlr4Generator generator

  @Inject
  static IWorkspaceRoot workspaceRoot

  @Inject
  static ToolOptionsProvider optionsProvider

  @Inject
  static ConsoleListener console

  override launch(ILaunchConfiguration config, String mode, ILaunch launch, IProgressMonitor monitor) throws CoreException {
    val path = Path.fromOSString(config.getAttribute(AntlrToolLaunchConstants.GRAMMAR, ""))
    val args = config.getAttribute(AntlrToolLaunchConstants.ARGUMENTS, "")
    val file = workspaceRoot.getFile(path)
    val defaults = optionsProvider.options(file)
    val options = ToolOptions.parse(args) [message |
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
