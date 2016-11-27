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

public class DefaultConsole extends AppenderSkeleton  {
	
	public DefaultConsole() {
		super();
		System.out.println("DefaultConsole - constructor");
	}

	@Override
	protected void append(LoggingEvent logEvent) {
		final String message = logEvent.getRenderedMessage();
		System.out.println("DefaultConsole, message='" + message + "'");
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

	private String getStreamId(Level level) {
		if (level == Level.FATAL || level == Level.ERROR
				|| level == Level.WARN) {
			return IDebugUIConstants.ID_STANDARD_ERROR_STREAM;
		}
		return IDebugUIConstants.ID_STANDARD_OUTPUT_STREAM;
	}

	@Override
	public void close() {
		System.out.println("DefaultConsole - close");
	}

	@Override
	public boolean requiresLayout() {
		System.out.println("DefaultConsole - requiresLayout");
		return false;
	}

}
