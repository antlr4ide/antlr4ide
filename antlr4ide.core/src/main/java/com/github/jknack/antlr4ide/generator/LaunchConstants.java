package com.github.jknack.antlr4ide.generator;

/**
 * Launch attributes.
 */
public interface LaunchConstants {

	/**
	 * Specify the grammar path. The path must be relative to the workspace root
	 * and must be in the OS format.
	 */
	public static String GRAMMAR = "antlr4.grammar";
	
	/**
	 * Specify tool arguments. Arguments are separated by spaces like in a shell
	 * console.
	 * See
	 * http://www.antlr.org/wiki/display/ANTLR4/ANTLR+Tool+Command+Line+Options
	 */
	public static String ARGUMENTS = "antlr4.arguments";
	
	/**
	 * Specify VM arguments.
	 */
	public static String VM_ARGUMENTS = "antlr4.vmArguments";
	
	/** Launch ID. */
	public static String LAUNCH_ID = "com.github.jknack.Antlr4.tool";
	
}
