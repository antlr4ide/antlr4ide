package com.github.jknack.antlr4ide.scoping;

import static org.easymock.EasyMock.createMock;
import static org.easymock.EasyMock.expect;
import static org.easymock.EasyMock.isA;
import static org.easymock.EasyMock.replay;
import static org.easymock.EasyMock.verify;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertNull;

import org.eclipse.emf.common.notify.Adapter;
import org.eclipse.emf.common.util.EList;
import org.eclipse.emf.ecore.EAttribute;
import org.eclipse.emf.ecore.EClass;
import org.eclipse.emf.ecore.EClassifier;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.xtext.naming.QualifiedName;
import org.junit.Test;

public class Antlr4NameProviderTest {

  @SuppressWarnings({"rawtypes", "unchecked" })
  @Test
  public void nameFeature() {
    EObject object = createMock(EObject.class);
    EClass eClass = createMock(EClass.class);
    EAttribute nameFeature = createMock(EAttribute.class);
    EClassifier eType = createMock(EClassifier.class);
    Class instanceClass = String.class;
    EList<Adapter> adapters = createMock(EList.class);
    String name = "rule";

    expect(object.eClass()).andReturn(eClass);
    expect(object.eAdapters()).andReturn(adapters);

    expect(eClass.getEStructuralFeature("name")).andReturn(nameFeature);

    expect(nameFeature.isMany()).andReturn(false);
    expect(nameFeature.getEType()).andReturn(eType);
    expect(object.eGet(nameFeature)).andReturn(name);

    expect(eType.getInstanceClass()).andReturn(instanceClass);

    expect(adapters.add(isA(Adapter.class))).andReturn(true);

    Object[] mocks = {object, eClass, nameFeature, eType, adapters };

    replay(mocks);

    QualifiedName qualifiedName = new Antlr4NameProvider().getFullyQualifiedName(object);
    assertNotNull(qualifiedName);
    assertEquals(name, qualifiedName.getFirstSegment());
    assertEquals(name, qualifiedName.getLastSegment());
    assertEquals(name, qualifiedName.toString());

    verify(mocks);
  }

  @SuppressWarnings({"rawtypes", "unchecked" })
  @Test
  public void idFeatureWhenNameIsMissing() {
    EObject object = createMock(EObject.class);
    EClass eClass = createMock(EClass.class);
    EAttribute idFeature = createMock(EAttribute.class);
    EClassifier eType = createMock(EClassifier.class);
    Class instanceClass = String.class;
    EList<Adapter> adapters = createMock(EList.class);
    String name = "rule";

    expect(object.eClass()).andReturn(eClass).times(2);
    expect(object.eAdapters()).andReturn(adapters);

    expect(eClass.getEStructuralFeature("name")).andReturn(null);
    expect(eClass.getEStructuralFeature("id")).andReturn(idFeature);

    expect(idFeature.isMany()).andReturn(false);
    expect(idFeature.getEType()).andReturn(eType);
    expect(object.eGet(idFeature)).andReturn(name);

    expect(eType.getInstanceClass()).andReturn(instanceClass);

    expect(adapters.add(isA(Adapter.class))).andReturn(true);

    Object[] mocks = {object, eClass, idFeature, eType, adapters };

    replay(mocks);

    QualifiedName qualifiedName = new Antlr4NameProvider().getFullyQualifiedName(object);
    assertNotNull(qualifiedName);
    assertEquals(name, qualifiedName.getFirstSegment());
    assertEquals(name, qualifiedName.getLastSegment());
    assertEquals(name, qualifiedName.toString());

    verify(mocks);
  }

  @Test
  public void missingNameOrId() {
    EObject object = createMock(EObject.class);
    EClass eClass = createMock(EClass.class);

    expect(object.eClass()).andReturn(eClass).times(2);

    expect(eClass.getEStructuralFeature("name")).andReturn(null);
    expect(eClass.getEStructuralFeature("id")).andReturn(null);

    Object[] mocks = {object, eClass };

    replay(mocks);

    QualifiedName qualifiedName = new Antlr4NameProvider().getFullyQualifiedName(object);
    assertNull(qualifiedName);

    verify(mocks);
  }

  @Test
  public void nullReference() {
    QualifiedName qualifiedName = new Antlr4NameProvider().getFullyQualifiedName(null);
    assertNull(qualifiedName);
  }
}
