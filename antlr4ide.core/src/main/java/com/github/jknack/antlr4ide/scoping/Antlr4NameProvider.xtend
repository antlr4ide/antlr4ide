package com.github.jknack.antlr4ide.scoping

import org.eclipse.xtext.naming.IQualifiedNameProvider
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.util.SimpleAttributeResolver
import com.google.common.base.Function
import org.eclipse.xtext.naming.QualifiedName

/**
 * Provide names for ANTLR grammar elements. A custom name provider is required due to some
 * limitations on the EMF generator, where you can't use a 'name' attribute with inheritance.
 *
 * For those cases we were forced to use a different name attribute: 'id'.
 */
class Antlr4NameProvider extends IQualifiedNameProvider.AbstractImpl {

  /** The 'id' attribute resolver. */
  private final static val ID_RESOLVER = SimpleAttributeResolver.newResolver(String, "id")

  /**
   * Produces the name function. It looks for a 'name' attribute and fallbacks to 'id' when missing.
   */
  public static val Function<EObject, QualifiedName> nameFn = [ candidate |
      var name = SimpleAttributeResolver.NAME_RESOLVER.apply(candidate)
      if (name == null) {
        name = ID_RESOLVER.apply(candidate)
      }
      if (name == null) {
        return null
      }
      return QualifiedName.create(name)
    ]
  /**
   * @return The name of an EObject reference by extracting the value of the 'name' attribute, if
   * 'name' is missing we fallback to 'id'. If both are missing <code>null</code> is returned.
   */
  override getFullyQualifiedName(EObject obj) {
    return if (obj == null) null else nameFn.apply(obj)
  }

}
