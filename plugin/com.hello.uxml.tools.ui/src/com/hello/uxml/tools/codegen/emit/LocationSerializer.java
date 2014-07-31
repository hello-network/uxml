package com.hello.uxml.tools.codegen.emit;

import com.google.common.collect.Maps;
import com.hello.uxml.tools.codegen.CompilerError;
import com.hello.uxml.tools.codegen.ModelCompiler;
import com.hello.uxml.tools.codegen.emit.expressions.CodeBlock;
import com.hello.uxml.tools.codegen.emit.expressions.Expression;
import com.hello.uxml.tools.codegen.emit.expressions.HexIntegerLiteralExpression;

import java.util.Map;

/**
 * Serializes Overlay location.
 *
 * @author ferhat@(Ferhat Buyukkokten)
 */
public class LocationSerializer implements CodeSerializer {

  static Map<String, Integer> valMap = null;

  public LocationSerializer() {
    super();
    if (valMap == null) {
      valMap = Maps.newHashMap();
      valMap.put("default", 0);
      valMap.put("top", 1);
      valMap.put("bottom", 2);
      valMap.put("topedge", 4);
      valMap.put("bottomedge", 8);
      valMap.put("vcenter", 0x10);
      valMap.put("bottomortop", 0x10002);
      valMap.put("toporbottom", 0x10001);
      valMap.put("left", 0x0100);
      valMap.put("right", 0x0200);
      valMap.put("leftedge", 0x0400);
      valMap.put("rightedge", 0x0800);
      valMap.put("center", 0x1000);
      valMap.put("custom", 0x40000);
      valMap.put("toplevel", 0x80000);
    }
  }

  /** Returns true if value can be serialized */
  @Override
  public boolean canSerialize(String value, ModelCompiler compiler) {
    return !value.startsWith("{");
  }

  /**
   * Create expression for string value.
   */
  @Override
  public Expression createExpression(String value, ModelCompiler compiler, CodeBlock codeBlock) {
    value = value.toLowerCase();
    String[] flags = value.split("\\|");
    int maskVal = 0;
    for (int i = 0; i < flags.length; i++) {
      if (!valMap.containsKey(flags[i])) {
        compiler.getErrors().add(new CompilerError(String.format(
            "Invalid overlay location value '%s'", flags[i])));
        return null;
      }
      int m = valMap.get(flags[i]).intValue();
      maskVal |= m;
    }
    return new HexIntegerLiteralExpression(maskVal);
  }
}
