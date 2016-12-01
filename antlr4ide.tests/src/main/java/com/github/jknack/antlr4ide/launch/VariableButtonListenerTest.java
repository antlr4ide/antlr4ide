package com.github.jknack.antlr4ide.launch;

import com.github.jknack.antlr4ide.ui.launch.VariableButtonListener;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.variables.IStringVariableManager;
import org.eclipse.core.variables.IValueVariable;
import org.eclipse.core.variables.VariablesPlugin;
import org.eclipse.xtext.junit4.XtextRunner;
import org.junit.Assert;
import org.junit.runner.RunWith;
import org.junit.Test;

@RunWith(XtextRunner.class)
public class VariableButtonListenerTest {
	
	@Test
	public void testVariableSubstitution() throws CoreException {
		final IStringVariableManager manager =
			VariablesPlugin.getDefault().getStringVariableManager();
		final IValueVariable var1 = manager.newValueVariable("my", "", false, 
			"MyTestProject");
		final IValueVariable var2 = manager.newValueVariable("hello",
			"hello world!", false, "Hello");
		final IValueVariable var3 = manager.newValueVariable("ext", "", true, 
			"g4");
		final IValueVariable[] vars = new IValueVariable[] {var1, var2, var3};
		manager.addVariables(vars);
		final String path = "/${my}/${hello}.${ext}";
		final String actual = VariableButtonListener.substituteVariables(path);
		final String expected = "/MyTestProject/Hello.g4";
		Assert.assertEquals(expected, actual);
	}
	
}
