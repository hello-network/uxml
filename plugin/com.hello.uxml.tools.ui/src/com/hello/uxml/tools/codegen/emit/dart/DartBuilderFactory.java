package com.hello.uxml.tools.codegen.emit.dart;

import com.hello.uxml.tools.codegen.emit.BuilderFactory;
import com.hello.uxml.tools.codegen.emit.PackageBuilder;

/**
 * Implements Factory for Dash source code target.
 *
 * @author ferhat
 */
public class DartBuilderFactory implements BuilderFactory {
  @Override
  public PackageBuilder createPackageBuilder() {
    return new DartPackageBuilder();
  }
}
