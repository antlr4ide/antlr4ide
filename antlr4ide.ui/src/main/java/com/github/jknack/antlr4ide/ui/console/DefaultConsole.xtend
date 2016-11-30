package com.github.jknack.antlr4ide.ui.console

import org.eclipse.debug.ui.console.ConsoleColorProvider
import org.eclipse.debug.ui.IDebugUIConstants
import org.eclipse.swt.widgets.Display
import com.github.jknack.antlr4ide.console.LogLevel
import com.github.jknack.antlr4ide.console.LogOptions
import com.github.jknack.antlr4ide.console.Console

class DefaultConsole implements Console {
	
  private static final String NL_STR = "\n";

  override info(String message, Object... args) {
    log(LogLevel.INFO, String.format(message, args), 
    	IDebugUIConstants.ID_STANDARD_OUTPUT_STREAM, NL_STR
    )
  }

  override print(String message, Object... args) {
    log(LogLevel.INFO, String.format(message, args),
    	IDebugUIConstants.ID_STANDARD_OUTPUT_STREAM, NL_STR
    )
  }

  override println(String message, Object... args) {
    info(message, args)
  }

  override error(String message, Object... args) {
    log(LogLevel.ERROR, String.format(message, args),
    	IDebugUIConstants.ID_STANDARD_ERROR_STREAM, NL_STR
    )
  }
  
  override warning(String message, Object... args) {
    log(LogLevel.WARNING, String.format(message, args),
    	IDebugUIConstants.ID_STANDARD_ERROR_STREAM, NL_STR
    )
  }
  
  override debug(String message, Object... args) {
  	log(LogLevel.DEBUG, String.format(message, args),
    	IDebugUIConstants.ID_STANDARD_OUTPUT_STREAM, NL_STR
    )
  }
  
  override trace(String message, Object... args) {
  	log(LogLevel.TRACE, String.format(message, args),
    	IDebugUIConstants.ID_STANDARD_OUTPUT_STREAM, NL_STR
    )
  }
  
  override trace(Class<?> clazz, String message, Object... args) {
  	log(LogLevel.TRACE, clazz.getCanonicalName() + ": " + 
  		String.format(message, args),
    	IDebugUIConstants.ID_STANDARD_OUTPUT_STREAM, NL_STR
    )
  }
  
  private def log(LogLevel logLevel, String message, String streamId, String nl) {
  	val LogLevel currentLogLevel = LogOptions.getLogLevel();
  	if (logLevel > currentLogLevel) {
  		// suppress log message
  		System.out.println("DefaultConsole.suppressMessage='" + message + ", logLevel='" 
  			+ logLevel + "', currLogLevel='" + currentLogLevel + "'"
  		);
  		return;
  	}
  	log(message, streamId, nl);
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
