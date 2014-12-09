package com.github.jknack.antlr4ide.runtime;

import static org.junit.Assert.assertEquals;

import java.io.PrintWriter;
import java.util.Collections;

import org.junit.Test;

public class LiveParseTreeRunnerTest {

  @Test
  public void helloTree() {
    assertEquals("( r 'hello' 'Edgar' )",
        new ParseTreeCommand(new PrintWriter(System.out)).run("src/test/resources/Hello.g4", null, "dir",
            Collections.<String> emptyList(),
            "r",
            "hello Edgar"));
  }

  @Test
  public void jsonTree() {
    assertEquals(
        "( jsonText  ( jsonObject '{'  ( member '\"number\"' ':'  ( jsonValue  ( jsonString '\"space\u00B7inside\"' )  )  )  '}' )  )",
        new ParseTreeCommand(new PrintWriter(System.out)).run("src/test/resources/Json.g4", null,
            "dir",
            Collections.<String> emptyList(),
            "jsonText",
            "{\"number\": \"space inside\"}"));
  }
}
