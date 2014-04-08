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

      String line = in.readLine();
      String[] command = line.split(" ");
      if ("parsetree".equals(command[0])) {
        String sexpression = new ParseTreeCommand(out).run(unespace(command[1]), command[2], unespace(command[3]));
        out.println(sexpression);
      } else {
        System.err.println("error: unknown command " + command[0]);
      }

      out.close();
      in.close();
      clientSocket.close();
    } catch (IOException ex) {
      System.err.println("Problem with Communication Server: " + ex.getMessage());
      System.exit(1);
    }
  }

  private String unespace(final String string) {
    return string.replace("\u00B7", " ").replace("\\t", "\t").replace("\\r", "\r")
        .replace("\\n", "\n");
  }
}
