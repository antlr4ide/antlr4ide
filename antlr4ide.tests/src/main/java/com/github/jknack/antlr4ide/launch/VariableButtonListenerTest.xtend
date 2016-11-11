package com.github.jknack.antlr4ide.parser

import static org.junit.Assert.*

import com.github.jknack.antlr4ide.ui.launch.VariableButtonListener
import com.github.jknack.antlr4ide.Antlr4TestInjectorProvider
import org.eclipse.core.variables.IValueVariable;
import org.eclipse.core.variables.VariablesPlugin;
import org.eclipse.xtext.junit4.XtextRunner
import org.junit.runner.RunWith
import org.junit.Test

@RunWith(XtextRunner)
class VariableButtonListenerTest {
  
  @Test
  def void testVariableSubstitution() {
  	val manager = VariablesPlugin.getDefault().getStringVariableManager()
  	val var1 = manager.newValueVariable("my", "", false, "MyTestProject")
  	val var2 = manager.newValueVariable("hello", "hello world!", false, "Hello")
  	val var3 = manager.newValueVariable("ext", "", true, "g4");
  	val IValueVariable[] vars = #[ var1, var2, var3 ];
  	manager.addVariables(vars);
  	val path = "/${my}/${hello}.${ext}";
    val actual = VariableButtonListener.substituteVariables(path);
    val expected = "/MyTestProject/Hello.g4";
    assertEquals(expected, actual);
  }
}
