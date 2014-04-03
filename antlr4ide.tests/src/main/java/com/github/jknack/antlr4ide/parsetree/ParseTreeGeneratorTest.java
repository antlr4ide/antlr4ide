package com.github.jknack.antlr4ide.parsetree;

import static org.easymock.EasyMock.createMock;
import static org.easymock.EasyMock.expect;
import static org.easymock.EasyMock.replay;
import static org.easymock.EasyMock.verify;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.PrintStream;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;

import org.abego.treelayout.NodeExtentProvider;
import org.abego.treelayout.TreeForTreeLayout;
import org.abego.treelayout.TreeLayout;
import org.abego.treelayout.TreeLayout.DumpConfiguration;
import org.abego.treelayout.util.DefaultConfiguration;
import org.eclipse.core.resources.IContainer;
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

@RunWith(PowerMockRunner.class)
@PrepareForTest({ParseTreeGenerator.class, ProcessBuilder.class, ModelExtensions.class })
public class ParseTreeGeneratorTest {

  @Test
  public void build() throws Exception {
    String ruleName = "rule";
    String input = "3+4*5";

    ToolOptionsProvider optionsProvider = createMock(ToolOptionsProvider.class);

    String toolPath = "/tmp/antlr4-x-complete.jar";
    ToolOptions options = createMock(ToolOptions.class);
    expect(options.getAntlrTool()).andReturn(toolPath);

    IPath location = Path.fromPortableString("/home/edgar/ws/project/G4.g4");

    IContainer folder = createMock(IContainer.class);
    IPath folderLocation = createMock(IPath.class);
    File folderLocationFile = location.toFile();
    expect(folder.getLocation()).andReturn(folderLocation);
    expect(folderLocation.toFile()).andReturn(folderLocationFile);

    IWorkspaceRoot workspaceRoot = createMock(IWorkspaceRoot.class);
    IFile file = createMock(IFile.class);
    expect(file.getLocation()).andReturn(location);
    expect(file.getParent()).andReturn(folder);

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
    expect(rule.getName()).andReturn(ruleName).times(2);
    expect(rule.eContainer()).andReturn(grammar);

    expect(workspaceRoot.getFile(Path.fromOSString("/project/G.g4"))).andReturn(file);
    expect(optionsProvider.options(file)).andReturn(options);

    Object[] command = {"java", "-cp",
        toolPath + File.pathSeparator + ToolOptionsProvider.RUNTIME_JAR, ParseTreeGenerator.MAIN,
        location.toOSString(), ruleName, input };

    Process process = createMock(Process.class);
    expect(process.getInputStream())
        .andReturn(
            stream("( expression ( sum ( number 3 ) '+' ( expression ( prod ( number 2 ) '*' ( number 4 ) ) ) ) ) "));
    expect(process.getErrorStream()).andReturn(stream(""));
    expect(process.waitFor()).andReturn(0);
    process.destroy();

    ProcessBuilder pb = PowerMock.createMockAndExpectNew(ProcessBuilder.class,
        Arrays.asList(command));
    expect(pb.directory(folderLocationFile)).andReturn(pb);
    expect(pb.start()).andReturn(process);

    Rule parserRule = createMock(ParserRule.class);
    Rule lexerRule = createMock(LexerRule.class);
    Terminal three = createMock(Terminal.class);

    PowerMock.mockStatic(ModelExtensions.class);

    Map<String, EObject> ruleMap = new HashMap<String, EObject>();
    ruleMap.put("parserRule", parserRule);
    ruleMap.put("lexerRule", lexerRule);
    expect(ModelExtensions.ruleMap(grammar, true)).andReturn(ruleMap);

    expect(ModelExtensions.hash(rule)).andReturn(678);

    Object[] mocks = {rule, grammar, resource, workspaceRoot, optionsProvider, file,
        options, folder, process, folderLocation, parserRule, lexerRule, three, langFactory,
        plusRule, starRule };

    PowerMock.replay(ProcessBuilder.class, pb, ModelExtensions.class);

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
        dump(tree));

    verify(mocks);
    PowerMock.verify(ProcessBuilder.class, pb, ModelExtensions.class);
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

  private InputStream stream(final String content) {
    return new ByteArrayInputStream(content.getBytes());
  }

}
