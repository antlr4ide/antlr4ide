package com.github.jknack.antlr4ide.ui.preferences

import org.eclipse.core.resources.IProject
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.core.runtime.jobs.Job
import org.eclipse.jface.layout.PixelConverter
import org.eclipse.jface.preference.IPreferenceStore
import org.eclipse.jface.viewers.TableViewer
import org.eclipse.swt.SWT
import org.eclipse.swt.layout.GridData
import org.eclipse.swt.layout.GridLayout
import org.eclipse.swt.widgets.Button
import org.eclipse.swt.widgets.Composite
import org.eclipse.swt.widgets.Control
import org.eclipse.swt.widgets.Group
import org.eclipse.swt.widgets.TableColumn
import org.eclipse.ui.preferences.IWorkbenchPreferenceContainer
import org.eclipse.xtext.builder.EclipseOutputConfigurationProvider
import org.eclipse.xtext.builder.internal.Activator
import org.eclipse.xtext.builder.preferences.BuilderPreferenceAccess
import org.eclipse.xtext.ui.preferences.OptionsConfigurationBlock
import org.eclipse.xtext.ui.preferences.ScrolledPageContent

import com.github.jknack.antlr4ide.generator.ToolOptions
import org.eclipse.jface.viewers.ArrayContentProvider
import org.eclipse.jface.viewers.LabelProvider
import org.eclipse.jface.viewers.ITableLabelProvider
import org.eclipse.xtext.ui.IImageHelper
import static extension com.github.jknack.antlr4ide.ui.Widgets.*
import org.eclipse.swt.widgets.FileDialog
import com.github.jknack.antlr4ide.generator.Distributions
import java.io.File
import java.util.Collection
import com.google.common.collect.Lists
import com.google.common.collect.Sets
import org.eclipse.jface.viewers.IStructuredSelection
import org.eclipse.swt.widgets.TableItem
import java.util.Map
import org.eclipse.jface.dialogs.MessageDialog

/**
 * @author Michael Clay - Initial contribution and API
 * @since 2.1
 */
@SuppressWarnings("restriction")
class BuilderConfigurationBlock extends OptionsConfigurationBlock {
  static val SETTINGS_SECTION_NAME = "BuilderConfigurationBlock"

  EclipseOutputConfigurationProvider configurationProvider

  IImageHelper imageHelper

  Map<String, String> transientStore = newHashMap()

  IPreferenceStore preferenceStore

  new(IProject project, IPreferenceStore preferenceStore, EclipseOutputConfigurationProvider configurationProvider,
    IWorkbenchPreferenceContainer container, IImageHelper imageHelper) {
    super(project, preferenceStore, container)
    this.configurationProvider = configurationProvider
    this.imageHelper = imageHelper
  }

  override Control doCreateContents(Composite parent) {
    val pixelConverter = new PixelConverter(parent)
    shell = parent.shell
    val mainComp = new Composite(parent, SWT.NONE)
    mainComp.font = parent.font
    val layout = new GridLayout
    layout.marginHeight = 0
    layout.marginWidth = 0
    mainComp.layout = layout
    val othersComposite = createBuildPathTabContent(mainComp)
    val gridData = new GridData(GridData.FILL, GridData.FILL, true, true)
    gridData.heightHint = pixelConverter.convertHeightInCharsToPixels(20)
    othersComposite.setLayoutData(gridData)
    validateSettings(null, null, null)
    return mainComp
  }

  private def Composite createBuildPathTabContent(Composite parent) {
    val trueFalseValues = #[IPreferenceStore.TRUE, IPreferenceStore.FALSE]
    val columns = 3
    val pageContent = new ScrolledPageContent(parent)
    val layout = new GridLayout
    layout.numColumns = columns
    layout.marginHeight = 0
    layout.marginWidth = 0

    val composite = pageContent.body
    composite.layout = layout
    var excomposite = createStyleSection(composite, "ANTLR Tool", columns)

    var othersComposite = new Composite(excomposite, SWT.NONE)
    excomposite.client = othersComposite
    othersComposite.layout = new GridLayout(columns, false)

    addCheckBox(othersComposite, "Tool is activated", BuilderPreferenceAccess.PREF_AUTO_BUILDING, trueFalseValues, 0)

    createPackagePanel(othersComposite)

    val outputConfiguration = configurationProvider.getOutputConfigurations(project).head

    excomposite = createStyleSection(composite, outputConfiguration.getDescription(), columns)
    othersComposite = new Composite(excomposite, SWT.NONE)
    excomposite.setClient(othersComposite)
    othersComposite.setLayout(new GridLayout(columns, false))

    addTextField(othersComposite, "Directory",
      BuilderPreferenceAccess.getKey(outputConfiguration,
        EclipseOutputConfigurationProvider.OUTPUT_DIRECTORY), 0, 300)

    addCheckBox(othersComposite, "Generate a parse tree listener (-listener)", ToolOptions.BUILD_LISTENER,
      trueFalseValues, 0)

    addCheckBox(othersComposite, "Generate parse tree visitors (-visitor)", ToolOptions.BUILD_VISITOR,
      trueFalseValues, 0)

    addTextField(othersComposite, "Encoding", ToolOptions.BUILD_ENCODING, 0, 100)

    addCheckBox(othersComposite, "Mark generated files as derived",
      BuilderPreferenceAccess.getKey(outputConfiguration,
        EclipseOutputConfigurationProvider.OUTPUT_DERIVED), trueFalseValues, 0)

    excomposite = createStyleSection(composite, "VM Arguments", columns)
    othersComposite = new Composite(excomposite, SWT.NONE)
    excomposite.setClient(othersComposite)
    othersComposite.setLayout(new GridLayout(columns, false))

    addTextField(othersComposite, "", ToolOptions.VM_ARGS, 0, 360)

    registerKey(OptionsConfigurationBlock.IS_PROJECT_SPECIFIC)
    val section = Activator.^default.dialogSettings.getSection(SETTINGS_SECTION_NAME)
    restoreSectionExpansionStates(section)
    return pageContent
  }

  private def Composite createSubsection(Composite parent, String label) {
    val group = new Group(parent, SWT.SHADOW_NONE)
    group.text = label
    group.layoutData = new GridData(SWT.FILL, SWT.CENTER, true, false)
    return group
  }

  private def Composite createPackagePanel(Composite parent) {
    val composite = createSubsection(parent, "Distributions")

    val layout = new GridLayout(2, false)

    layout.verticalSpacing = 10

    composite.setLayout(layout)

    val packageViewer = new TableViewer(composite,
      SWT.CHECK.bitwiseOr(SWT.BORDER).bitwiseOr(SWT.V_SCROLL).bitwiseOr(SWT.H_SCROLL).bitwiseOr(SWT.SINGLE).
        bitwiseOr(SWT.FULL_SELECTION))

    val table = packageViewer.table
    table.addListener(SWT.Selection) [ event |
      if (event.detail == SWT.CHECK) {
        table.items.forEach[checked = false]
        val item = event.item as TableItem
        item.checked = true
        val distribution = event.item.data as Pair<String, String>
        setValue(ToolOptions.BUILD_TOOL_PATH, distribution.value)
      }
    ]

    var gd = new GridData(GridData.FILL_BOTH)

    gd.verticalSpan = 8
    gd.horizontalSpan = 2
    table.layoutData = gd
    table.headerVisible = true
    table.linesVisible = true
    packageViewer.useHashlookup = true

    val widths = #[75, 250]
    #["Version", "Path"].forEach [ name, index |
      val tableColumn = new TableColumn(table, SWT.LEFT)
      tableColumn.text = name
      tableColumn.width = widths.get(index)
    ]

    packageViewer.labelProvider = new DistributionLabelProvider(imageHelper)
    packageViewer.contentProvider = ArrayContentProvider.instance

    val addButton = new Button(composite, SWT.NONE)
    gd = new GridData
    gd.widthHint = 100
    addButton.layoutData = gd
    addButton.text = "Add"

    addButton.onClick [
      val dialog = new FileDialog(parent.shell)
      dialog.filterExtensions = #["*.jar"]
      val file = dialog.open
      if (file != null) {
        val distribution = Distributions.get(new File(file))
        if (distribution.key != "") {
          val packages = Lists.newArrayList(packageViewer.input as Collection<Pair<String, String>>)
          packages.add(distribution.key -> file)
          packageViewer.input = Sets.newLinkedHashSet(packages)
          setValue(ToolOptions.BUILD_ANTLR_TOOLS, Distributions.toString(packages).toString)
        } else {
          MessageDialog.openError(parent.shell, '''Invalid JAR: "«file»"''',
            "Visit http://www.antlr.org/download.html and download the:\n" +
              "\"Complete ANTLR 4.x Java binaries jar\" distribution")
        }
      }
    ]

    val removeButton = new Button(composite, SWT.NONE)
    gd = new GridData
    gd.widthHint = 100
    removeButton.layoutData = gd
    removeButton.text = "Remove"

    removeButton.onClick [
      val selectionIndex = table.selectionIndex
      if (selectionIndex > 0) {
        val packages = Lists.newArrayList(packageViewer.input as Collection<Pair<String, String>>)
        packages.remove(selectionIndex)

        // update UI
        packageViewer.input = Sets.newLinkedHashSet(packages)

        // reset tools
        setValue(ToolOptions.BUILD_ANTLR_TOOLS, Distributions.toString(packages).toString)

        // select/choose and save previous version
        val item = table.getItem(selectionIndex - 1)
        item.checked = true
        val distribution = item.data as Pair<String, String>
        setValue(ToolOptions.BUILD_TOOL_PATH, distribution.value)
      }
    ]

    packageViewer.addSelectionChangedListener [ event |
      val selection = event.selection as IStructuredSelection
      if (!selection.empty) {
        val selected = selection.firstElement as Pair<String, String>
        val packages = packageViewer.input as Collection<Pair<String, String>>

        removeButton.enabled = packages.head != selected
      } else {
        removeButton.enabled = true
      }
    ]

    packageViewer.input = try {
      Distributions.fromString(getValue(ToolOptions.BUILD_ANTLR_TOOLS))
    } catch (Exception ex) {
      Sets.newHashSet(Distributions.defaultDistribution)
    }

    // Select current tool
    val distribution = getValue(ToolOptions.BUILD_TOOL_PATH)

    val item = table.items.findFirst [
      val current = it.data as Pair<String, String>
      return current.value == distribution
    ]
    if(item != null) item.checked = true

    registerKey(ToolOptions.BUILD_TOOL_PATH)
    registerKey(ToolOptions.BUILD_ANTLR_TOOLS)

    return composite
  }

  override validateSettings(String changedKey, String oldValue, String newValue) {
  }

  override dispose() {
    val settings = Activator.^default.dialogSettings.addNewSection(SETTINGS_SECTION_NAME)
    storeSectionExpansionStates(settings)
    super.dispose()
  }

  override getFullBuildDialogStrings(boolean workspaceSettings) {
    val title = "Building Settings Changed"
    val message = if (workspaceSettings) {
        "The Building settings have changed. A full rebuild is required for changes to" +
          " take effect. Do the full build now?"
      } else {
        "The Building settings have changed. A rebuild of the project is required for " +
          "changes to take effect. Build the project now?"
      }
    return #[title, message]
  }

  override Job getBuildJob(IProject project) {
    val buildJob = new OptionsConfigurationBlock.BuildJob("Rebuilding", project)
    buildJob.rule = ResourcesPlugin.workspace.ruleFactory.buildRule
    buildJob.user = true
    return buildJob
  }

  override protected setValue(String key, String value) {
    transientStore.put(key, value)
  }

  override performDefaults() {
    super.performDefaults
  }

  override performApply() {
    storeTransientValues
    return super.performApply
  }

  override performOk() {
    storeTransientValues
    return super.performOk
  }

  def private storeTransientValues() {
    transientStore.forEach [ name, value |
      this.preferenceStore.putValue(name, value)
    ]
    // clear distributions cache
    Distributions.clear
  }

  override setPreferenceStore(IPreferenceStore preferenceStore) {
    super.preferenceStore = preferenceStore
    this.preferenceStore = preferenceStore
  }

}

class DistributionLabelProvider extends LabelProvider implements ITableLabelProvider {

  IImageHelper imageHelper

  new(IImageHelper imageHelper) {
    this.imageHelper = imageHelper
  }

  override getColumnImage(Object element, int columnIndex) {
    if(columnIndex == 0) imageHelper.getImage("package.png") else null
  }

  override getColumnText(Object element, int columnIndex) {
    val row = element as Pair<String, String>
    if(columnIndex == 0) row.key else row.value
  }

}
