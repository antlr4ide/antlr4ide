package com.github.jknack.ui.generator

import com.github.jknack.generator.CodeGeneratorListener
import org.eclipse.core.resources.IFile
import org.eclipse.core.runtime.NullProgressMonitor
import org.eclipse.core.resources.IResource
import com.github.jknack.generator.ToolOptions

class RefreshProjectProcessor implements CodeGeneratorListener {

  override beforeProcess(IFile file, ToolOptions options) {
  }

  override afterProcess(IFile file, ToolOptions options) {
    val project = file.project
    val monitor = new NullProgressMonitor
    
    project.refreshLocal(IResource.DEPTH_INFINITE, monitor)
    val output = options.output(file)
    if (project.exists(output.relative)) {
      val folder = project.getFolder(output.relative)

      /**
       * Mark files as derived
       */
      folder.accept [ generated |
        generated.setDerived(options.derived, monitor)
        return true
      ]
    }
  }

}