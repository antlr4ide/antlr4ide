package com.github.jknack.antlr4ide.ui.console

import org.eclipse.debug.ui.console.ConsoleColorProvider
import org.eclipse.debug.ui.IDebugUIConstants
import org.eclipse.swt.widgets.Display
import com.github.jknack.antlr4ide.console.Console

class DefaultConsole implements Console {

  override info(String message, Object... args) {
    log(String.format(message, args), IDebugUIConstants.ID_STANDARD_OUTPUT_STREAM, "\n")
  }

  override print(String message, Object... args) {
    log(String.format(message, args), IDebugUIConstants.ID_STANDARD_OUTPUT_STREAM, "")
  }

  override println(String message, Object... args) {
    info(message, args)
  }

  override error(String message, Object... args) {
    log(String.format(message, args), IDebugUIConstants.ID_STANDARD_ERROR_STREAM, "\n")
  }

  private def log(String message, String streamId, String nl) {
    val display = Display.^default
    val thread = display.thread
    val uiThread = thread == Thread.currentThread

    val Runnable printTask = [ |
      val console = AntlrConsoleFactory.console
      val stream = console.newOutputStream
      val colorProvider = new ConsoleColorProvider
      val color = colorProvider.getColor(streamId)
      stream.setColor(color)
      stream.setActivateOnWrite(true)
      stream.write(message + nl);
      stream.close();
    ]
    if (uiThread) {
      printTask.run
    } else {
      display.syncExec(printTask)
    }
  }
}
