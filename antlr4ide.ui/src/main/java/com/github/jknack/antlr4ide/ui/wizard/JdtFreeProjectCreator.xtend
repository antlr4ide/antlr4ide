package com.github.jknack.antlr4ide.ui.wizard

import org.eclipse.xtext.ui.XtextProjectHelper
import org.eclipse.core.resources.IProject
import org.eclipse.core.resources.IFile
import java.util.List
import org.eclipse.core.resources.IResource

class JdtFreeProjectCreator extends Antlr4ProjectCreator {

  override protected getAllFolders() {
    return #[]
  }

  override IFile getModelFile(IProject project) {
    val expectedExtension = getPrimaryModelFileExtension();
    val List<IFile> result = newArrayList()
    project.accept [ resource |
      if (IResource.FILE == resource.type && expectedExtension == resource.fileExtension) {
        result.add(resource as IFile)
        return false;
      }
      return IResource.FOLDER == resource.type || IResource.PROJECT == resource.type
    ]
    return result.head
  }

  override protected getModelFolderName() {
    return null
  }

  override protected getExportedPackages() {
    return #[]
  }

  override protected getImportedPackages() {
    return #[]
  }

  override protected getProjectNatures() {
    return #[XtextProjectHelper.NATURE_ID]
  }

  override protected getBuilders() {
    return #[XtextProjectHelper.BUILDER_ID]
  }

}
