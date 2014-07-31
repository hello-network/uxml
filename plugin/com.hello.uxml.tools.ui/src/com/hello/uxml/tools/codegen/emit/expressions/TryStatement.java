package com.hello.uxml.tools.codegen.emit.expressions;
import com.hello.uxml.tools.codegen.emit.SourceWriter;

import java.util.ArrayList;

/**
 * Defines an if Statement
 *
 * @author ericarnold@ (Eric Arnold)
 */
public class TryStatement extends Statement {

  private ArrayList<CatchEntry> catches = new ArrayList<CatchEntry>();

  /** The try CodeBlock (ie. try <tryBlock> catch { } finally { } ) **/
  private CodeBlock tryBlock;

  /** The finally CodeBlock (ie. try { } catch { } finally <finallyBlock>) **/
  public CodeBlock finallyBlock;

  /**
   * Constructs a try statement (ie. try { } catch { } finally { })
   *
   * @param tryBlock The try CodeBlock (ie. try <tryBlock> catch { } finally { })
   * @param finallyBlock The finally CodeBlock (ie. try { } catch { } finally <finallyBlock>)
   */
  public TryStatement(CodeBlock tryBlock, CodeBlock finallyBlock) {
    this.tryBlock = tryBlock;
    this.finallyBlock = finallyBlock;
  }

  /**
   * Adds a catch entry to this try statement (ie. try { } <catchEntry>
   * @param catchEntry The catch entry
   */
  public void addCatch(CatchEntry catchEntry) {
    this.catches.add(catchEntry);
  }

  @Override
  public void toCode(SourceWriter writer, boolean omitSemicolon) {
    writer.print("try ");
    tryBlock.toCode(writer);
    for (int catchIndex = 0; catchIndex < catches.size(); catchIndex++) {
      CatchEntry catchEntry = catches.get(catchIndex);
      writer.print(" catch (");
      catchEntry.exceptionReference.toCode(writer);
      writer.print(") ");
      catchEntry.codeBlock.toCode(writer);
    }

    if (finallyBlock != null) {
      writer.print(" finally ");
      finallyBlock.toCode(writer);
    }
  }
}
