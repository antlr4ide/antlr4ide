package com.github.jknack.antlr4ide.console;

/**
 * Log level used by Console.
 * Enable separation of log messages by importance.
 * Might be used to suppress message types which a user is not interested in at all. 
 */
public enum LogLevel {
  /**
   * disable logging at all
   */
  NONE (0),
  /**
   * errors will result in build breaks
   */
  ERROR (2),
  /**
   * warnings should be fixed but are not as critical as errors
   */
  WARNING (4),
  /**
   * information that might be interesting for a user
   */
  INFO (6),
  /**
   * information that might be interesting for a developer
   */
  DEBUG (8),
  /**
   * information that might be interesting only for insane people
   */
  TRACE (10);
  
  private final int value;
  
  private LogLevel(int value) {
	  this.value = value;
  }

  protected int getValue() {
    return value;
  }
  
  public static LogLevel getLogLevel(int value) {
	  for (LogLevel type : LogLevel.values()) {
          if (type.getValue() == value) {
              return type;
          }
      }
      return null;
  }
  
}
