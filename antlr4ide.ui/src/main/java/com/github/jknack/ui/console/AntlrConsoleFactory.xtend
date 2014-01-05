package com.github.jknack.ui.console

import org.eclipse.ui.console.IConsoleFactory
import org.eclipse.ui.console.IOConsole
import org.eclipse.ui.console.ConsolePlugin
import com.google.inject.Inject
import org.eclipse.xtext.ui.IImageHelper.IImageDescriptorHelper

class AntlrConsoleFactory implements IConsoleFactory {

  public static val ANTLR_CONSOLE = "ANTLR Console"

  @Inject
  static IImageDescriptorHelper imageHelper

  override openConsole() {
    val manager = ConsolePlugin.^default.consoleManager
    manager.showConsoleView(console)
  }

  def static getConsole() {
    val manager = ConsolePlugin.^default.consoleManager
    val existing = manager.consoles

    for (console : existing) {
      if (ANTLR_CONSOLE == console.name)
        return console as IOConsole
    }

    val console = new IOConsole(ANTLR_CONSOLE, imageHelper.getImageDescriptor("console.png"))
    manager.addConsoles(#[console])
    return console
  }
}
