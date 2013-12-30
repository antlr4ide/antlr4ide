package com.github.jknack;

import org.eclipse.core.runtime.Plugin;
import org.osgi.framework.Bundle;
import org.osgi.framework.BundleContext;

public class Activator extends Plugin {

  public static Bundle bundle;

  @Override
  public void start(final BundleContext context) throws Exception {
    super.start(context);
    bundle = context.getBundle();
  }

}
