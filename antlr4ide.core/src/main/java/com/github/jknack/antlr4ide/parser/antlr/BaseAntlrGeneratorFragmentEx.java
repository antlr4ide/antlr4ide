package com.github.jknack.antlr4ide.parser.antlr;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.nio.channels.FileChannel;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;

import org.apache.log4j.Logger;
import org.eclipse.xtext.generator.parser.antlr.ex.common.AbstractAntlrGeneratorFragmentEx;

public abstract class BaseAntlrGeneratorFragmentEx extends AbstractAntlrGeneratorFragmentEx {

  private Logger log = Logger.getLogger(getClass());

  protected void copy(final File source, final File dest) {
    FileChannel sourceChannel = null;
    FileChannel destChannel = null;
    try {
      log.info("copying: " + source.getCanonicalPath() + " to " + dest);
      sourceChannel = new FileInputStream(source).getChannel();
      destChannel = new FileOutputStream(dest).getChannel();
      destChannel.transferFrom(sourceChannel, 0, sourceChannel.size());
    } catch (IOException ex) {
      throw new IllegalStateException("Can't copy: " + source, ex);
    } finally {
      try {
        sourceChannel.close();
        destChannel.close();
      } catch (IOException ex) {
        throw new IllegalStateException("Can't close: " + source, ex);
      }
    }
  }

  protected void writeFile(final String fileName, final String data) {
    try {
      log.info("using: " + new File(fileName).getCanonicalPath());
      PrintWriter writer = new PrintWriter(new File(fileName));
      writer.write(data);
      writer.close();
    } catch (IOException ex) {
      throw new IllegalStateException("Can't write file: " + fileName, ex);
    }
  }

  protected String readFile(final String fileName) {
    BufferedReader br = null;
    try {
      br = new BufferedReader(new InputStreamReader(getClass().getResourceAsStream(
          "InternalAntlr4Lexer.g")));
      StringBuilder sb = new StringBuilder();
      String line = br.readLine();

      while (line != null) {
        sb.append(line);
        sb.append("\n");
        line = br.readLine();
      }
      br.close();
      return process(sb.toString());
    } catch (IOException ex) {
      throw new IllegalStateException("Can't read file: " + fileName, ex);
    }
  }

  private String process(final String content) {
    String result = content;
    Set<Entry<String, Object>> vars = vars().entrySet();
    for (Entry<String, Object> var : vars) {
      result = result.replace("{{" + var.getKey() + "}}", var.getValue().toString());
    }
    return result;
  }

  protected abstract Map<String, Object> vars();
}
