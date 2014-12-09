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
import com.github.jknack.antlr4ide.lang.Rule
import static extension org.eclipse.xtext.EcoreUtil2.*
import static extension com.github.jknack.antlr4ide.services.ModelExtensions.*
import java.net.ServerSocket
import java.net.Socket
import java.io.PrintWriter
import com.github.jknack.antlr4ide.generator.Jobs
import java.util.Set
import org.eclipse.xtext.xbase.lib.Functions.Function3
import com.github.jknack.antlr4ide.generator.ToolOptions
import java.util.List
import java.util.Map
import org.eclipse.core.runtime.jobs.Job
import com.google.common.collect.Maps
import com.google.common.cache.CacheBuilder
import java.util.concurrent.TimeUnit
import com.google.common.cache.CacheLoader
import com.github.jknack.antlr4ide.lang.Options
import com.github.jknack.antlr4ide.lang.TokenVocab
import org.eclipse.core.resources.IFile

/**
 * Given a start rule and grammar this class generate a parse tree for matching input.
 *
 * Parse tree generation is done by invoking an external process (JVM). This way a user can specify
 * ANTLR version at runtime.
 */
@Singleton
class ParseTreeGenerator {

  /** The parse tree runner from 'antlr4ide-runtime' project. */
  public static val MAIN = "com.github.jknack.antlr4ide.runtime.Antlr4Server"

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

  /** Process->Job */
  Map<Process, Job> jobs = Maps.newHashMap

  /** Cache JVM and reduce startup time. */
  val processCache = CacheBuilder.newBuilder
    .maximumSize(2)
    .expireAfterAccess(1, TimeUnit.HOURS)
  .removalListener [
    // destroy process
    destroy(it.value)
  ].build(
    CacheLoader.from [ Pair<Pair<String, String>, Set<String>> key |
      val dir = key.key
      val vmArgs = key.value
      val port = freePort.toString
      val command = Lists.newArrayList("java", "-cp")
      command += vmArgs
      command += dir.value
      command += MAIN
      command += port
      val process = newProcess(dir.key, command)
      port -> process
    ]
  )

  /**
   * Build a parse tree for the given rule & input.
   *
   * @param rule The rule to execute.
   * @param input The input text to run
   *
   * @return A parse tree
   */
  def TreeForTreeLayout<ParseTreeNode> build(Rule rule, String input) {
    doBuild(rule, input)
  }

  /**
   * Disconnect the parse tree evaluator and destroy any live process.
   */
  def disconnect() {
    processCache.invalidateAll
  }

  /**
   * Build a cache key for the given options.
   */
  private def processKey(IFile file, ToolOptions options) {

    // classpath
    val cp = #[options.antlrTool, ToolOptionsProvider.RUNTIME_JAR].join(File.pathSeparator)

    (file.project.location.toOSString -> cp) -> options.vmArguments.toSet
  }

  /**
   * Creates a new process.
   */
  private def newProcess(String dir, List<String> command) {
    val process = new ProcessBuilder(command).directory(new File(dir)).start

    val job = Jobs.system("parse tree server") [
      processOutput(process.errorStream, console)
    ]

    jobs.put(process, job)
    job.schedule

    // wait for serverSocket
    Thread.sleep(500)

    return process
  }

  /**
   * Destroy the JVM process.
   */
  private def destroy(Pair<String, Process> entry) {
    val process = entry.value
    jobs.remove(process).cancel
    process.destroy
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
    val options = grammar.prequels.findFirst[it instanceof Options] as Options
    val tokenVocabURI = if (options != null) {
      val tokenVocab = options.options.findFirst[it instanceof TokenVocab] as TokenVocab
      if (tokenVocab != null) {
        workspaceRoot.getFile(new Path(tokenVocab.importURI.eResource.URI.toPlatformString(true)))
      }
    }
    val imports = grammar.imports
      .map[workspaceRoot.getFile(new Path(it.importURI.eResource.URI.toPlatformString(true)))]

    // tool options
    val toolOptions = optionsProvider.options(file)

    val entry = processCache.get(processKey(file, toolOptions))
    val port = Integer.parseInt(entry.key)
    val process = entry.value

    val escape = [ String string |
      return string
          .replace("\r", "___creturn__")
          .replace("\n", "___nline__")
    ]

    connect(process, port) [ socket, out, in |
      out.println("parsetree")
      out.println(file.location.toOSString)
      if (tokenVocabURI != null) {
        out.println(tokenVocabURI.location.toOSString)
      } else {
        out.println("null")
      }
      out.println(toolOptions.outputDirectory)
      // imports
      out.println(imports.size.toString)
      imports.forEach[out.println(it.location.toOSString)]

      out.println(rule.name)
      out.println(escape.apply(input))
      var line = ""
      var sexpression = "( )"
      while ((line = in.readLine) != null) {
        if (line.startsWith("(")) {
          sexpression = line
        } else {
          console.error(line)
        }
      }
      val rules = grammar.ruleMap(true)
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
      return tree as TreeForTreeLayout <ParseTreeNode>
    ]
  }

  private def connect(Process process, int port,
    Function3<Socket, PrintWriter, BufferedReader, TreeForTreeLayout<ParseTreeNode>> fn) {
    var Socket socket = null
    var PrintWriter out = null
    var BufferedReader in = null
    try {
      socket = new Socket("localhost", port)
      out = new PrintWriter(socket.outputStream, true)
      in = new BufferedReader(new InputStreamReader(socket.inputStream))
      return fn.apply(socket, out, in)
    } finally {
      if (in != null) {
        in.close
      }
      if (out != null) {
        out.close
      }
      if (socket != null) {
        socket.close
      }
    }
  }

  /**
   * Read output from a runtime process.
   */
  private def processOutput(InputStream stream, Console console) {
    val in = new BufferedReader(new InputStreamReader(stream))
    var line = ""
    try {
      while ((line = in.readLine) != null) {
        if (line.startsWith("warning")) {
          console.info(line)
        } else {
          console.error(line)
        }
      }
    } finally {
      in.close
    }
  }

  /**
   * Find a free port to connect.
   */
  private def freePort() {
    try {
      val socket = new ServerSocket(0)
      val port = socket.localPort
      socket.close
      return port
    } catch (Exception ex) {
      return 49100
    }
  }
}
