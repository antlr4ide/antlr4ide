package com.github.jknack.antlr4ide.runtime;

import static org.junit.Assert.assertEquals;

import java.io.PrintWriter;

import org.junit.Test;

public class LiveParseTreeRunnerTest {

  @Test
  public void helloTree() {
    assertEquals("( r 'hello' 'Edgar' )",
        new ParseTreeCommand(new PrintWriter(System.out)).run("src/test/resources/Hello.g4", "r",
            "hello Edgar"));
  }

  @Test
  public void jsonTree() {
    assertEquals(
        "( jsonText  ( jsonObject '{'  ( member '\"number\"' ':'  ( jsonValue  ( jsonString '\"space\u00B7inside\"' )  )  )  '}' )  )",
        new ParseTreeCommand(new PrintWriter(System.out)).run("src/test/resources/Json.g4",
            "jsonText",
            "{\"number\": \"space inside\"}"));
  }
}
