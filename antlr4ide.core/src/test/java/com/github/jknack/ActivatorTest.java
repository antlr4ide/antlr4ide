package com.github.jknack;

import static org.easymock.EasyMock.createMock;
import static org.easymock.EasyMock.expect;
import static org.easymock.EasyMock.replay;
import static org.easymock.EasyMock.verify;
import static org.junit.Assert.assertEquals;

import org.junit.Test;
import org.osgi.framework.Bundle;
import org.osgi.framework.BundleContext;

public class ActivatorTest {

  @Test
  public void start() throws Exception {
    Bundle bundle = createMock(Bundle.class);
    expect(bundle.getSymbolicName()).andReturn("antlr4ide.core");

    BundleContext context = createMock(BundleContext.class);
    expect(context.getBundle()).andReturn(bundle).times(2);

    Object[] mocks = {bundle, context};

    replay(mocks);

    Activator activator = new Activator();
    activator.start(context);

    assertEquals(bundle, Activator.bundle);

    verify(mocks);
  }
}
