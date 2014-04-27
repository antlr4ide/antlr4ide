package com.github.jknack.antlr4ide;

import static org.easymock.EasyMock.createMock;
import static org.easymock.EasyMock.expect;
import static org.easymock.EasyMock.replay;
import static org.easymock.EasyMock.verify;
import static org.junit.Assert.assertTrue;

import java.io.File;
import java.io.FilenameFilter;
import java.net.MalformedURLException;
import java.util.Dictionary;

import org.eclipse.core.runtime.Path;
import org.junit.Test;
import org.osgi.framework.Bundle;
import org.osgi.framework.BundleContext;

import com.github.jknack.antlr4ide.generator.Distributions;
import com.github.jknack.antlr4ide.generator.ToolOptionsProvider;

public class ActivatorTest {

  @Test
  public void start() throws MalformedURLException {
    String path = "lib/" + ToolOptionsProvider.DEFAULT_TOOL;
    String version = version(Path.fromOSString("..").append("antlr4ide.core").append("lib")
        .toFile());
    String runtime = "lib/antlr4ide.runtime-" + version + ".jar";
    File[] jars = {new File(Distributions.defaultDistribution().getValue()),
        new File(System.getProperty("java.io.tmpdir"), "antlr4ide.runtime-" + version + ".jar") };
    for (File jar : jars) {
      jar.delete();
    }

    @SuppressWarnings("unchecked")
    Dictionary<String, String> headers = createMock(Dictionary.class);
    expect(headers.get("Bundle-Version")).andReturn(version);

    Bundle bundle = createMock(Bundle.class);
    expect(bundle.getHeaders()).andReturn(headers);

    BundleContext context = createMock(BundleContext.class);
    expect(context.getBundle()).andReturn(bundle).times(2);

    expect(bundle.getSymbolicName()).andReturn("antlr4ide.core");

    expect(bundle.getResource(path)).andReturn(
        Path.fromOSString("..").append("antlr4ide.core").append("lib")
            .append(ToolOptionsProvider.DEFAULT_TOOL).
            toFile().toURI().toURL());

    expect(bundle.getResource(runtime)).andReturn(
        Path.fromOSString("..").append("antlr4ide.core").append("lib")
            .append("antlr4ide.runtime-" + version + ".jar").
            toFile().toURI().toURL());

    Object[] mocks = {context, bundle, headers };

    replay(mocks);

    new Activator().start(context);

    // must be created again
    for (File jar : jars) {
      System.out.println(jar );
      assertTrue(jar.exists());
    }

    verify(mocks);
  }

  private String version(final File lib) {
    String name = lib.list(new FilenameFilter() {
      @Override
      public boolean accept(final File dir, final String name) {
        return name.startsWith("antlr4ide.runtime");
      }
    })[0];
    return name.substring(name.indexOf("-") + 1).replace(".jar", "");
  }

}
