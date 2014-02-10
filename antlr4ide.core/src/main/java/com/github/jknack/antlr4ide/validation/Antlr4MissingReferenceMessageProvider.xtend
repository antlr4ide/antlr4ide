package com.github.jknack.antlr4ide.validation

import org.eclipse.xtext.linking.impl.LinkingDiagnosticMessageProvider
import org.eclipse.xtext.linking.ILinkingDiagnosticMessageProvider.ILinkingDiagnosticContext
import org.eclipse.xtext.linking.impl.IllegalNodeException
import org.eclipse.xtext.diagnostics.DiagnosticMessage
import static org.eclipse.xtext.diagnostics.Severity.*
import static org.eclipse.xtext.diagnostics.Diagnostic.*
import static extension org.eclipse.xtext.EcoreUtil2.*
import com.github.jknack.antlr4ide.antlr4.Rule
import com.github.jknack.antlr4ide.antlr4.ParserRule
import com.github.jknack.antlr4ide.antlr4.LexerCommands

/**
 * Customize undefined messages of missing references. It provides messages for missing rules,
 * token, imports or tokenVocab linkings.
 */
class Antlr4MissingReferenceMessageProvider extends LinkingDiagnosticMessageProvider {

  /**
   * Default modes in ANTLRv4.
   */
  public static val MODES = newHashSet("DEFAULT_MODE", "MORE", "SKIP", "HIDDEN", "DEFAULT_TOKEN_CHANNEL")

  override getUnresolvedProxyMessage(ILinkingDiagnosticContext diagnosticContext) {
    val linkText = try {
      diagnosticContext.linkText
    } catch (IllegalNodeException ex) {
      ex.node.text
    }

    val context = diagnosticContext.context
    val command = context.getContainerOfType(LexerCommands) != null

    if (command) {
      if (MODES.contains(linkText)) {

        // default modes are OK
        return null
      }
      return new DiagnosticMessage("reference to undefined mode '" + linkText + "'", ERROR,
        LINKING_DIAGNOSTIC, linkText, "mode")
    }

    val rule = context.getContainerOfType(Rule)
    if (rule == null) {

      // it must be an import
      val root = context.rootContainer
      val fname = root.eResource.URI.lastSegment
      return new DiagnosticMessage("can't find or load grammar '" + linkText + "' from '" + fname + "'",
        ERROR, LINKING_DIAGNOSTIC, linkText, "import")
    }

    val token = Character.isUpperCase(linkText.charAt(0))
    var msg = "reference to undefined rule '" + linkText + "'"
    var severity = ERROR
    if (rule instanceof ParserRule) {
      if (token) {
        msg = "implicit token definition '" + linkText + "'"
        severity = WARNING
      }
    }
    return new DiagnosticMessage(msg, severity, LINKING_DIAGNOSTIC, linkText, if(token) "token" else "rule")
  }

}
