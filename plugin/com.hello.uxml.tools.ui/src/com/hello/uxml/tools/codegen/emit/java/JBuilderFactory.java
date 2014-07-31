package com.hello.uxml.tools.codegen.emit.java;

import com.hello.uxml.tools.codegen.emit.BuilderFactory;
import com.hello.uxml.tools.codegen.emit.PackageBuilder;

/**
 * Implements Factory for Java source code target.
 *
 * @author ferhat
 */
public class JBuilderFactory implements BuilderFactory {
  @Override
  public PackageBuilder createPackageBuilder() {
    return new JPackageBuilder();
  }
}
