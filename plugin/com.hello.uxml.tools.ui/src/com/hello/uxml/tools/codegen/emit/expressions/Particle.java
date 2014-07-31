package com.hello.uxml.tools.codegen.emit.expressions;

import com.hello.uxml.tools.codegen.emit.SourceWriter;

/**
 * Provides a simple particle for reference expressions (ie. expression.particle1.particle2)
 *
 * @author ericarnold@ (Eric Arnold)
 *
 */
public class Particle {
  protected String particleValue = null;

  public Particle(String stringValue) {
    this.particleValue = stringValue;
  }

  /**
   * Returns value of the particle as a string.
   */
  public String getValue() {
    return particleValue;
  }

  /**
   * Converts the particle to code.
   */
  public void toCode(SourceWriter writer) {
    writer.print(particleValue);
  }
}
