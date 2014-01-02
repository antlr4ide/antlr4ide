package com.github.jknack;

import org.eclipse.core.runtime.Plugin;
import org.osgi.framework.Bundle;
import org.osgi.framework.BundleContext;

/**
 * The plugin activator.
 *
 * @author edgar
 */
public class Activator extends Plugin {

  /**
   * Shared bundle. If the plugin was not initialized, bundle will be null.
   */
  public static Bundle bundle;

  @Override
  public void start(final BundleContext context) throws Exception {
    super.start(context);
    bundle = context.getBundle();
  }

}
