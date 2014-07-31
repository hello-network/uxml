package com.hello.uxml.tools.codegen.emit.expressions;

import com.hello.uxml.tools.codegen.emit.SourceWriter;

import java.util.ArrayList;

/**
 * Defines a switch case command (ie: case 1, 2, 4: break;)
 *
 * @author ericarnold@ (Eric Arnold)
 *
 */
public class SwitchCase extends Statement {
  public SwitchBlock switchBlock = null;
  public ArrayList<Expression> cases = new ArrayList<Expression>();
  private boolean isDefault;

  /**
   * Whether this is the default case statement.
   *
   * While syntactically, there should not be more than one default case, the parser could accept
   * more than one.  Because of this, this is a boolean rather than a parent's reference.
   *
   * @param isDefault
   */
  public void setDefault(boolean isDefault) {
    this.isDefault = isDefault;
  }

  /**
   * Sets the block for this SwitchCase.
   *
   * @param switchBlock The SwitchBlock (set of statements) to set for this case.
   */
  public void setBlock(SwitchBlock switchBlock) {
    this.switchBlock = switchBlock;
  }

  /**
   * Adds a case to this case statement (ie. case 1, 2, <caseExpression>: break).
   *
   * @param caseExpression An expression to add to this SwitchCase
   */
  public void addCase(Expression caseExpression) {
    this.cases.add(caseExpression);
  }

  @Override
  public void toCode(SourceWriter writer, boolean omitSemicolon) {
    if (isDefault) {
      writer.print("default");
    } else {
      writer.print("case ");
      final int casesLength = cases.size();
      boolean firstCase = true;
      for (int switchCaseIndex = 0; switchCaseIndex < casesLength; switchCaseIndex++) {
        Expression switchCase = cases.get(switchCaseIndex);
        switchCase.toCode(writer);
        if (!firstCase) {
          writer.print(", ");
        }
        firstCase = false;
      }
    }

    writer.println(":");

    switchBlock.toCode(writer);
  }
}
