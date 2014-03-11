package com.github.jknack.antlr4ide.validation;

import static org.easymock.EasyMock.createMock;
import static org.easymock.EasyMock.expect;
import static org.easymock.EasyMock.replay;
import static org.easymock.EasyMock.verify;
import static org.junit.Assert.assertArrayEquals;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertNull;

import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.xtext.diagnostics.Diagnostic;
import org.eclipse.xtext.diagnostics.DiagnosticMessage;
import org.eclipse.xtext.diagnostics.Severity;
import org.eclipse.xtext.linking.ILinkingDiagnosticMessageProvider.ILinkingDiagnosticContext;
import org.junit.Test;

import com.github.jknack.antlr4ide.lang.Grammar;
import com.github.jknack.antlr4ide.lang.Import;
import com.github.jknack.antlr4ide.lang.LexerCommand;
import com.github.jknack.antlr4ide.lang.LexerCommands;
import com.github.jknack.antlr4ide.lang.LexerRule;
import com.github.jknack.antlr4ide.lang.ParserRule;
import com.github.jknack.antlr4ide.lang.RuleRef;

public class Antlr4MissingReferenceMessageProviderTest {

  @Test
  public void defaultModesOK() {
    ILinkingDiagnosticContext diagnosticContext = createMock(ILinkingDiagnosticContext.class);
    LexerCommand command = createMock(LexerCommand.class);
    LexerCommands commands = createMock(LexerCommands.class);

    expect(diagnosticContext.getLinkText()).andReturn("HIDDEN");
    expect(diagnosticContext.getContext()).andReturn(command);

    expect(command.eContainer()).andReturn(commands);

    Object[] mocks = {diagnosticContext, command, commands };

    replay(mocks);

    DiagnosticMessage message = new Antlr4MissingReferenceMessageProvider()
        .getUnresolvedProxyMessage(diagnosticContext);
    assertNull(message);

    verify(mocks);
  }

  @Test
  public void undefinedMode() {
    ILinkingDiagnosticContext diagnosticContext = createMock(ILinkingDiagnosticContext.class);
    LexerCommand command = createMock(LexerCommand.class);
    LexerCommands commands = createMock(LexerCommands.class);

    expect(diagnosticContext.getLinkText()).andReturn("INSIDE");
    expect(diagnosticContext.getContext()).andReturn(command);

    expect(command.eContainer()).andReturn(commands);

    Object[] mocks = {diagnosticContext, command, commands };

    replay(mocks);

    DiagnosticMessage message = new Antlr4MissingReferenceMessageProvider()
        .getUnresolvedProxyMessage(diagnosticContext);
    assertNull(message);

    verify(mocks);
  }

  @Test
  public void badImport() {
    ILinkingDiagnosticContext diagnosticContext = createMock(ILinkingDiagnosticContext.class);
    Grammar grammar = createMock(Grammar.class);
    Import delegate = createMock(Import.class);
    Resource resource = createMock(Resource.class);
    URI uri = createMock(URI.class);
    String name = "G.g4";

    expect(diagnosticContext.getLinkText()).andReturn("some");
    expect(diagnosticContext.getContext()).andReturn(delegate);

    expect(delegate.eContainer()).andReturn(null).times(2);

    expect(delegate.eContainer()).andReturn(grammar);

    expect(grammar.eContainer()).andReturn(null);
    expect(grammar.eResource()).andReturn(resource);

    expect(resource.getURI()).andReturn(uri);

    expect(uri.lastSegment()).andReturn(name);

    Object[] mocks = {diagnosticContext, delegate, grammar, resource, uri };

    replay(mocks);

    DiagnosticMessage message = new Antlr4MissingReferenceMessageProvider()
        .getUnresolvedProxyMessage(diagnosticContext);
    assertNotNull(message);

    assertEquals(Diagnostic.LINKING_DIAGNOSTIC, message.getIssueCode());
    assertArrayEquals(new String[]{"some", "import" }, message.getIssueData());
    assertEquals("can't find or load grammar 'some' from 'G.g4'", message.getMessage());
    assertEquals(Severity.ERROR, message.getSeverity());

    verify(mocks);
  }

  @Test
  public void undefinedParserRule() {
    ILinkingDiagnosticContext diagnosticContext = createMock(ILinkingDiagnosticContext.class);
    ParserRule rule = createMock(ParserRule.class);
    RuleRef ref = createMock(RuleRef.class);

    expect(diagnosticContext.getLinkText()).andReturn("some");
    expect(diagnosticContext.getContext()).andReturn(ref);

    expect(ref.eContainer()).andReturn(null);
    expect(ref.eContainer()).andReturn(rule);

    Object[] mocks = {diagnosticContext, ref, rule };

    replay(mocks);

    DiagnosticMessage message = new Antlr4MissingReferenceMessageProvider()
        .getUnresolvedProxyMessage(diagnosticContext);
    assertNotNull(message);

    assertEquals(Diagnostic.LINKING_DIAGNOSTIC, message.getIssueCode());
    assertArrayEquals(new String[]{"some", "rule" }, message.getIssueData());
    assertEquals("reference to undefined rule 'some'", message.getMessage());
    assertEquals(Severity.ERROR, message.getSeverity());

    verify(mocks);
  }

  @Test
  public void undefinedLexerRule() {
    ILinkingDiagnosticContext diagnosticContext = createMock(ILinkingDiagnosticContext.class);
    LexerRule rule = createMock(LexerRule.class);
    RuleRef ref = createMock(RuleRef.class);

    expect(diagnosticContext.getLinkText()).andReturn("ID");
    expect(diagnosticContext.getContext()).andReturn(ref);

    expect(ref.eContainer()).andReturn(null);
    expect(ref.eContainer()).andReturn(rule);

    Object[] mocks = {diagnosticContext, ref, rule };

    replay(mocks);

    DiagnosticMessage message = new Antlr4MissingReferenceMessageProvider()
        .getUnresolvedProxyMessage(diagnosticContext);
    assertNotNull(message);

    assertEquals(Diagnostic.LINKING_DIAGNOSTIC, message.getIssueCode());
    assertArrayEquals(new String[]{"ID", "token" }, message.getIssueData());
    assertEquals("reference to undefined rule 'ID'", message.getMessage());
    assertEquals(Severity.ERROR, message.getSeverity());

    verify(mocks);
  }

  @Test
  public void implicitTokenDefinition() {
    ILinkingDiagnosticContext diagnosticContext = createMock(ILinkingDiagnosticContext.class);
    ParserRule rule = createMock(ParserRule.class);
    RuleRef ref = createMock(RuleRef.class);

    expect(diagnosticContext.getLinkText()).andReturn("ID");
    expect(diagnosticContext.getContext()).andReturn(ref);

    expect(ref.eContainer()).andReturn(null);
    expect(ref.eContainer()).andReturn(rule);

    Object[] mocks = {diagnosticContext, ref, rule };

    replay(mocks);

    DiagnosticMessage message = new Antlr4MissingReferenceMessageProvider()
        .getUnresolvedProxyMessage(diagnosticContext);
    assertNotNull(message);

    assertEquals(Diagnostic.LINKING_DIAGNOSTIC, message.getIssueCode());
    assertArrayEquals(new String[]{"ID", "token" }, message.getIssueData());
    assertEquals("implicit token definition 'ID'", message.getMessage());
    assertEquals(Severity.WARNING, message.getSeverity());

    verify(mocks);
  }

}
