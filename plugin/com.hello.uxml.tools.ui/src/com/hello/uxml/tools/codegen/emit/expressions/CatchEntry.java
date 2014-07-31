package com.hello.uxml.tools.codegen.emit.expressions;

/**
 * Defines a catch entry in a try-catch statement (ie ... catch (e:Error) { }).
 *
 * @author ericarnold@ (Eric Arnold)
 */
public class CatchEntry {
  /** The exception reference (ie ... catch (<exceptionReference>) { }). **/
  public Reference exceptionReference;

  /** The CodeBlock to run on catch (ie ... catch (e:Error) <codeBlock>). **/
  public CodeBlock codeBlock;

  /**
   * Constructs a catch entry in a try-catch statement (ie ... catch (e:Error) { }).
   *
   * @param exceptionReference The exception reference (ie ... catch (<exceptionReference>) { }).
   * @param codeBlock The CodeBlock to run on catch (ie ... catch (e:Error) <codeBlock>).
   */
  public CatchEntry(Reference exceptionReference, CodeBlock codeBlock) {
    this.exceptionReference = exceptionReference;
    this.codeBlock = codeBlock;
  }
}
