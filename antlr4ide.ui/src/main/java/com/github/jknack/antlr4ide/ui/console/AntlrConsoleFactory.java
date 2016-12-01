package com.github.jknack.antlr4ide.ui.console;

import java.util.Arrays;

import com.google.inject.Inject;
import org.eclipse.jface.resource.ImageDescriptor;
import org.eclipse.ui.console.IConsole;
import org.eclipse.ui.console.IConsoleFactory;
import org.eclipse.ui.console.IConsoleManager;
import org.eclipse.ui.console.IOConsole;
import org.eclipse.ui.console.ConsolePlugin;
import org.eclipse.xtext.ui.IImageHelper;

public class AntlrConsoleFactory implements IConsoleFactory {
	
	public static final String ANTLR_CONSOLE = "ANTLR Console";

	@Inject
	private static IImageHelper.IImageDescriptorHelper imageHelper;
	
	@Override
	public void openConsole() {
		IConsoleManager manager = ConsolePlugin.getDefault().getConsoleManager();
		final IOConsole console = getConsole();
		manager.showConsoleView(console);
	}
	
	protected static IOConsole getConsole() {
		final IConsoleManager manager = ConsolePlugin.getDefault().getConsoleManager();
		final IConsole[] existing = manager.getConsoles();
		final int size = existing.length;
		for (int i = 0; i < size; i++) {
			final IConsole console = existing[i];
			if (ANTLR_CONSOLE == console.getName()) {
				return (IOConsole)console;
			}
		}
		ImageDescriptor imageDescriptor = imageHelper.getImageDescriptor("console.png");
		final IOConsole console = new IOConsole(ANTLR_CONSOLE, imageDescriptor);
		final IConsole[] consoles = Arrays.copyOf(existing, size + 1);
		consoles[size] = console;
		manager.addConsoles(consoles);
		return console;
	}
	
}
