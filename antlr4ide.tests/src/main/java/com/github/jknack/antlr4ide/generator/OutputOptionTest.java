package com.github.jknack.antlr4ide.generator;

import org.eclipse.core.runtime.IPath;
import org.eclipse.core.runtime.Path;
import org.junit.Assert;
import org.junit.Test;

public class OutputOptionTest {

	@Test
	public void newOutputOption() {
		final IPath absolutePath = Path.fromOSString("absolutePath");
		final IPath relativePath = Path.fromOSString("relativePath");
		final String packageName = "org.demo";

		final OutputOption option = new OutputOption(absolutePath, relativePath,
				packageName);
		Assert.assertEquals(absolutePath, option.getAbsolute());
		Assert.assertEquals(relativePath, option.getRelative());
		Assert.assertEquals(packageName, option.getPackageName());
		//final String expected = "[OutputOption [absolute=" + absolutePath + ",packageName="
		//		+ packageName + ",relative=" + relativePath + "]]";
		//final String toString = option.toString();
		//Assert.assertEquals(expected, toString);
	}
	
	@Test
	public void testEquals() {
		final IPath absolutePath1 = Path.fromOSString("absolutePath");
		final IPath absolutePath2 = Path.fromOSString("absolutePath");
		final IPath relativePath1 = Path.fromOSString("relativePath");
		final IPath relativePath2 = Path.fromOSString("relativePath");
		final String packageName1 = "org.demo";
		final String packageName2 = "org.demo";
		final String packageName3 = "org.other";
		
		final OutputOption option1 = new OutputOption(absolutePath1, relativePath1,
				packageName1);
		final OutputOption option2 = new OutputOption(absolutePath2, relativePath2,
				packageName2);
		Assert.assertTrue(option1.equals(option1));
		Assert.assertTrue(option1.equals(option2));
		Assert.assertTrue(option2.equals(option1));
		// now the ones that differ in exactly one parameter
		final OutputOption option3 = new OutputOption(relativePath1, relativePath1,
				packageName1);
		final OutputOption option4 = new OutputOption(absolutePath1, absolutePath1,
				packageName1);
		final OutputOption option5 = new OutputOption(absolutePath1, relativePath1,
				packageName3);
		final OutputOption option6 = new OutputOption(absolutePath1, relativePath1,
				packageName3);
		Assert.assertFalse(option1.equals(option3));
		Assert.assertFalse(option2.equals(option4));
		Assert.assertFalse(option3.equals(option5));
		Assert.assertFalse(option4.equals(option1));
		Assert.assertFalse(option5.equals(option2));
		Assert.assertTrue(option5.equals(option6));
	}

}
