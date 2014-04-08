package com.github.jknack.antlr4ide.generator;

import static com.google.common.base.Preconditions.checkNotNull;

import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.Status;
import org.eclipse.core.runtime.jobs.Job;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1;

import com.google.common.base.Function;

/**
 * Statics method for creating {@link Job}.
 *
 * @author edgar
 */
public class Jobs {

  /**
   * Creates a new job.
   *
   * @param name The job name.
   * @param fn The job execution body.
   * @return A new job.
   */
  public static Job job(final String name, final Function<IProgressMonitor, IStatus> fn) {
    checkNotNull(name);
    checkNotNull(fn);
    return new Job(name) {
      @Override
      protected IStatus run(final IProgressMonitor monitor) {
        return fn.apply(monitor);
      }

      @Override
      public String toString() {
        return name;
      }
    };
  }

  /**
   * Creates a new job.
   *
   * @param name The job name.
   * @param fn The job execution body.
   * @return A new job.
   */
  public static Job job(final String name, final Procedure1<IProgressMonitor> fn) {
    checkNotNull(name);
    checkNotNull(fn);
    return new Job(name) {
      @Override
      protected IStatus run(final IProgressMonitor monitor) {
        fn.apply(monitor);
        return Status.OK_STATUS;
      }

      @Override
      public String toString() {
        return name;
      }
    };
  }

  /**
   * Schedule a new job.
   *
   * @param name The job's name.
   * @param fn The job's execution body.
   * @return A new job.
   */
  public static Job schedule(final String name, final Function<IProgressMonitor, IStatus> fn) {
    Job job = job(name, fn);
    job.schedule();
    return job;
  }

  /**
   * Creates a new system job.
   *
   * @param name The job's name.
   * @param fn The job's execution body.
   * @return A new job.
   */
  public static Job system(final String name, final Procedure1<IProgressMonitor> fn) {
    Job job = job(name, fn);
    job.setSystem(true);
    return job;
  }

}
