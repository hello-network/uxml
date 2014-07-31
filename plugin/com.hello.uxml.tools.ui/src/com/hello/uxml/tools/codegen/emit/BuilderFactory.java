package com.hello.uxml.tools.codegen.emit;

/**
 * Interface for factories that produce {@link PackageBuilder}.
 * Each registered target language implements this interface and registers it
 * in {@code BuilderFactoryRegistry}.
 *
 * @author ferhat
 */
public interface BuilderFactory {
  PackageBuilder createPackageBuilder();
}
