package com.hello.uxml.tools.codegen.dom;
import com.hello.uxml.tools.codegen.emit.SourceWriter;

/**
 *
 * Writes a model to SourceWriter as HTS XML markup.

 * @author ferhat@
 */
public class ModelWriter {
  private ModelWriter() {
  }

  public static void writeModel(Model node, SourceWriter writer) {
    writeModel(node, writer, 0);
  }

  private static void writeModel(Model node, SourceWriter writer, int depth) {
    writer.print("<");
    writer.print(node.getTypeName());
    boolean hasComplexProperties = false;
    // Write properties
    for (int p = 0; p < node.getPropertyCount(); ++p) {
      ModelProperty prop = node.getProperty(p);
      if ((!(prop instanceof ModelCollectionProperty)) &&
          (prop.getValue() instanceof String)) {
        writer.print(" ");
        writer.print(prop.getName());
        writer.print("=\"");
        writer.print(quickEncode((String) prop.getValue()));
        writer.print("\"");
      } else {
        hasComplexProperties = true;
      }
    }
    if ((node.getChildCount() == 0) && (!hasComplexProperties)) {
      // we're done. close tag
      writer.println("/>");
      return;
    }
    writer.println(">");
    writer.indent();
    // Write complex properties
    for (int p = 0; p < node.getPropertyCount(); ++p) {
      ModelProperty prop = node.getProperty(p);
      if (prop instanceof ModelCollectionProperty) {
        writer.print("<");
        writer.print(prop.getName());
        writer.println(">");
        writer.indent();
        ModelCollectionProperty items = (ModelCollectionProperty) prop;
        for (int c = 0; c < items.getChildCount(); ++c) {
          writeModel(items.getChild(c), writer, depth + 1);
        }
        writer.outdent();
        writer.print("</");
        writer.print(prop.getName());
        writer.println(">");
      } else if (prop.getValue() instanceof Model) {
        writer.print("<");
        writer.print(prop.getName());
        writer.println(">");
        writer.indent();
        writeModel((Model) prop.getValue(), writer);
        writer.outdent();
        writer.print("</");
        writer.print(prop.getName());
        writer.println(">");
      }
    }
    // Write children
    for (int c = 0; c < node.getChildCount(); ++c) {
      writeModel(node.getChild(c), writer, depth + 1);
    }
    writer.outdent();
    writer.print("</");
    writer.print(node.getTypeName());
    writer.println(">");
    if (depth == 1) {
      writer.println("");
      writer.println("");
    }
  }

  private static String quickEncode(String originalString) {
    boolean isProtected = false;

    StringBuffer stringBuffer = new StringBuffer();
    for (int i = 0; i < originalString.length(); i++) {
      char ch = originalString.charAt(i);

      boolean isSpecialChar = ch == '<' || ch == '&' || ch == '>';
      boolean isControlChar = ch < 32;
      boolean unicodeNotAscii = ch > 126;


      if (isSpecialChar || unicodeNotAscii || isControlChar) {
        stringBuffer.append("&#" + (int) ch + ";");
        isProtected = true;
      } else {
        stringBuffer.append(ch);
      }
    }
    return (isProtected == false) ? originalString : stringBuffer.toString();
  }
}
