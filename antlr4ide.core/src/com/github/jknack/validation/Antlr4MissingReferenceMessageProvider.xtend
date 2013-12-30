package com.github.jknack.validation

import org.eclipse.xtext.linking.impl.LinkingDiagnosticMessageProvider
import org.eclipse.xtext.linking.ILinkingDiagnosticMessageProvider.ILinkingDiagnosticContext
import org.eclipse.xtext.linking.impl.IllegalNodeException
import org.eclipse.xtext.diagnostics.DiagnosticMessage
import org.eclipse.xtext.diagnostics.Severity
import org.eclipse.xtext.diagnostics.Diagnostic
import org.eclipse.xtext.EcoreUtil2
import com.github.jknack.antlr4.Rule
import com.github.jknack.antlr4.ParserRule
import com.github.jknack.antlr4.LexerCommands

class Antlr4MissingReferenceMessageProvider extends LinkingDiagnosticMessageProvider {

  val modes = newHashSet("DEFAULT_MODE", "MORE", "SKIP", "HIDDEN", "DEFAULT_TOKEN_CHANNEL")

  override getUnresolvedProxyMessage(ILinkingDiagnosticContext context) {
    var linkText = ""
    try {
      linkText = context.getLinkText
    } catch (IllegalNodeException ex) {
      linkText = ex.getNode().getText
    }
    val command = EcoreUtil2.getContainerOfType(context.context, LexerCommands) != null
    if (command) {
      if (modes.contains(linkText)) {

        // default modes are OK
        return null
      }
      return new DiagnosticMessage("reference to undefined mode '" + linkText + "'", Severity.ERROR,
        Diagnostic.LINKING_DIAGNOSTIC, linkText, "mode")
    }

    val rule = EcoreUtil2.getContainerOfType(context.context, Rule)
    if (rule == null) {

      // it must be an import
      val fname = EcoreUtil2.getRootContainer(context.context).eResource.URI.lastSegment
      return new DiagnosticMessage("can't find or load grammar '" + linkText + "' from '" + fname + "'",
        Severity.ERROR, Diagnostic.LINKING_DIAGNOSTIC, linkText, "import")
    }

    val token = Character.isUpperCase(linkText.charAt(0))
    var msg = "reference to undefined rule '" + linkText + "'"
    var severity = Severity.ERROR
    if (rule instanceof ParserRule) {
      if (token) {
        msg = "implicit token definition '" + linkText + "'"
        severity = Severity.WARNING
      }
    }
    return new DiagnosticMessage(msg, severity, Diagnostic.LINKING_DIAGNOSTIC, linkText,
      if(token) "token" else "rule")
  }

}
