package com.github.jknack.antlr4ide.issues;

import static org.easymock.EasyMock.createMock;
import static org.easymock.EasyMock.expect;
import static org.easymock.EasyMock.replay;
import static org.easymock.EasyMock.verify;

import org.eclipse.emf.ecore.EClass;
import org.eclipse.emf.ecore.EStructuralFeature;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.powermock.api.easymock.PowerMock;
import org.powermock.core.classloader.annotations.PrepareForTest;
import org.powermock.modules.junit4.PowerMockRunner;

import com.github.jknack.antlr4ide.lang.LexerCommand;
import com.github.jknack.antlr4ide.lang.LexerCommandArg;
import com.github.jknack.antlr4ide.lang.LexerCommandExpr;
import com.github.jknack.antlr4ide.lang.LexerRule;
import com.github.jknack.antlr4ide.lang.Mode;
import com.github.jknack.antlr4ide.lang.Rule;
import com.github.jknack.antlr4ide.lang.V3Token;
import com.github.jknack.antlr4ide.lang.V4Token;
import com.github.jknack.antlr4ide.validation.Antlr4Validator;

@RunWith(PowerMockRunner.class)
@PrepareForTest({Antlr4Validator.class })
public class Issue29 {

  @Test
  public void commandWithModeRefOK() throws Exception {
    Rule rule = createMock(Rule.class);

    Mode ref = createMock(Mode.class);
    expect(ref.getId()).andReturn("VAR").times(2);

    LexerCommandExpr args = createMock(LexerCommandExpr.class);
    expect(args.getRef()).andReturn(ref);

    LexerCommand command = createMock(LexerCommand.class);
    expect(command.getArgs()).andReturn(args);
    expect(command.eContainer()).andReturn(rule);

    Antlr4Validator validator = PowerMock.createPartialMock(Antlr4Validator.class, "error");

    Object[] mocks = {rule, command, args, ref, validator };

    replay(mocks);

    validator.commandWithUnrecognizedConstantValue(command);

    verify(mocks);
  }

  @Test
  public void commandWithLexerRuleRefOK() throws Exception {
    Rule rule = createMock(Rule.class);

    LexerRule ref = createMock(LexerRule.class);
    expect(ref.getName()).andReturn("VAR").times(2);

    LexerCommandExpr args = createMock(LexerCommandExpr.class);
    expect(args.getRef()).andReturn(ref);

    LexerCommand command = createMock(LexerCommand.class);
    expect(command.getArgs()).andReturn(args);
    expect(command.eContainer()).andReturn(rule);

    Antlr4Validator validator = PowerMock.createPartialMock(Antlr4Validator.class, "error");

    Object[] mocks = {rule, command, args, ref, validator };

    replay(mocks);

    validator.commandWithUnrecognizedConstantValue(command);

    verify(mocks);
  }

  @Test
  public void warnCommandWithV3Token() throws Exception {
    Rule rule = createMock(Rule.class);
    expect(rule.getName()).andReturn("RULE");

    V3Token ref = createMock(V3Token.class);
    expect(ref.getId()).andReturn("VAR");

    EStructuralFeature feature = createMock(EStructuralFeature.class);

    EClass eClass = createMock(EClass.class);
    expect(eClass.getEStructuralFeature("ref")).andReturn(feature);

    LexerCommandExpr args = createMock(LexerCommandExpr.class);
    expect(args.getRef()).andReturn(ref);
    expect(args.eClass()).andReturn(eClass);

    LexerCommand command = createMock(LexerCommand.class);
    expect(command.getArgs()).andReturn(args);
    expect(command.eContainer()).andReturn(rule);

    Antlr4Validator validator = PowerMock.createPartialMock(Antlr4Validator.class, "warning");

    PowerMock.expectPrivate(validator, "warning",
        "rule 'RULE' contains a lexer command with an unrecognized " +
            "constant value; lexer interpreters may produce incorrect output",
        args, feature);

    Object[] mocks = {rule, command, args, ref, eClass, feature, validator };

    replay(mocks);

    validator.commandWithUnrecognizedConstantValue(command);

    verify(mocks);
  }

  @Test
  public void warnCommandWithV4Token() throws Exception {
    Rule rule = createMock(Rule.class);
    expect(rule.getName()).andReturn("RULE");

    V4Token ref = createMock(V4Token.class);
    expect(ref.getName()).andReturn("VAR");

    EStructuralFeature feature = createMock(EStructuralFeature.class);

    EClass eClass = createMock(EClass.class);
    expect(eClass.getEStructuralFeature("ref")).andReturn(feature);

    LexerCommandExpr args = createMock(LexerCommandExpr.class);
    expect(args.getRef()).andReturn(ref);
    expect(args.eClass()).andReturn(eClass);

    LexerCommand command = createMock(LexerCommand.class);
    expect(command.getArgs()).andReturn(args);
    expect(command.eContainer()).andReturn(rule);

    Antlr4Validator validator = PowerMock.createPartialMock(Antlr4Validator.class, "warning");

    PowerMock.expectPrivate(validator, "warning",
        "rule 'RULE' contains a lexer command with an unrecognized " +
            "constant value; lexer interpreters may produce incorrect output",
        args, feature);

    Object[] mocks = {rule, command, args, ref, eClass, feature, validator };

    replay(mocks);

    validator.commandWithUnrecognizedConstantValue(command);

    verify(mocks);
  }

  @Test
  public void warnCommandWithAnythingElse() throws Exception {
    Rule rule = createMock(Rule.class);
    expect(rule.getName()).andReturn("RULE");

    LexerCommandArg ref = createMock(LexerCommandArg.class);

    EStructuralFeature feature = createMock(EStructuralFeature.class);

    EClass eClass = createMock(EClass.class);
    expect(eClass.getEStructuralFeature("ref")).andReturn(feature);

    LexerCommandExpr args = createMock(LexerCommandExpr.class);
    expect(args.getRef()).andReturn(ref);
    expect(args.eClass()).andReturn(eClass);

    LexerCommand command = createMock(LexerCommand.class);
    expect(command.getArgs()).andReturn(args);
    expect(command.eContainer()).andReturn(rule);

    Antlr4Validator validator = PowerMock.createPartialMock(Antlr4Validator.class, "warning");

    PowerMock.expectPrivate(validator, "warning",
        "rule 'RULE' contains a lexer command with an unrecognized " +
            "constant value; lexer interpreters may produce incorrect output",
        args, feature);

    Object[] mocks = {rule, command, args, ref, eClass, feature, validator };

    replay(mocks);

    validator.commandWithUnrecognizedConstantValue(command);

    verify(mocks);
  }

  @Test
  public void typeCommandWithoutArgumentMustFail() throws Exception {
    commandWithoutArgument("type");
  }

  @Test
  public void channelCommandWithoutArgumentMustFail() throws Exception {
    commandWithoutArgument("channel");
  }

  @Test
  public void modeCommandWithoutArgumentMustFail() throws Exception {
    commandWithoutArgument("mode");
  }

  @Test
  public void pushModeCommandWithoutArgumentMustFail() throws Exception {
    commandWithoutArgument("pushMode");
  }

  @Test
  public void skipCommandWithArgumentMustFail() throws Exception {
    commandWithArgument("skip");
  }

  @Test
  public void moreCommandWithArgumentMustFail() throws Exception {
    commandWithArgument("more");
  }

  @Test
  public void popModeCommandWithArgumentMustFail() throws Exception {
    commandWithArgument("popMode");
  }

  @Test
  public void validCommands() throws Exception {
    String[] commands = {"skip", "more", "popMode", "type", "channel", "mode", "pushMode"};
    for (String comamndName : commands) {
      LexerCommand command = createMock(LexerCommand.class);
      expect(command.getName()).andReturn(comamndName);

      Antlr4Validator validator = PowerMock.createPartialMock(Antlr4Validator.class, "error");

      Object[] mocks = {command, validator };

      replay(mocks);

      validator.unsupported(command);

      verify(mocks);
    }
  }

  private void commandWithoutArgument(final String commandName) throws Exception {
    EStructuralFeature feature = createMock(EStructuralFeature.class);

    EClass eClass = createMock(EClass.class);
    expect(eClass.getEStructuralFeature("name")).andReturn(feature);

    LexerCommand command = createMock(LexerCommand.class);
    expect(command.getName()).andReturn(commandName);
    expect(command.getArgs()).andReturn(null);
    expect(command.eClass()).andReturn(eClass);

    Antlr4Validator validator = PowerMock.createPartialMock(Antlr4Validator.class, "error");

    PowerMock.expectPrivate(validator, "error", "missing argument for lexer command '"
        + commandName + "' ", command, feature);

    Object[] mocks = {command, eClass, feature, validator };

    replay(mocks);

    validator.missingArgument(command);

    verify(mocks);
  }

  private void commandWithArgument(final String commandName) throws Exception {
    EStructuralFeature feature = createMock(EStructuralFeature.class);

    LexerCommandExpr args = createMock(LexerCommandExpr.class);

    EClass eClass = createMock(EClass.class);
    expect(eClass.getEStructuralFeature("name")).andReturn(feature);

    LexerCommand command = createMock(LexerCommand.class);
    expect(command.getName()).andReturn(commandName);
    expect(command.getArgs()).andReturn(args);
    expect(command.eClass()).andReturn(eClass);

    Antlr4Validator validator = PowerMock.createPartialMock(Antlr4Validator.class, "error");

    PowerMock.expectPrivate(validator, "error", "lexer command '" + commandName
        + "' does not take any arguments", command, feature);

    Object[] mocks = {command, eClass, feature, args, validator };

    replay(mocks);

    validator.noArgument(command);

    verify(mocks);
  }
}
