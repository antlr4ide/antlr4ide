package com.github.jknack;

import static org.easymock.EasyMock.createMock;
import static org.easymock.EasyMock.expect;
import static org.easymock.EasyMock.replay;
import static org.easymock.EasyMock.verify;
import static org.junit.Assert.assertTrue;

import java.io.File;
import java.net.MalformedURLException;

import org.eclipse.core.runtime.Path;
import org.junit.Test;
import org.osgi.framework.Bundle;
import org.osgi.framework.BundleContext;

import com.github.jknack.generator.Distributions;
import com.github.jknack.generator.ToolOptionsProvider;

public class ActivatorTest {

  @Test
  public void start() throws MalformedURLException {
    String path = "lib/" + ToolOptionsProvider.DEFAULT_TOOL;
    File jar = new File(Distributions.defaultDistribution().getValue());
    if (jar.exists()) {
      jar.delete();
    }

    BundleContext context = createMock(BundleContext.class);
    Bundle bundle = createMock(Bundle.class);

    expect(context.getBundle()).andReturn(bundle);

    expect(bundle.getSymbolicName()).andReturn("antlr4ide.core");

    expect(bundle.getResource(path)).andReturn(
      Path.fromOSString("..").append("antlr4ide.core").append("lib").append(ToolOptionsProvider.DEFAULT_TOOL).
        toFile().toURI().toURL());

    Object[] mocks = {context, bundle};

    replay(mocks);

    new Activator().start(context);

    // must be created again
    assertTrue(jar.exists());

    verify(mocks);
  }

}
