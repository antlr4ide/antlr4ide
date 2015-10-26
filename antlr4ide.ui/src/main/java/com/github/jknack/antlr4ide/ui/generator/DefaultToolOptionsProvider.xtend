package com.github.jknack.antlr4ide.ui.generator

import com.github.jknack.antlr4ide.generator.ToolOptionsProvider
import org.eclipse.xtext.builder.EclipseOutputConfigurationProvider
import com.google.inject.Inject
import org.eclipse.xtext.ui.editor.preferences.IPreferenceStoreAccess
import com.github.jknack.antlr4ide.generator.ToolOptions
import org.eclipse.jface.preference.IPreferenceStore
import org.eclipse.core.resources.IFile
import com.github.jknack.antlr4ide.generator.Distributions
import org.eclipse.emf.common.util.URI
import org.eclipse.xtext.ui.resource.IResourceSetProvider
import com.github.jknack.antlr4ide.lang.Grammar
import com.github.jknack.antlr4ide.lang.GrammarAction
import java.util.regex.Pattern
import org.eclipse.debug.core.ILaunchManager
import com.github.jknack.antlr4ide.generator.LaunchConstants

class DefaultToolOptionsProvider implements ToolOptionsProvider {

  @Inject
  private EclipseOutputConfigurationProvider configurationProvider

  @Inject
  private IPreferenceStoreAccess preferenceStore

  @Inject
  IResourceSetProvider resourceSetProvider

  /** Launch manager. */
  @Inject
  ILaunchManager launchManager

  static val PKG_NAME = Pattern.compile("package\\s+(([a-zA_Z_][\\.\\w]*))\\s*;")

  override options(IFile file) {
    val project = file.project
    val store = preferenceStore.getContextPreferenceStore(project)
    val output = configurationProvider.getOutputConfigurations(project).last
    val pkgName = try {
        val uri = URI.createFileURI(file.location.toString)
        val resourceSet = resourceSetProvider.get(file.project)
        val resource = resourceSet.getResource(uri, true)
        val grammar = resource.contents.get(0) as Grammar
        val pkgNames = grammar.prequels.filter(GrammarAction).filter[it.name == "header"].map[
          val matcher = PKG_NAME.matcher(it.action)
          return if (matcher.find) matcher.group(1).trim else null
        ]
        if (pkgNames.empty) null else pkgNames.head
      } catch (Exception ex) {
        return null
      }

    val defaults = new ToolOptions => [
      antlrTool = getString(ToolOptions.BUILD_TOOL_PATH, store,
        Distributions.defaultDistribution.value
      )
      outputDirectory = output.outputDirectory
      packageName = pkgName
      packageInsideAction = pkgName != null
      listener = getBoolean(ToolOptions.BUILD_LISTENER, store, true)
      visitor = getBoolean(ToolOptions.BUILD_VISITOR, store, false)
      encoding = getString(ToolOptions.BUILD_ENCODING, store, "UTF-8")
      vmArgs = getString(ToolOptions.VM_ARGS, store, "")
      derived = output.setDerivedProperty
      cleanUpDerivedResources = output.cleanUpDerivedResources
    ]

    return options(file, defaults)
  }

  /**
   * Find a launch configuration and create tool options from there. If no launch configuration
   * exists, the defaults options will be used it.
   */
  private def options(IFile file, ToolOptions defaults) {
    val grammar = file.fullPath.toOSString
    val configType = launchManager.getLaunchConfigurationType(LaunchConstants.LAUNCH_ID)
    var configurations = launchManager.getLaunchConfigurations(configType)

    val existing = configurations.filter [ launch |
      if (grammar == launch.getAttribute(LaunchConstants.GRAMMAR, "")) {
        return true
      }
      return false
    ]

    if (existing.size > 0) {

      // launch existing
      val config = existing.head
      val args = config.getAttribute(LaunchConstants.ARGUMENTS, "")
      val options = ToolOptions.parse(args) [ message |
      ]

      // set some defaults if they are missing
      if (options.outputDirectory == null) {
        options.outputDirectory = defaults.outputDirectory
      }
      if (options.packageName == null ) {
        options.packageName = defaults.packageName
        options.packageInsideAction = defaults.packageInsideAction
      }
      options.antlrTool = defaults.antlrTool
      return options
    } else {
      return defaults
    }
  }

  private def getBoolean(String key, IPreferenceStore store, Boolean defaultValue) {
    if (store.contains(key)) {
      store.getBoolean(key)
    } else {
      defaultValue
    }
  }

  private def getString(String key, IPreferenceStore store, String defaultValue) {
    if (store.contains(key)) {
      store.getString(key)
    } else {
      defaultValue
    }
  }

  def getLaunchManager() {
    return launchManager
  }
}