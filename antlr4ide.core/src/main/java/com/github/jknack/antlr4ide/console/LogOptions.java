package com.github.jknack.antlr4ide.console;

import org.eclipse.core.runtime.Platform;
import org.eclipse.core.runtime.preferences.IPreferencesService;

/**
 * Antlr4IDE log-level options.
 *
 * @Statefull
 * @NotThreadSafe
 */
public final class LogOptions {
	
	public static final String QUALIFIER = "com.github.jknack.antlr4ide";
	public static final String KEY = "loglevel";
	
	/** default log level for console and loggers.*/
	public static final LogLevel DEFAULT_LOGLEVEL = LogLevel.INFO;
	
	/** default log level for console and loggers as a java.lang.String.*/
	public static final String DEFAULT_LOGLEVEL_AS_STRING = DEFAULT_LOGLEVEL.toString();
	
	public static LogLevel getLogLevel() {
		IPreferencesService service = Platform.getPreferencesService();
		final String string = service.getString(QUALIFIER, KEY, 
		DEFAULT_LOGLEVEL_AS_STRING, null);
		//final String string = service.get(KEY, 
		//		DEFAULT_LOGLEVEL_AS_STRING, null);
		final LogLevel result = LogLevel.valueOf(string);
		return result;
	}
	
}
