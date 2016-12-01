package com.github.jknack.antlr4ide.console;

import org.eclipse.core.runtime.preferences.IEclipsePreferences;
import org.eclipse.core.runtime.preferences.InstanceScope;
import org.junit.Assert;
import org.junit.Test;

import org.apache.log4j.Level;
import org.apache.log4j.LogManager;
import org.osgi.service.prefs.BackingStoreException;

public class ConsoleTest {

	@Test
	public void testEnumLogLevel() {
		Assert.assertEquals(Level.DEBUG, Level.toLevel("DEBUG"));
		final Level logLevel1 = Level.WARN;
		Assert.assertEquals("WARN", logLevel1.toString());
	}

	@Test
	public void testGetDefaultLogLevel() {
		Assert.assertEquals(Level.INFO, ConsoleImpl.DEFAULT_LOGLEVEL);
		Assert.assertEquals("INFO", ConsoleImpl.DEFAULT_LOGLEVEL_AS_STRING);
	}

	@Test
	public void testPreferenceLogLevelSetting() throws BackingStoreException {
		final Level logLevel1 = ConsoleImpl.getLogLevel();
		Assert.assertEquals(Level.INFO, logLevel1);
		final IEclipsePreferences prefs = InstanceScope.INSTANCE
		        .getNode(ConsoleImpl.QUALIFIER);
		Assert.assertNotNull(prefs);
		final String trace = "TRACE";
		prefs.put(ConsoleImpl.KEY, trace);
		final Level logLevel2 = ConsoleImpl.getLogLevel();
		Assert.assertEquals(Level.TRACE, logLevel2);
		prefs.put(ConsoleImpl.KEY, "INFO");
		final Level logLevel3 = ConsoleImpl.getLogLevel();
		Assert.assertEquals(Level.INFO, logLevel3);
		prefs.clear();
	}

	@Test
	public void testOutputWithDefault() throws Exception {
		// preparations
		final TestAppender appender = new TestAppender();
		final Console console = new ConsoleImpl();
		LogManager.getRootLogger().addAppender(appender);
		// start test
		console.debug("first debug");
		console.warning("some warning");
		console.info("some info");
		console.debug("second debug");
		// check actual against expected
		Assert.assertEquals("", appender.getError());
		Assert.assertEquals("some warning", appender.getWarning());
		Assert.assertEquals("some info", appender.getInfo());
		Assert.assertEquals("", appender.getDebug());
		Assert.assertEquals("", appender.getTrace());
	}
	
}
