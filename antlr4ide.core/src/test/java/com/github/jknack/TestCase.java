package com.github.jknack;

import static org.easymock.EasyMock.createMock;

import java.util.ArrayList;
import java.util.List;

import org.easymock.EasyMock;

public abstract class TestCase {

  public interface MockConfigurer<T> {
    public void configure(T mock);
  }

  public class Mock<T> {
    private T mock;

    public Mock(final Class<T> mockType) {
      mock = createMock(mockType);
    }

    public void configure(final MockConfigurer<T> configurer) {
      configurer.configure(mock);
    }

    public void replay() {
      EasyMock.replay(mock);
    }

    public void verify() {
      EasyMock.verify(mock);
    }

    public TestCase endMock() {
      return TestCase.this;
    }
  }

  private List<Mock<?>> mocks = new ArrayList<Mock<?>>();

  public <T> Mock<T> newMock(final Class<T> mockType) {
    Mock<T> mock = new Mock<T>(mockType);
    mocks.add(mock);
    return mock;
  }

  public void run() {
    for(Mock<?> mock : mocks) {
      mock.replay();
    }

    doRun();

    for(Mock<?> mock : mocks) {
      mock.verify();
    }
  }

  protected abstract void doRun();

}
