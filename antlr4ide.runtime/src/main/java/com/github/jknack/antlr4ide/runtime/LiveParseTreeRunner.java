package com.github.jknack.antlr4ide.runtime;

import java.util.Arrays;
import java.util.List;

import org.antlr.v4.Tool;
import org.antlr.v4.parse.ANTLRParser;
import org.antlr.v4.runtime.ANTLRInputStream;
import org.antlr.v4.runtime.BaseErrorListener;
import org.antlr.v4.runtime.CommonTokenStream;
import org.antlr.v4.runtime.LexerInterpreter;
import org.antlr.v4.runtime.Parser;
import org.antlr.v4.runtime.ParserInterpreter;
import org.antlr.v4.runtime.RecognitionException;
import org.antlr.v4.runtime.Recognizer;
import org.antlr.v4.runtime.Token;
import org.antlr.v4.runtime.misc.NotNull;
import org.antlr.v4.runtime.misc.Nullable;
import org.antlr.v4.runtime.misc.Utils;
import org.antlr.v4.runtime.tree.ErrorNode;
import org.antlr.v4.runtime.tree.ParseTree;
import org.antlr.v4.runtime.tree.RuleNode;
import org.antlr.v4.runtime.tree.TerminalNode;
import org.antlr.v4.runtime.tree.Tree;
import org.antlr.v4.tool.ANTLRMessage;
import org.antlr.v4.tool.DefaultToolListener;
import org.antlr.v4.tool.Grammar;
import org.antlr.v4.tool.LexerGrammar;
import org.antlr.v4.tool.Rule;
import org.antlr.v4.tool.ast.GrammarRootAST;
import org.stringtemplate.v4.ST;

public class LiveParseTreeRunner {

  public static void main(final String[] args) {
    String grammarFileName = args[0];
    String startRule = args[1];
    String inputText = args[2];

    System.out.println(tree(grammarFileName, startRule, inputText));
  }

  public static String tree(final String grammarFileName, final String startRule,
      final String inputText) {
    Tool antlr = new Tool();
    final StringBuilder error = new StringBuilder();
    antlr.addListener(new DefaultToolListener(antlr) {
      @Override
      public void error(final ANTLRMessage msg) {
        ST msgST = tool.errMgr.getMessageTemplate(msg);
        String message = msgST.render().replace('\n', ' ');
        error.append(message);
      }
    });
    String combinedGrammarFileName = null;
    String lexerGrammarFileName = null;
    String parserGrammarFileName = null;

    // load to examine it
    Grammar g = antlr.loadGrammar(grammarFileName);

    // examine's Grammar AST from v4 itself;
    // hence use ANTLRParser.X not ANTLRv4Parser from this plugin
    switch (g.getType()) {
      case ANTLRParser.PARSER:
        parserGrammarFileName = grammarFileName;
        int i = grammarFileName.indexOf("Parser");
        lexerGrammarFileName = grammarFileName.substring(0, i) + "Lexer.g4";
        break;
      case ANTLRParser.LEXER:
        lexerGrammarFileName = grammarFileName;
        int i2 = grammarFileName.indexOf("Lexer");
        parserGrammarFileName = grammarFileName.substring(0, i2) + "Parser.g4";
        break;
      case ANTLRParser.COMBINED:
        combinedGrammarFileName = grammarFileName;
        break;
    }

    ANTLRInputStream input = new ANTLRInputStream(inputText);
    LexerInterpreter lexEngine;
    if (combinedGrammarFileName != null) {
      lexEngine = g.createLexerInterpreter(input);
    }
    else {
      LexerGrammar lg = null;
      try {
        lg = (LexerGrammar) Grammar.load(lexerGrammarFileName);
      } catch (ClassCastException cce) {
        System.err.println("File " + lexerGrammarFileName + " isn't a lexer grammar");
      }
      g = loadGrammar(antlr, parserGrammarFileName, lg);
      lexEngine = lg.createLexerInterpreter(input);
    }

    CommonTokenStream tokens = new CommonTokenStream(lexEngine);
    ParserInterpreter parser = g.createParserInterpreter(tokens);
    parser.removeErrorListeners();
    parser.addErrorListener(new BaseErrorListener() {
      @Override
      public void syntaxError(final Recognizer<?, ?> recognizer, final Object offendingSymbol,
          final int line,
          final int charPositionInLine, final String msg, final RecognitionException e) {
        if (error.length() == 0) {
          error.append(msg);
        }
      }
    });
    Rule start = g.getRule(startRule);
    ParseTree tree = parser.parse(start.index);

    // this loop works around a bug in ANTLR 4.2
    // https://github.com/antlr/antlr4/issues/461
    // https://github.com/antlr/intellij-plugin-v4/issues/23
    while (tree.getParent() != null) {
      tree = tree.getParent();
    }
    String sexpression = toStringTree(tree, Arrays.asList(parser.getRuleNames())).trim();
    if (error.length() > 0) {
      sexpression = sexpression.substring(0, sexpression.length() - 1) + " <"
          + Utils.escapeWhitespace(error.toString(), true) + "> )";
    }
    return sexpression;
  }

  /** Same as loadGrammar(fileName) except import vocab from existing lexer */
  public static Grammar loadGrammar(final Tool tool, final String fileName,
      final LexerGrammar lexerGrammar) {
    GrammarRootAST grammarRootAST = tool.parseGrammar(fileName);
    final Grammar g = tool.createGrammar(grammarRootAST);
    g.fileName = fileName;
    g.importVocab(lexerGrammar);
    tool.process(g, false);
    return g;
  }

  public static String toStringTree(@NotNull final Tree t, @Nullable final List<String> ruleNames) {
    if (t.getChildCount() == 0) {
      return Utils.escapeWhitespace(getNodeText(t, ruleNames), true);
    }
    StringBuilder buf = new StringBuilder();
    buf.append(" ( ");
    String s = Utils.escapeWhitespace(getNodeText(t, ruleNames), true);
    buf.append(s);
    buf.append(' ');
    for (int i = 0; i < t.getChildCount(); i++) {
      if (i > 0) {
        buf.append(' ');
      }
      buf.append(toStringTree(t.getChild(i), ruleNames));
    }
    buf.append(" ) ");
    return buf.toString();
  }

  public static String getNodeText(@NotNull final Tree t, @Nullable final Parser recog) {
    String[] ruleNames = recog != null ? recog.getRuleNames() : null;
    List<String> ruleNamesList = ruleNames != null ? Arrays.asList(ruleNames) : null;
    return getNodeText(t, ruleNamesList);
  }

  public static String getNodeText(@NotNull final Tree t, @Nullable final List<String> ruleNames) {
    if (ruleNames != null) {
      if (t instanceof RuleNode) {
        int ruleIndex = ((RuleNode) t).getRuleContext().getRuleIndex();
        String ruleName = ruleNames.get(ruleIndex);
        return ruleName;
      }
      else if (t instanceof ErrorNode) {
        return "<" + t.toString() + ">";
      }
      else if (t instanceof TerminalNode) {
        Token symbol = ((TerminalNode) t).getSymbol();
        if (symbol != null) {
          String s = symbol.getText();
          return "'" + s + "'";
        }
      }
    }
    // no recog for rule names
    Object payload = t.getPayload();
    if (payload instanceof Token) {
      return ((Token) payload).getText();
    }
    return t.getPayload().toString();
  }
}
