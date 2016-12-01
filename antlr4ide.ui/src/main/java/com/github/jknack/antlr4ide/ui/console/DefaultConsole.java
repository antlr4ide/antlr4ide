package com.github.jknack.antlr4ide.ui.console;

import com.google.common.base.Objects;
import org.eclipse.debug.ui.IDebugUIConstants;
import org.eclipse.debug.ui.console.ConsoleColorProvider;
import org.eclipse.swt.graphics.Color;
import org.eclipse.swt.widgets.Display;
import org.eclipse.ui.console.IOConsole;
import org.eclipse.ui.console.IOConsoleOutputStream;
import org.apache.log4j.AppenderSkeleton;
import org.apache.log4j.Level;
import org.apache.log4j.spi.LoggingEvent;

/**
 * Creates and prints to Eclipse ConsoleView.
 * Unfortunately it cannot be added as an appender in a
 * log4j.properties file.
 * It is added programatically in
 * com.github.jknack.antlr4ide.ui.Antlr4UiModule.configure()
 * to the logger defined in antlr4ide.core
 */
public class DefaultConsole extends AppenderSkeleton  {
	
	@Override
	protected void append(LoggingEvent logEvent) {
		final String message = logEvent.getRenderedMessage();
		final Level level = logEvent.getLevel();
		final String streamId = getStreamId(level);
		
		final Display display = Display.getDefault();
		final Thread thread = display.getThread();
		Thread _currentThread = Thread.currentThread();
		final boolean uiThread = Objects.equal(thread, _currentThread);
		final Runnable _function = new Runnable() {
			@Override
			public void run() {
				try {
					final IOConsole console = AntlrConsoleFactory.getConsole();
					final IOConsoleOutputStream stream = console
							.newOutputStream();
					final ConsoleColorProvider colorProvider = new ConsoleColorProvider();
					final Color color = colorProvider.getColor(streamId);
					stream.setColor(color);
					stream.setActivateOnWrite(true);
					stream.write((message + "\n"));
					stream.close();
				} catch (Throwable ex) {
					ex.printStackTrace();
				}
			}
		};
		final Runnable printTask = _function;
		if (uiThread) {
			printTask.run();
		} else {
			display.syncExec(printTask);
		}
	}
	
	/**
	 * streamId is used for selecting the color of the 
	 * ConsoleView
	 */
	private String getStreamId(Level level) {
		if (level == Level.FATAL || level == Level.ERROR
				|| level == Level.WARN) {
			return IDebugUIConstants.ID_STANDARD_ERROR_STREAM;
		}
		return IDebugUIConstants.ID_STANDARD_OUTPUT_STREAM;
	}

	@Override
	public void close() {
	}

	@Override
	public boolean requiresLayout() {
		return false;
	}

}
