package com.hello.uxml.tools.codegen.emit.expressions;

import com.hello.uxml.tools.codegen.emit.SourceWriter;

/**
 * Defines an if Statement.
 *
 * @author ericarnold@ (Eric Arnold)
 */
public class IfStatement extends Statement {

  /** The condition ie. if ( <condition> ) ... **/
  private Condition condition;

  /** The then CodeBlock ie. if (1) { <then code block> } **/
  private Statement thenStatement;

  /** The else statement ie. if (1) { } <else statement> **/
  private Statement elseStatement = null;

  /**
   * Constructs an if statement (ie. if (1) { }) with no else CodeBlock
   *
   * @param condition The conditional ie. if ( <condition> ) { }
   * @param thenStatement The then statement ie. if (1) { <then statement> }
   */
  public IfStatement(Condition condition, Statement thenStatement) {
    this(condition, thenStatement, null);
  }

  /**
   * Constructs an if statement (ie. if (1) { } else { }) with an else CodeBlock
   *
   * @param condition The conditional ie. if ( <condition> ) ...
   * @param thenStatement The then statement ie. if (1) { <then statement> } else { }
   * @param elseStatement  The else statement ie. if (1) { } else <else statement>
   */
  public IfStatement(Condition condition, Statement thenStatement, Statement elseStatement) {
    super();
    this.condition = condition;
    this.thenStatement = thenStatement;
    this.elseStatement = elseStatement;
  }


  @Override
  public void toCode(SourceWriter writer, boolean omitSemicolon) {
    writer.print("if ");
    writer.print("(");
    condition.toCode(writer);
    writer.print(") ");
    thenStatement.toCode(writer);
    if (this.elseStatement != null) {
      writer.print(" else ");
      elseStatement.toCode(writer);
    }
  }
}
