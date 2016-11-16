package com.github.jknack.antlr4ide.ui.wizard;

import org.eclipse.ui.dialogs.WizardNewProjectCreationPage;
import org.eclipse.xtext.ui.wizard.IProjectInfo;
import org.eclipse.xtext.ui.wizard.IProjectCreator;
import com.google.inject.Inject;


public class Antlr4NewProjectWizardX extends org.eclipse.xtext.ui.wizard.XtextNewProjectWizard  {

	private WizardNewProjectCreationPage mainPage;
	
	@Inject
	public Antlr4NewProjectWizardX(IProjectCreator projectCreator) {
		super(projectCreator);
		setWindowTitle("New Antlr4 Project.2");
	}

	/**
	 * Use this method to add pages to the wizard.
	 * The one-time generated version of this class will add a default new project page to the wizard.
	 */
	@Override
	public void addPages() {
		mainPage = new WizardNewProjectCreationPage("basicNewProjectPage");
		mainPage.setTitle("Antlr4 Project.2");
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
