package com.hello.uxml.tools.codegen.emit.expressions;

import com.google.common.collect.Lists;
import com.hello.uxml.tools.codegen.emit.SourceWriter;

import java.util.List;

/**
 * Defines a block of code in a switch case (ie. case 1: <switchBlock>).
 *
 * @author ericarnold@ (Eric Arnold)
 */
public class SwitchBlock extends Statement {
  private List<Statement> statements = Lists.newArrayList();

  public SwitchBlock() {
  }

  /**
   * Returns mutable list of statements.
   */
  public List<Statement> getStatements() {
    return statements;
  }

  /**
   * Adds a statement to the SwitchBlock.
   *
   * @param statement A statement to add to the SwitchBlock.
   */
  public void addStatement(Statement statement) {
    statements.add(statement);
  }

  /**
   * Adds a SwitchBlock to this SwitchBlock
   *
   * @param switchBlockToAppend A switch block to append to the current block.
   */
  public void addSwitchBlock(SwitchBlock switchBlockToAppend) {
    List<Statement> statementsToAppend = switchBlockToAppend.statements;
    for (Statement statement : statementsToAppend) {
      this.statements.add(statement);
    }
  }

  @Override
  public void toCode(SourceWriter writer, boolean omitSemicolon) {
    writer.indent();
    for (Statement statement : statements) {
      statement.toCode(writer);
      writer.println("");
    }
    writer.outdent();
  }
}
