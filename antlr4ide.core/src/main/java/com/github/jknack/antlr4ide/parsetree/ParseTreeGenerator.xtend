package com.github.jknack.antlr4ide.parsetree

import java.io.File
import java.io.InputStream
import java.io.BufferedReader
import java.io.InputStreamReader
import com.github.jknack.antlr4ide.console.Console
import com.google.inject.Singleton
import org.abego.treelayout.util.DefaultTreeForTreeLayout
import com.google.common.collect.Lists
import org.abego.treelayout.TreeForTreeLayout
import com.google.common.base.Splitter
import com.github.jknack.antlr4ide.lang.Grammar
import com.google.inject.Inject
import org.eclipse.core.resources.IWorkspaceRoot
import org.eclipse.core.runtime.Path
import org.eclipse.xtext.xbase.lib.Pair
import com.github.jknack.antlr4ide.lang.LangFactory
import com.github.jknack.antlr4ide.generator.ToolOptionsProvider
import com.google.common.cache.CacheBuilder
import com.google.common.cache.CacheLoader
import com.github.jknack.antlr4ide.lang.Rule
import static extension org.eclipse.xtext.EcoreUtil2.*
import static extension com.github.jknack.antlr4ide.services.ModelExtensions.*
import java.util.List
import com.google.common.base.Function

/**
 * Given a start rule and grammar this class generate a parse tree for matching input.
 *
 * Parse tree generation is done by invoking an external process (JVM). This way a user can specify
 * ANTLR version at runtime.
 */
@Singleton
class ParseTreeGenerator {

  /** The parse tree runner from 'antlr4ide-runtime' project. */
  public static val MAIN = "com.github.jknack.antlr4ide.runtime.LiveParseTreeRunner"

  /** Access to the workspace root and resolve file/resource from there. */
  @Inject
  @Property
  IWorkspaceRoot workspaceRoot

  /** Provide feedback to users. */
  @Inject
  @Property
  Console console

  /** Choose which version of ANTLR is used. */
  @Inject
  @Property
  ToolOptionsProvider optionsProvider

  /** Create fake/virtual node. */
  @Inject
  @Property
  LangFactory langFactory

  /** Cache a max of 20 parse trees. */
  val cache = CacheBuilder.newBuilder.maximumSize(20).build(
    CacheLoader.from [ Pair<String, Pair<Rule, String>> key |
      val data = key.value
      doBuild(data.key, data.value)
    ])

  /**
   * Build a parse tree for the given rule & input.
   *
   * @param rule The rule to execute.
   * @param input The input text to run
   *
   * @return A parse tree
   */
  def TreeForTreeLayout<ParseTreeNode> build(Rule rule, String input) {
    cache.get(key(rule, input))
  }

  /**
   * Build a cache key for the given rule & input.
   */
  private def key(Rule rule, String input) {
    val id = rule.name + "@" + rule.hash + "@" + input.hashCode
    id -> (rule -> input)
  }

  /**
   * Build a parse tree for the given rule & input.
   *
   * @param rule The rule to execute.
   * @param input The input text to run
   *
   * @return A parse tree
   */
  private def TreeForTreeLayout<ParseTreeNode> doBuild(Rule rule, String input) {

    // get root grammar
    val grammar = rule.getContainerOfType(Grammar)

    // file ref
    val path = grammar.eResource.URI.toPlatformString(true)
    val file = workspaceRoot.getFile(new Path(path))

    // tool options
    val options = optionsProvider.options(file)

    // classpath
    val cp = #[options.antlrTool, ToolOptionsProvider.RUNTIME_JAR].join(File.pathSeparator)

    // build and execute command
    val command = #["java", "-cp", cp, MAIN, file.location.toOSString, rule.name, input]

    val rules = grammar.ruleMap(true)

    run(command, file.parent.location.toFile) [ process |
      val sexpression = processOutput(process.inputStream, console)
      processOutput(process.errorStream, console)
      val tokens = Splitter.on(" ").trimResults.omitEmptyStrings.split(sexpression)
      val stack = Lists.<ParseTreeNode>newLinkedList
      var DefaultTreeForTreeLayout<ParseTreeNode> tree = null
      val nodeFactory = [ String text |
        var element = rules.get(text)
        if (element == null && text.startsWith("'")) {

          // create a virtual token instance
          val token = langFactory.createLexerRule
          token.setName(text.substring(1, text.length - 1))
          element = token
        }
        new ParseTreeNode(if(element == null) text else element)
      ]
      var i = 0
      while (i < tokens.size) {
        val token = tokens.get(i)
        switch (token) {
          case "(": {
            i = i + 1
            val node = nodeFactory.apply(tokens.get(i))
            if (tree == null) {
              tree = new DefaultTreeForTreeLayout(node)
            } else {
              tree.addChild(stack.last, node)
            }
            stack += node
          }
          case ")": {
            stack.removeLast
          }
          default: {
            tree.addChild(stack.last, nodeFactory.apply(token))
          }
        }
        i = i + 1
      }
      return tree
    ]
  }

  /**
   * Run the eval command safely.
   */
  private def run(List<String> command, File directory,
    Function<Process, ? extends TreeForTreeLayout<ParseTreeNode>> fn) {
    val process = new ProcessBuilder(command).directory(directory).start
    try {
      return fn.apply(process)
    } finally {
      process.waitFor
      process.destroy
    }
  }

  /**
   * Read output from a runtime process.
   */
  private def processOutput(InputStream stream, Console console) {
    val in = new BufferedReader(new InputStreamReader(stream))
    val buffer = new StringBuilder
    var line = ""
    try {
      while ((line = in.readLine) != null) {
        if (line.startsWith("(")) {
          buffer.append(line)
        } else {
          console.error(line)
        }
      }
    } finally {
      in.close
    }
    return buffer.toString
  }

}
