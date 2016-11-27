package com.github.jknack.antlr4ide.console;

/**
 * Console and logger for showing feedback to users.
 */
public interface Console {

	/**
	 * Write an ERROR message into the console.
	 *
	 * @param message The message. Might includes place holder. See String#format
	 * @param args Message arguments.
	 */
	public void error(String message, Object...args);
	
	/**
	 * Write a WARNING message into the console.
	 *
	 * @param message The message. Might includes place holder. See String#format
	 * @param args Message arguments.
	 */
	public void warning(String message, Object...args);
	
	/**
	 * Write an INFO message into the console.
	 *
	 * @param message The message. Might includes place holder. See String#format
	 * @param args Message arguments.
	 */
	public void info(String message, Object...args);
	
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
	
}
