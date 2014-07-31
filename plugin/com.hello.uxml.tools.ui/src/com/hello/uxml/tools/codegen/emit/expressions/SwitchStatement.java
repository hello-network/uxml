package com.hello.uxml.tools.codegen.emit.expressions;

import com.hello.uxml.tools.codegen.emit.SourceWriter;

import java.util.ArrayList;

/**
 * Defines a switch statement (ie. switch (variable) { case 1, 2, 4: break }
 *
 * @author ericarnold@ (Eric Arnold)
 */
public class SwitchStatement extends Statement {
  private final Expression expression;
  private ArrayList<SwitchCase> cases = new ArrayList<SwitchCase>();

  /**
   * Constructs a switch statement (ie. switch (variable) { case 1, 2, 4: break }
   *
   * @param expression The expression to evaluate.
   */
  public SwitchStatement(Expression expression) {
    this.expression = expression;
  }

  /**
   * Adds a switch case to this switch statement (ie. switch (variable) { <switchCase> }
   * @param switchCase
   */
  public void addCase(SwitchCase switchCase) {
    this.cases.add(switchCase);
  }

  @Override
  public void toCode(SourceWriter writer, boolean omitSemicolon) {
    writer.print("switch (");
    this.expression.toCode(writer);
    writer.println(") {");
    writer.indent();
    final int casesLength = cases.size();
    for (int caseIndex = 0; caseIndex < casesLength; caseIndex++) {
      SwitchCase switchCase = cases.get(caseIndex);
      switchCase.toCode(writer);
    }
    writer.outdent();
    writer.print("}");
  }
}
