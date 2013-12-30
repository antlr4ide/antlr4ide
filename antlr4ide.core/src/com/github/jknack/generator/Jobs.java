package com.github.jknack.generator;

import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.jobs.Job;

import com.google.common.base.Function;

public class Jobs {

  public static Job job(final String name, final Function<IProgressMonitor, IStatus> fn) {
    return new Job(name) {
      @Override
      protected IStatus run(final IProgressMonitor monitor) {
        return fn.apply(monitor);
      }
    };
  }

  public static Job schedule(final String name, final Function<IProgressMonitor, IStatus> fn) {
    Job job = job(name, fn);
    job.schedule();
    return job;
  }
}
