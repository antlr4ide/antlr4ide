package com.github.jknack.antlr4ide.console;

/**
 * Console for showing feedback to users.
 * 
 * Use with <code>@Inject IConsole console;</code>
 */
public interface Console {

	/**
	 * Write an INFO message into the console.
	 *
	 * @param message The message. Might includes place holder. See String#format
	 * @param args Message arguments.
	 */
	public void info(String message, Object...args);
	
	/**
	 * Write an INFO message into the console without a new line.
	 *
	 * @param message The message. Might includes place holder. See String#format
	 * @param args Message arguments.
	 */
	public void print(String message, Object...args);
	
	/**
	 * Write an INFO message into the console with a new line.
	 *
	 * @param message The message. Might includes place holder. See String#format
	 * @param args Message arguments.
	 */
	public void println(String message, Object...args);
	
	/**
	 * Write an ERROR message into the console.
	 *
	 * @param message The message. Might includes place holder. See String#format
	 * @param args Message arguments.
	 */
	public void error(String message, Object...args);
	
	/**
	 * Write an WARNING message into the console.
	 *
	 * @param message The message. Might includes place holder. See String#format
	 * @param args Message arguments.
	 */
	public void warning(String message, Object...args);
	
	/**
	 * Write a DEBUG message into the console.
	 *
	 * @param message The message. Might includes place holder. See String#format
	 * @param args Message arguments.
	 */
	public void debug(String message, Object...args);
	
	/**
	 * Write a TRACE message into the console.
	 *
	 * @param message The message. Might includes place holder. See String#format
	 * @param args Message arguments.
	 */
	public void trace(String message, Object...args);
	
	/**
	 * Write a TRACE message into the console which has the name of the provided
	 * class as prefix 
	 *
	 * @param clazz The calling Java class
	 * @param message The message. Might includes place holder. See String#format
	 * @param args Message arguments.
	 */
	public void trace(Class<?> clazz, String message, Object...args);
	
}
