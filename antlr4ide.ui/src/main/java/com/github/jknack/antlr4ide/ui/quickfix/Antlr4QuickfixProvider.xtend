package com.github.jknack.antlr4ide.ui.quickfix

import org.eclipse.xtext.ui.editor.quickfix.Fix
import org.eclipse.xtext.ui.editor.quickfix.IssueResolutionAcceptor
import org.eclipse.xtext.validation.Issue
import com.github.jknack.antlr4ide.validation.Antlr4Validator

import static extension org.eclipse.xtext.EcoreUtil2.*
import com.github.jknack.antlr4ide.antlr4.Rule
import org.eclipse.xtext.diagnostics.Diagnostic
import static extension org.eclipse.xtext.nodemodel.util.NodeModelUtils.*

/**
 * see http://www.eclipse.org/Xtext/documentation.html#quickfixes
 */
@SuppressWarnings("restriction")
class Antlr4QuickfixProvider extends org.eclipse.xtext.ui.editor.quickfix.DefaultQuickfixProvider {

  @Fix(Antlr4Validator::GRAMMAR_NAME_DIFFER)
  def capitalizeName(Issue issue, IssueResolutionAcceptor acceptor) {
    val name = issue.data.get(0)
    val fname = issue.data.get(1)
    val label = "Rename grammar to '" + fname + "'"

    acceptor.accept(issue, label, label, "rename.png") [ source, context |
      val xtextDocument = context.xtextDocument
      xtextDocument.replace(issue.offset, name.length, fname)
    ]
  }

  @Fix(Diagnostic::LINKING_DIAGNOSTIC)
  def void createMissingEntity(Issue issue, IssueResolutionAcceptor acceptor) {
    val name = issue.data.head
    val type = issue.data.get(1)
    if (type != "rule" && type != "token") {
      return
    }

    val label = "Create " + type + " '" + name + "'"
    acceptor.accept(issue, label, label, type + ".png") [ source, context |
      val rule = source.getContainerOfType(Rule)
      val xtextDocument = context.xtextDocument

      val nodes = rule.findNodesForFeature(rule.eClass.getEStructuralFeature("semicolonSymbol"))
      if (nodes.size > 0) {
        xtextDocument.replace(nodes.head.totalOffset, 1, ";\n" + name + ": ;\n")
      }
    ]

  }
}
