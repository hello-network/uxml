package com.hello.uxml.tools.codegen.emit;

import com.google.common.collect.Sets;

import java.util.Set;

/**
 * Creates unique variable names given a base class name.
 *
 * @author ferhat@(Ferhat Buyukkokten)
 */
public class UniqueNameGenerator {

  /** Variable name map used to create unique var names */
  protected final Set<String> varNames = Sets.newHashSet();

  /**
   * Creates a unique variable name for the given type name.
   */
  public String createVariableName(String baseName) {
    return createVariableName(baseName, false);
  }

  /**
   * Creates a unique variable name for the given type name.
   */
  public String createVariableName(String baseName, boolean startAtZero) {
    baseName = baseName.substring(0, 1).toLowerCase() + baseName.substring(1);
    int i = startAtZero ? 0 : 1;
    do {
      String newName = (startAtZero && i == 0)
          ? baseName
          : baseName + String.valueOf(i);
      if (!varNames.contains(newName)) {
        varNames.add(newName);
        return newName;
      }
      ++i;
    } while (true);
  }

  /**
   * Releases the variable name for reuse.
   */
  public void releaseVariableName(String varName) {
    varNames.remove(varName);
  }
}
