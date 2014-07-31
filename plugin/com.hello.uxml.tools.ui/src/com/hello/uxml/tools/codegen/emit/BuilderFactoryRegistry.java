package com.hello.uxml.tools.codegen.emit;

import com.google.common.collect.Maps;

import java.util.Map;

/**
 * Utility methods to register and unregister package builders.
 *
 * @author ferhat
 */
public class BuilderFactoryRegistry {

  /**
   * Maps a language name to a {link PackageBuilder} factory class.
   */
  private final Map<String, BuilderFactory> builders = Maps.newHashMap();

  /**
   * Registers a language package factory.
   * If factory already exists, it is replaced with new one.
   *
   * @param name language name
   * @param factory BuilderFactory instance
   */
  public void registerFactory(String name, BuilderFactory factory) {
    builders.put(name, factory);
  }

  /**
   * Returns a registered builder factory.
   *
   * @param languageName target language
   * @return builder factory or null if not found
   */
  public BuilderFactory getFactory(String languageName) {
    return builders.get(languageName);
  }
}
