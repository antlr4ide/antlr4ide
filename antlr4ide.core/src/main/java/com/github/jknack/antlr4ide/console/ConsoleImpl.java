package com.github.jknack.antlr4ide.console;

import org.apache.log4j.Logger;
import org.eclipse.core.runtime.Platform;
import org.eclipse.core.runtime.preferences.IPreferencesService;
import org.apache.log4j.Level;
import org.apache.log4j.LogManager;

public final class ConsoleImpl implements Console {
	
	public static final String QUALIFIER = "com.github.jknack.antlr4ide";
	public static final String KEY = "loglevel";
	
	/** default log level for console and loggers.*/
	public static final Level DEFAULT_LOGLEVEL = Level.INFO;
	
	/** default log level for console and loggers as a java.lang.String.*/
	public static final String DEFAULT_LOGLEVEL_AS_STRING = DEFAULT_LOGLEVEL.toString();

	@Override
	public void error(String message, Object...args) {
		final Logger logger = getLogger();
		final String msg = format(message, args);
		logger.error(msg);
	}
	
	@Override
	public void warning(String message, Object...args) {
		final Logger logger = getLogger();
		final String msg = format(message, args);
		logger.warn(msg);
	}
	
	@Override
	public void info(String message, Object...args) {
		final Logger logger = getLogger();
		final String msg = format(message, args);
		logger.info(msg);
	}
	
	@Override
	public void debug(String message, Object...args) {
		final Logger logger = getLogger();
		final String msg = format(message, args);
		logger.debug(msg);
	}

	@Override
	public void trace(String message, Object...args) {
		final Logger logger = getLogger();
		final String msg = format(message, args);
		logger.trace(msg);
	}
	
	public static Logger getLogger() {
		final Logger logger = LogManager.getRootLogger();
		logger.setAdditivity(true);
		// set log-level of logger
		Level level = getLogLevel();
		logger.setLevel(level);
		return logger;
	}
	
	private String format(final String message, final Object...args) {
		final String result = String.format(message, args);
		return result;
	}
	
	public static Level getLogLevel() {
		final IPreferencesService service = Platform.getPreferencesService();
		final String string = service.getString(QUALIFIER, KEY, 
				DEFAULT_LOGLEVEL_AS_STRING, null);
		final Level result = Level.toLevel(string);
		return result;
	}
	
}
