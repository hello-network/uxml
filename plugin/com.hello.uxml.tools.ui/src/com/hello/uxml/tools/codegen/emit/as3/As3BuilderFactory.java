package com.hello.uxml.tools.codegen.emit.as3;

import com.hello.uxml.tools.codegen.emit.BuilderFactory;
import com.hello.uxml.tools.codegen.emit.PackageBuilder;

/**
 * Implements Factory for ActionScript 3.0 source code target.
 *
 * @author ferhat
 */
public class As3BuilderFactory implements BuilderFactory {
  @Override
  public PackageBuilder createPackageBuilder() {
    return new As3PackageBuilder();
  }
}
