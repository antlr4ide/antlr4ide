package com.github.jknack.ui.launch

import org.eclipse.debug.ui.AbstractLaunchConfigurationTabGroup
import org.eclipse.debug.ui.ILaunchConfigurationDialog
import com.google.inject.Inject
import com.google.inject.Injector
import org.eclipse.debug.ui.AbstractLaunchConfigurationTab
import org.eclipse.debug.ui.EnvironmentTab
import org.eclipse.debug.ui.CommonTab

class Antlr4ToolTabGroup extends AbstractLaunchConfigurationTabGroup {
  @Inject
  Injector injector

  override createTabs(ILaunchConfigurationDialog dialog, String mode) {
    this.tabs = #[newTab(MainTab), new EnvironmentTab, new CommonTab]
  }

  def newTab(Class<? extends AbstractLaunchConfigurationTab> tabClass) {
    injector.getInstance(tabClass)
  }
}
