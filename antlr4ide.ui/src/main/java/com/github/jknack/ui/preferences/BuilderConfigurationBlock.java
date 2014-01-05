package com.github.jknack.ui.preferences;

import java.util.Set;

import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.jobs.Job;
import org.eclipse.jface.dialogs.IDialogSettings;
import org.eclipse.jface.layout.PixelConverter;
import org.eclipse.jface.preference.IPreferenceStore;
import org.eclipse.swt.SWT;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Control;
import org.eclipse.ui.forms.widgets.ExpandableComposite;
import org.eclipse.ui.preferences.IWorkbenchPreferenceContainer;
import org.eclipse.xtext.builder.EclipseOutputConfigurationProvider;
import org.eclipse.xtext.builder.internal.Activator;
import org.eclipse.xtext.builder.preferences.BuilderPreferenceAccess;
import org.eclipse.xtext.generator.OutputConfiguration;
import org.eclipse.xtext.ui.preferences.OptionsConfigurationBlock;
import org.eclipse.xtext.ui.preferences.ScrolledPageContent;

import com.github.jknack.generator.ToolOptions;

/**
 * @author Michael Clay - Initial contribution and API
 * @since 2.1
 */
@SuppressWarnings("restriction")
public class BuilderConfigurationBlock extends OptionsConfigurationBlock {
  private static final String SETTINGS_SECTION_NAME = "BuilderConfigurationBlock"; //$NON-NLS-1$

  private EclipseOutputConfigurationProvider configurationProvider;

  public BuilderConfigurationBlock(final IProject project, final IPreferenceStore preferenceStore,
      final EclipseOutputConfigurationProvider configurationProvider,
      final IWorkbenchPreferenceContainer container) {
    super(project, preferenceStore, container);
    this.configurationProvider = configurationProvider;
  }

  @Override
  protected Control doCreateContents(final Composite parent) {
    PixelConverter pixelConverter = new PixelConverter(parent);
    setShell(parent.getShell());
    Composite mainComp = new Composite(parent, SWT.NONE);
    mainComp.setFont(parent.getFont());
    GridLayout layout = new GridLayout();
    layout.marginHeight = 0;
    layout.marginWidth = 0;
    mainComp.setLayout(layout);
    Composite othersComposite = createBuildPathTabContent(mainComp);
    GridData gridData = new GridData(GridData.FILL, GridData.FILL, true, true);
    gridData.heightHint = pixelConverter.convertHeightInCharsToPixels(20);
    othersComposite.setLayoutData(gridData);
    validateSettings(null, null, null);
    return mainComp;
  }

  private Composite createBuildPathTabContent(final Composite parent) {
    String[] trueFalseValues = new String[]{IPreferenceStore.TRUE, IPreferenceStore.FALSE };
    int columns = 3;
    final ScrolledPageContent pageContent = new ScrolledPageContent(parent);
    GridLayout layout = new GridLayout();
    layout.numColumns = columns;
    layout.marginHeight = 0;
    layout.marginWidth = 0;

    Composite composite = pageContent.getBody();
    composite.setLayout(layout);
    ExpandableComposite excomposite = createStyleSection(composite, "ANTLR Tool", columns);

    Composite othersComposite = new Composite(excomposite, SWT.NONE);
    excomposite.setClient(othersComposite);
    othersComposite.setLayout(new GridLayout(columns, false));

    addCheckBox(othersComposite, "Tool is activated",
        BuilderPreferenceAccess.PREF_AUTO_BUILDING, trueFalseValues, 0);

    addTextField(othersComposite, "JAR", ToolOptions.BUILD_ANTLR_TOOL, 0, 340);

    Set<OutputConfiguration> outputConfigurations = configurationProvider
        .getOutputConfigurations(getProject());

    for (OutputConfiguration outputConfiguration : outputConfigurations) {
      excomposite = createStyleSection(composite, outputConfiguration.getDescription(), columns);
      othersComposite = new Composite(excomposite, SWT.NONE);
      excomposite.setClient(othersComposite);
      othersComposite.setLayout(new GridLayout(columns, false));

      addTextField(othersComposite, "Directory",
          BuilderPreferenceAccess.getKey(outputConfiguration,
              EclipseOutputConfigurationProvider.OUTPUT_DIRECTORY), 0, 300);

      addCheckBox(othersComposite, "Generate a parse tree listener (-listener)",
          ToolOptions.BUILD_LISTENER, trueFalseValues, 0);

      addCheckBox(othersComposite, "Generate parse tree visitors (-visitor)",
          ToolOptions.BUILD_VISITOR, trueFalseValues, 0);

      addTextField(othersComposite, "Encoding",
          ToolOptions.BUILD_ENCODING, 0, 100);

      addCheckBox(othersComposite, "Create directory, if it doesn't exist",
          BuilderPreferenceAccess.getKey(outputConfiguration,
              EclipseOutputConfigurationProvider.OUTPUT_CREATE_DIRECTORY), trueFalseValues, 0);

      addCheckBox(othersComposite, "Mark generated files as derived",
          BuilderPreferenceAccess.getKey(outputConfiguration,
              EclipseOutputConfigurationProvider.OUTPUT_DERIVED), trueFalseValues, 0);
    }

    excomposite = createStyleSection(composite, "VM Arguments", columns);
    othersComposite = new Composite(excomposite, SWT.NONE);
    excomposite.setClient(othersComposite);
    othersComposite.setLayout(new GridLayout(columns, false));

    addTextField(othersComposite, "", ToolOptions.VM_ARGS, 0, 360);

    registerKey(OptionsConfigurationBlock.IS_PROJECT_SPECIFIC);
    IDialogSettings section = Activator.getDefault().getDialogSettings()
        .getSection(SETTINGS_SECTION_NAME);
    restoreSectionExpansionStates(section);
    return pageContent;
  }

  @Override
  protected void validateSettings(final String changedKey, final String oldValue,
      final String newValue) {
  }

  @Override
  public void dispose() {
    IDialogSettings settings = Activator.getDefault().getDialogSettings()
        .addNewSection(SETTINGS_SECTION_NAME);
    storeSectionExpansionStates(settings);
    super.dispose();
  }

  @Override
  protected String[] getFullBuildDialogStrings(final boolean workspaceSettings) {
    String title = "Building Settings Changed";
    String message;
    if (workspaceSettings) {
      message = "The Building settings have changed. A full rebuild is required for changes to"
          + " take effect. Do the full build now?";
    } else {
      message = "The Building settings have changed. A rebuild of the project is required for "
          + "changes to take effect. Build the project now?";
    }
    return new String[]{title, message };
  }

  @Override
  protected Job getBuildJob(final IProject project) {
    Job buildJob = new OptionsConfigurationBlock.BuildJob("Rebuilding", project);
    buildJob.setRule(ResourcesPlugin.getWorkspace().getRuleFactory().buildRule());
    buildJob.setUser(true);
    return buildJob;
  }

}
