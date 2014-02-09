package com.github.jknack.ui.generator

import com.github.jknack.generator.CodeGeneratorListener
import org.eclipse.core.resources.IFile
import org.eclipse.core.runtime.NullProgressMonitor
import org.eclipse.core.resources.IResource
import com.github.jknack.generator.ToolOptions
import com.google.common.base.Function

class RefreshProjectProcessor implements CodeGeneratorListener {

  static val ROOT = #[".", "./", ".\\"]

  override beforeProcess(IFile file, ToolOptions options) {
  }

  override afterProcess(IFile file, ToolOptions options) {
    val project = file.project
    val monitor = new NullProgressMonitor

    project.refreshLocal(IResource.DEPTH_INFINITE, monitor)
    val output = options.output(file)
    val relative = output.relative
    if (project.exists(relative)) {
      val container = if (ROOT.contains(relative.toString))
          project
        else
          project.getFolder(output.relative)

      /**
       * Mark files as derived
       */
      val Function<IResource, String> fileName = [
        it.location.removeFileExtension.lastSegment.toLowerCase
      ]
      val fname = fileName.apply(file)
      container.accept [ generated |
        val gname = fileName.apply(generated)
        // TODO: make me stronger
        if (file.name != generated.name && gname.startsWith(fname)) {
          generated.setDerived(options.derived, monitor)
        }
        return true
      ]
    }
  }

}
