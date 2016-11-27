package com.github.jknack.antlr4ide.console;

import java.util.ArrayList;
import java.util.List;

import org.apache.log4j.AppenderSkeleton;
import org.apache.log4j.Level;
import org.apache.log4j.spi.LoggingEvent;

class TestAppender extends AppenderSkeleton {
	private final List<String> errors;
	private final List<String> warnings;
	private final List<String> infos;
	private final List<String> debugs;
	private final List<String> traces;
	private final List<String> others;
	
	public TestAppender() {
		errors = new ArrayList<String>();
		warnings = new ArrayList<String>();
		infos = new ArrayList<String>();
		debugs = new ArrayList<String>();
		traces = new ArrayList<String>();
		others = new ArrayList<String>();
	}

	@Override
	public void close() {
		
	}

	@Override
	public boolean requiresLayout() {
		return false;
	}

	@Override
	protected void append(LoggingEvent event) {
		final Level level = event.getLevel();
		final String message = event.getRenderedMessage();
		switch (level.toInt()) {
		case Level.ERROR_INT: errors.add(message); break;
		case Level.WARN_INT: warnings.add(message); break;
		case Level.INFO_INT: infos.add(message); break;
		case Level.DEBUG_INT: debugs.add(message); break;
		case Level.TRACE_INT: traces.add(message); break;
		default: others.add(message); break;
		}
	}
	
	public String getError() {
		return getStringForList(this.errors);
	}
	
	public String getWarning() {
		return getStringForList(this.warnings);
	}
	
	public String getInfo() {
		return getStringForList(this.infos);
	}
	
	public String getDebug() {
		return getStringForList(this.debugs);
	}
	
	public String getTrace() {
		return getStringForList(this.traces);
	}
	
	private String getStringForList(final List<String> list) {
		final StringBuffer result = new StringBuffer("");
		for (int i = 0; i < list.size(); i++) {
			final String msg = list.get(i);
			result.append(msg);
		}
		return result.toString();
	}
}
