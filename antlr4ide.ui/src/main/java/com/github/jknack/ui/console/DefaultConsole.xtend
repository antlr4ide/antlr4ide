package com.github.jknack.ui.console

import org.eclipse.debug.ui.console.ConsoleColorProvider
import org.eclipse.debug.ui.IDebugUIConstants
import org.eclipse.swt.widgets.Display
import com.github.jknack.console.Console

class DefaultConsole implements Console {

  override info(String message, Object...args) {
    log(String.format(message, args), IDebugUIConstants.ID_STANDARD_OUTPUT_STREAM)
  }

  override error(String message, Object...args) {
    log(String.format(message, args), IDebugUIConstants.ID_STANDARD_ERROR_STREAM)
  }

  private def log(String message, String streamId) {
    Display.^default.syncExec([ |
      val console = AntlrConsoleFactory.console
      val stream = console.newOutputStream
      val colorProvider = new ConsoleColorProvider
      val color = colorProvider.getColor(streamId)
      stream.setColor(color)
      stream.setActivateOnWrite(true)
      stream.write(message);
      stream.write('\n');
      stream.close();
    ])
  }
}
