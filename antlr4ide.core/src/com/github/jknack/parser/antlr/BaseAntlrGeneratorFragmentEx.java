package com.github.jknack.parser.antlr;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.nio.channels.FileChannel;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;

import org.eclipse.xtext.generator.parser.antlr.ex.common.AbstractAntlrGeneratorFragmentEx;

public abstract class BaseAntlrGeneratorFragmentEx extends AbstractAntlrGeneratorFragmentEx {

  protected void copy(final File source, final File dest) {
    System.out.println("Copying: " + source + " to " + dest);
    FileChannel sourceChannel = null;
    FileChannel destChannel = null;
    try {
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
      br = new BufferedReader(new FileReader(fileName));
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
