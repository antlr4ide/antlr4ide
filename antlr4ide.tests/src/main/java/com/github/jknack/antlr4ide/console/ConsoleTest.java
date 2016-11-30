package com.github.jknack.antlr4ide.console;

//import org.eclipse.core.runtime.preferences.IEclipsePreferences;
import org.eclipse.core.runtime.preferences.IEclipsePreferences;
import org.eclipse.core.runtime.preferences.InstanceScope;
import org.junit.Assert;
import org.junit.Test;
import org.osgi.service.prefs.BackingStoreException;

import com.github.jknack.antlr4ide.console.LogOptions;
import com.github.jknack.antlr4ide.console.LogLevel;

public class ConsoleTest {

	@Test
	public void testEnumLogLevel() {
		Assert.assertEquals(LogLevel.DEBUG, LogLevel.valueOf("DEBUG"));
		final LogLevel logLevel1 = LogLevel.WARNING;
		Assert.assertEquals("WARNING", logLevel1.toString());
	}

	@Test
	public void testGetDefaultLogLevel() {
		Assert.assertEquals(LogLevel.INFO, LogOptions.DEFAULT_LOGLEVEL);
		Assert.assertEquals("INFO", LogOptions.DEFAULT_LOGLEVEL_AS_STRING);
	}

	@Test
	public void testPreferenceLogLevelSetting() throws BackingStoreException {
		final LogLevel logLevel1 = LogOptions.getLogLevel();
		Assert.assertEquals(LogLevel.INFO, logLevel1);
		final IEclipsePreferences prefs = InstanceScope.INSTANCE
		        .getNode(LogOptions.QUALIFIER);
		Assert.assertNotNull(prefs);
		final String trace = "TRACE";
		prefs.put(LogOptions.KEY, trace);
		final LogLevel logLevel2 = LogOptions.getLogLevel();
		Assert.assertEquals(LogLevel.TRACE, logLevel2);
		prefs.put(LogOptions.KEY, "INFO");
		final LogLevel logLevel3 = LogOptions.getLogLevel();
		Assert.assertEquals(LogLevel.INFO, logLevel3);
		prefs.clear();
	}

}
