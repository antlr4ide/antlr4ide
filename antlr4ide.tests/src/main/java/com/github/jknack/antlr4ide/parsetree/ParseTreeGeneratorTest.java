package com.github.jknack.antlr4ide.parsetree;

import static org.easymock.EasyMock.createMock;
import static org.easymock.EasyMock.expect;
import static org.easymock.EasyMock.replay;
import static org.easymock.EasyMock.verify;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;

import java.io.BufferedReader;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.PrintStream;
import java.io.PrintWriter;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.abego.treelayout.NodeExtentProvider;
import org.abego.treelayout.TreeForTreeLayout;
import org.abego.treelayout.TreeLayout;
import org.abego.treelayout.TreeLayout.DumpConfiguration;
import org.abego.treelayout.util.DefaultConfiguration;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IWorkspaceRoot;
import org.eclipse.core.runtime.IPath;
import org.eclipse.core.runtime.Path;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.resource.Resource;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.powermock.api.easymock.PowerMock;
import org.powermock.core.classloader.annotations.PrepareForTest;
import org.powermock.modules.junit4.PowerMockRunner;

import com.github.jknack.antlr4ide.generator.ToolOptions;
import com.github.jknack.antlr4ide.generator.ToolOptionsProvider;
import com.github.jknack.antlr4ide.lang.Grammar;
import com.github.jknack.antlr4ide.lang.LangFactory;
import com.github.jknack.antlr4ide.lang.LexerRule;
import com.github.jknack.antlr4ide.lang.ParserRule;
import com.github.jknack.antlr4ide.lang.Rule;
import com.github.jknack.antlr4ide.lang.Terminal;
import com.github.jknack.antlr4ide.services.ModelExtensions;
import com.google.common.collect.Lists;

@RunWith(PowerMockRunner.class)
public class ParseTreeGeneratorTest {

  @Test
  @PrepareForTest({ParseTreeGenerator.class, ProcessBuilder.class, ModelExtensions.class,
    Socket.class, ServerSocket.class, PrintWriter.class, BufferedReader.class,
    InputStreamReader.class })
  public void build() throws Exception {
    String ruleName = "rule";
    String input = "3+4*5";
    String sexpression = "( expression ( sum ( number 3 ) '+' ( expression ( prod ( number 2 ) '*' ( number 4 ) ) ) ) ) ";

    int freePort = 41900;

    ToolOptionsProvider optionsProvider = createMock(ToolOptionsProvider.class);

    String toolPath = "/tmp/antlr4-x-complete.jar";
    String[] vmArgs = {};
    ToolOptions options = createMock(ToolOptions.class);
    expect(options.getAntlrTool()).andReturn(toolPath);
    expect(options.vmArguments()).andReturn(vmArgs);

    IPath location = Path.fromPortableString("/home/edgar/ws space/project/G4.g4");

    IWorkspaceRoot workspaceRoot = createMock(IWorkspaceRoot.class);
    IFile file = createMock(IFile.class);
    expect(file.getLocation()).andReturn(location);

    LexerRule plusRule = createMock(LexerRule.class);
    expect(plusRule.getName()).andReturn("+");
    plusRule.setName("+");

    LexerRule starRule = createMock(LexerRule.class);
    expect(starRule.getName()).andReturn("*");
    starRule.setName("*");

    LangFactory langFactory = createMock(LangFactory.class);
    expect(langFactory.createLexerRule()).andReturn(plusRule);
    expect(langFactory.createLexerRule()).andReturn(starRule);

    URI resourceURI = URI.createURI("platform:/resource/project/G.g4");
    Resource resource = createMock(Resource.class);
    expect(resource.getURI()).andReturn(resourceURI);

    Grammar grammar = createMock(Grammar.class);
    expect(grammar.eResource()).andReturn(resource);

    Rule rule = createMock(Rule.class);
    expect(rule.getName()).andReturn(ruleName);
    expect(rule.eContainer()).andReturn(grammar);

    expect(workspaceRoot.getFile(Path.fromOSString("/project/G.g4"))).andReturn(file);
    expect(optionsProvider.options(file)).andReturn(options);

    List<String> command = Lists.newArrayList("java", "-cp",
        toolPath + File.pathSeparator + ToolOptionsProvider.RUNTIME_JAR, ParseTreeGenerator.MAIN,
        freePort + "");

    Process process = createMock(Process.class);

    ProcessBuilder pb = PowerMock.createMockAndExpectNew(ProcessBuilder.class, command);
    expect(pb.start()).andReturn(process);

    OutputStream out = createMock(OutputStream.class);

    PrintWriter writer = PowerMock.createMockAndExpectNew(PrintWriter.class, out, true);
    writer.println("parsetree");
    writer.println(location.toOSString());
    writer.println("rule");
    writer.println("3+4*5");
    writer.close();

    InputStream in = createMock(InputStream.class);
    InputStreamReader streamReader = PowerMock.createMockAndExpectNew(InputStreamReader.class, in);

    BufferedReader reader = PowerMock.createMockAndExpectNew(BufferedReader.class, streamReader);
    expect(reader.readLine()).andReturn(sexpression);
    expect(reader.readLine()).andReturn(null);
    reader.close();

    ServerSocket serverSocket = PowerMock.createMockAndExpectNew(ServerSocket.class, 0);
    expect(serverSocket.getLocalPort()).andReturn(freePort);
    serverSocket.close();

    Socket socket = PowerMock.createMockAndExpectNew(Socket.class, "localhost", freePort);
    expect(socket.getOutputStream()).andReturn(out);
    expect(socket.getInputStream()).andReturn(in);
    socket.close();

    Rule parserRule = createMock(ParserRule.class);
    Rule lexerRule = createMock(LexerRule.class);
    Terminal three = createMock(Terminal.class);

    PowerMock.mockStatic(ModelExtensions.class);

    Map<String, EObject> ruleMap = new HashMap<String, EObject>();
    ruleMap.put("parserRule", parserRule);
    ruleMap.put("lexerRule", lexerRule);
    expect(ModelExtensions.ruleMap(grammar, true)).andReturn(ruleMap);

    Object[] mocks = {rule, grammar, resource, workspaceRoot, optionsProvider, file,
        options, process, parserRule, lexerRule, three, langFactory,
        plusRule, starRule, serverSocket, socket, out, in, writer, reader, streamReader };

    PowerMock.replay(ProcessBuilder.class, pb, ModelExtensions.class, Socket.class,
        ServerSocket.class, PrintWriter.class, BufferedReader.class, InputStreamReader.class);

    replay(mocks);

    ParseTreeGenerator generator = new ParseTreeGenerator();
    generator.setWorkspaceRoot(workspaceRoot);
    generator.setOptionsProvider(optionsProvider);
    generator.setLangFactory(langFactory);

    TreeForTreeLayout<ParseTreeNode> tree = generator.build(rule, input);
    assertNotNull(tree);
    assertEquals(
        "\"expression\"\n" +
            "  \"sum\"\n" +
            "    \"number\"\n" +
            "      \"3\"\n" +
            "    \"+\"\n" +
            "    \"expression\"\n" +
            "      \"prod\"\n" +
            "        \"number\"\n" +
            "          \"2\"\n" +
            "        \"*\"\n" +
            "        \"number\"\n" +
            "          \"4\"\n",
        dump(tree).replace("\r", ""));

    verify(mocks);
    PowerMock.verify(ProcessBuilder.class, pb, ModelExtensions.class, Socket.class,
        ServerSocket.class, PrintWriter.class, BufferedReader.class, InputStreamReader.class);
  }

  private String dump(final TreeForTreeLayout<ParseTreeNode> tree) {
    DumpConfiguration conf = new DumpConfiguration("  ", false, false);
    OutputStream stream = new ByteArrayOutputStream();
    new TreeLayout<ParseTreeNode>(tree, new NodeExtentProvider<ParseTreeNode>() {
      @Override
      public double getHeight(final ParseTreeNode node) {
        return 0;
      }

      @Override
      public double getWidth(final ParseTreeNode node) {
        return 0;
      }
    }, new DefaultConfiguration<ParseTreeNode>(10, 10)).dumpTree(new PrintStream(stream), conf);
    return stream.toString();
  }

}
