/**
 * This class is based on the xtend generated class /antlr4ide/antlr4ide.ui/src/generated/java/com/github/jknack/antlr4ide/ui/wizard/Antlr4NewProjectWizard.java
 * This version has the addition of storing the project location if the user select override default location.
 */
package com.github.jknack.antlr4ide.ui.wizard;

import org.eclipse.ui.dialogs.WizardNewProjectCreationPage;
import org.eclipse.xtext.ui.wizard.IProjectInfo;
import org.eclipse.xtext.ui.wizard.IProjectCreator;
import com.google.inject.Inject;


public class Antlr4NewProjectWizardV2 extends org.eclipse.xtext.ui.wizard.XtextNewProjectWizard  {

	private WizardNewProjectCreationPage mainPage;
	
	@Inject
	public Antlr4NewProjectWizardV2(IProjectCreator projectCreator) {
		super(projectCreator);
		setWindowTitle("New Antlr4 Project");
	}

	/**
	 * Use this method to add pages to the wizard.
	 * The one-time generated version of this class will add a default new project page to the wizard.
	 */
	@Override
	public void addPages() {
		mainPage = new WizardNewProjectCreationPage("basicNewProjectPage");
		mainPage.setTitle("Antlr4 Project");
		mainPage.setDescription("Create a new Antlr4 project.");
		addPage(mainPage);
	}

	
	/**
	 * Use this method to read the project settings from the wizard pages and feed them into the project info class.
	 */
	@Override
	protected IProjectInfo getProjectInfo() {
		com.github.jknack.antlr4ide.ui.wizard.Antlr4ProjectInfo projectInfo = new com.github.jknack.antlr4ide.ui.wizard.Antlr4ProjectInfo();
		projectInfo.setProjectName(mainPage.getProjectName());
        if (!mainPage.useDefaults()) {
            projectInfo.setLocationPath(mainPage.getLocationPath());
        }
		return projectInfo;
	}

}
