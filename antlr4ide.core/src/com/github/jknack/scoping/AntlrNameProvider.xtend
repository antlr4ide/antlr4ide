package com.github.jknack.scoping

import org.eclipse.xtext.naming.IQualifiedNameProvider
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.util.SimpleAttributeResolver
import com.google.common.base.Function
import org.eclipse.xtext.naming.QualifiedName

class AntlrNameProvider extends IQualifiedNameProvider.AbstractImpl {

  public final static SimpleAttributeResolver<EObject, String> ID_RESOLVER = SimpleAttributeResolver.
    newResolver(String, "id");

  override getFullyQualifiedName(EObject obj) {
    return nameFn().apply(obj)
  }

  def static <E extends EObject> Function<E, QualifiedName> nameFn() {
    return [ candidate |
      var name = SimpleAttributeResolver.NAME_RESOLVER.apply(candidate)
      if (name == null) {
        name = ID_RESOLVER.apply(candidate)
      }
      if (name == null) {
        return null
      }
      return QualifiedName.create(name)
    ]
  }
}
