package com.github.jknack.antlr4ide.runtime;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.ServerSocket;
import java.net.Socket;

public class Antlr4Server extends Thread
{
  protected Socket clientSocket;

  public static void main(final String[] args) throws IOException {
    int port = Integer.parseInt(args[0]);
    ServerSocket serverSocket = null;

    try {
      serverSocket = new ServerSocket(port);
      try {
        while (true) {
          new Antlr4Server(serverSocket.accept()).start();
        }
      } catch (IOException ex) {
        System.err.println("Accept failed: " + ex.getMessage());
        System.exit(1);
      }
    } catch (IOException ex) {
      System.err.println("Could not listen on port: " + port + ". Reason: " + ex.getMessage());
      System.exit(1);
    } finally {
      try {
        serverSocket.close();
      } catch (IOException ex) {
        System.err.println("Could not close on port: " + port + ". Reason: " + ex.getMessage());
        System.exit(1);
      }
    }
  }

  private Antlr4Server(final Socket clientSoc) {
    clientSocket = clientSoc;
  }

  @Override
  public void run() {
    try {
      PrintWriter out = new PrintWriter(clientSocket.getOutputStream(), true);
      BufferedReader in = new BufferedReader(new InputStreamReader(clientSocket.getInputStream()));

      String command = in.readLine();
      if ("parsetree".equals(command)) {
        String file = in.readLine();
        String lexerFile = in.readLine();
        String outdir = in.readLine();
        String startRule = in.readLine();
        String input = unescape(in.readLine());
        String sexpression = new ParseTreeCommand(out).run(file, lexerFile.equals("null") ? null
            : lexerFile, outdir, startRule, input);
        out.println(sexpression);
      } else {
        System.err.println("error: unknown command " + command);
      }

      out.close();
      in.close();
      clientSocket.close();
    } catch (IOException ex) {
      System.err.println("Problem with Communication Server: " + ex.getMessage());
      System.exit(1);
    }
  }

  private String unescape(final String string) {
    return string
        .replace("___creturn__", "\r")
        .replace("___nline__", "\n");
  }
}
