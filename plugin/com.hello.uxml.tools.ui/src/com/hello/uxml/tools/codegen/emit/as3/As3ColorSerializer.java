package com.hello.uxml.tools.codegen.emit.as3;

import com.hello.uxml.tools.framework.graphics.Color;
import com.hello.uxml.tools.codegen.CompilerError;
import com.hello.uxml.tools.codegen.ModelCompiler;
import com.hello.uxml.tools.codegen.ModelCompiler.ResourceInfo;
import com.hello.uxml.tools.codegen.dom.Model;
import com.hello.uxml.tools.codegen.emit.CodeModelSerializer;
import com.hello.uxml.tools.codegen.emit.PackageBuilder;
import com.hello.uxml.tools.codegen.emit.TypeToken;
import com.hello.uxml.tools.codegen.emit.expressions.CodeBlock;
import com.hello.uxml.tools.codegen.emit.expressions.DoubleLiteralExpression;
import com.hello.uxml.tools.codegen.emit.expressions.Expression;
import com.hello.uxml.tools.codegen.emit.expressions.HexIntegerLiteralExpression;
import com.hello.uxml.tools.codegen.emit.expressions.Reference;
import com.hello.uxml.tools.codegen.emit.expressions.StaticMethodCall;
import com.hello.uxml.tools.codegen.emit.expressions.VariableDefinitionStatement;

/**
 * Serializes Color.
 *
 * @author ferhat
 */
public class As3ColorSerializer implements CodeModelSerializer {

  /** Returns true if value can be serialized */
  @Override
  public boolean canSerialize(String value, ModelCompiler compiler) {
    if (value.startsWith("{")) {
      ResourceInfo info = compiler.getResourceInfo(value);
      if (info == null) {
        return false;
      }
    }
    return true;
  }

  /**
   * Create value expression for color model item. The color
   * model item can be either a member of an interface or a resource inside markup.
   * If it is a resource:
   *   - If the value is a binding to a static expression, we can resolve the final color
   *     as a const.
   *   - Otherwise we recursively create expression for the binding and then apply mutations.
   */
  @Override
  public Expression createExpression(Model node, ModelCompiler compiler, CodeBlock codeBlock) {
    if (node.getParent() != null && node.getParent().getTypeName().equals("Interface")) {
      // Color is defined inside an interface.
      String colorName = node.getStringProperty("id");
      String interfaceName = compiler.getResourceInfo("{" + colorName + "}").getInterface();
      return compiler.createGetInterfaceResourceExpression(interfaceName,
          TypeToken.fromClass(Color.class), colorName);
    }

    if (!node.hasProperty("value")) {
      compiler.getErrors().add(new CompilerError(node.getLineNumber(), node.getColumn(),
          "Invalid color syntax"));
      return new HexIntegerLiteralExpression(0);
    }

    Expression colorExpr = createExpression(node.getStringProperty("value"), compiler, codeBlock);
    if (colorExpr == null) {
      compiler.getErrors().add(new CompilerError(node.getLineNumber(), node.getColumn(),
        "Invalid color syntax"));
    }
    if (!containsTransformAttribute(node)) {
      return colorExpr;
    }

    // We have transforms on the color. Check if the colorExpr is a constant. We'd like to
    // transform at compile time if possible instead of calling .transform/.mix at runtime.
    if (isConstColorExpression(colorExpr, compiler)) {
      int colorVal = 0;
      if (colorExpr instanceof StaticMethodCall) {
        colorVal = ((HexIntegerLiteralExpression) ((StaticMethodCall) colorExpr).getParameters()[
          0]).intValue();
      } else {
        String bindExpr = "{" + ((Reference) (colorExpr)).getName() + "}";
        Model model = compiler.getResourceModel(bindExpr);
        colorVal = colorStringToInt(compiler, model.getStringProperty("value"));
      }
      colorVal = transformColorValue(compiler, node, colorVal);
      return colorExpressionFromConstColor(compiler, colorVal);
    }
    VariableDefinitionStatement colorDef = null;
    if (containsTransformAttribute(node) || node.hasProperty("mix")) {
      if (!compiler.getPackageBuilder().supportsExplicitCast()) {
        colorDef = codeBlock.defineLocal("color", TypeToken.fromClass(Color.class), colorExpr);
        colorExpr = colorDef.getReference();
      }
    }

    // Not constant so we need to call .transform .mix
    if (containsTransformAttribute(node)) {
      double lighten = 0;
      double saturate = 0;
      double opacity = 1.0;
      try {
        if (node.hasProperty("lighten")) {
          lighten += parsePercent(node.getStringProperty("lighten"));
        }
        if (node.hasProperty("darken")) {
          lighten -= parsePercent(node.getStringProperty("darken"));
        }
        if (node.hasProperty("saturate")) {
          saturate += parsePercent(node.getStringProperty("saturate"));
        }
        if (node.hasProperty("desaturate")) {
          saturate -= parsePercent(node.getStringProperty("desaturate"));
        }
        if (node.hasProperty("opacity")) {
          opacity = parsePercent(node.getStringProperty("opacity"));
        }
      } catch (NumberFormatException e) {
        compiler.getErrors().add(new CompilerError(node.getLineNumber(), node.getColumn(),
          "Invalid color adjustment value"));
        return new HexIntegerLiteralExpression(0);
      }
      if (lighten != 0.0 || saturate != 0.0 || node.hasProperty("opacity")) {
        if (colorExpr == null) {
          return new HexIntegerLiteralExpression(0);
        }
        colorExpr = compiler.getPackageBuilder().createMethodCall(new Reference("Color"),
            "transform",
          new Expression[] {colorExpr,
          new DoubleLiteralExpression(lighten),
          new DoubleLiteralExpression(saturate),
          new DoubleLiteralExpression(opacity)});
      }
    }
    if (node.hasProperty("mix")) {
      if (validateMixAttribute(compiler, node)) {
        Expression colorToMix = colorExpressionFromConstColor(compiler,
            node.getStringProperty("mix"));
        colorExpr = compiler.getPackageBuilder().createMethodCall(colorExpr, "mix",
            new Expression[] {colorToMix});
      }
    }

    if (colorDef != null) {
      codeBlock.releaseLocal(colorDef);
    }
    return colorExpr;
  }

  private boolean isConstColorExpression(Expression expr, ModelCompiler compiler) {
    if (!(expr instanceof StaticMethodCall)) {
      if (!(expr instanceof Reference)) {
        return false;
      }
      String bindingExpr = "{" + ((Reference) (expr)).getName() + "}";
      Model model = compiler.getResourceModel(bindingExpr);
      if (model == null) {
        return false;
      }
      if (model.getTypeName().equals("Color")) {
        if (!model.hasProperty("value")) {
          return false;
        }
        if (model.getStringProperty("value").startsWith("{")) {
          return false;
        }
        if (!containsTransformAttribute(model)) {
          return true;
        }
      }
      return false;
    }
    StaticMethodCall mcall = (StaticMethodCall) expr;
    if (!(mcall.getMethodName().equals("fromRGB") ||
        mcall.getMethodName().equals("fromARGB"))) {
      return false;
    }
    if (!((mcall.getParameters()[0] instanceof HexIntegerLiteralExpression))) {
      return false;
    }
    return true;
  }

  private boolean containsTransformAttribute(Model node) {
    return node.hasProperty("lighten") || node.hasProperty("darken") ||
        node.hasProperty("saturate") || node.hasProperty("desaturate") ||
        node.hasProperty("opacity") || node.hasProperty("mix");
  }

  /**
   * Create expression for string value.
   */
  @Override
  public Expression createExpression(String value, ModelCompiler compiler, CodeBlock codeBlock) {
    PackageBuilder packageBuilder = compiler.getPackageBuilder();
    packageBuilder.addImport(TypeToken.fromClass(Color.class));
    if (value.startsWith("{") && value.endsWith("}")) {
      return compiler.getBindingExpression(value);
    } else {
      return colorExpressionFromConstColor(compiler, value);
    }
  }

  /**
   * Converts #AARRGGBB to Color.fromRGB/fromARGB call.
   * @param compiler Model compiler to use for expression.
   * @param value Color value.
   * @return Expression for creating color.
   */
  public static Expression colorExpressionFromConstColor(ModelCompiler compiler, String value) {
    return colorExpressionFromConstColor(compiler, colorStringToInt(compiler, value));
  }

  private static int colorStringToInt(ModelCompiler compiler, String value) {
    int colorValue = 0;
    int hexPartLength = value.length();
    if (value.startsWith("#")) {
      hexPartLength--;
    }

    if (value.startsWith("0x") || value.startsWith("0X")) {
      hexPartLength -= 2;
    }

    try {
      colorValue = Long.decode(value).intValue();
      if (hexPartLength <= 6) {
        colorValue |= 0xFF000000; // set alpha to max.
      }
    } catch (NumberFormatException e) {
      compiler.getErrors().add(new CompilerError(
          String.format("Invalid color format '%s'", value)));
    }
    return colorValue;
  }

  private static Expression colorExpressionFromConstColor(ModelCompiler compiler, int colorValue) {
    PackageBuilder packageBuilder = compiler.getPackageBuilder();
    TypeToken colorType = TypeToken.fromClass(Color.class);
    packageBuilder.addImport(colorType);
    String methodName;
    if ((colorValue & 0xFF000000) == 0xFF000000) {
      methodName = "fromRGB";
      colorValue &= 0xFFFFFF;
    } else {
      methodName = "fromARGB";
    }
    Expression param = new HexIntegerLiteralExpression(colorValue);
    return packageBuilder.createStaticMethodCall(colorType, methodName,
        new Expression[] {param});
  }

  private boolean validateMixAttribute(ModelCompiler compiler, Model node) {
    String mixValue = node.getStringProperty("mix");
    if (mixValue.length() < 1) {
      compiler.getErrors().add(new CompilerError(
          String.format("Invalid color format '%s'", mixValue)));
      return false;
    } else if (mixValue.startsWith("{")) {
      compiler.getErrors().add(new CompilerError(String.format(
          "Invalid color format '%s'. Only constant color values can be used to mix.",
          mixValue)));
      return false;
    }
    return true;
  }

  /**
   * Transforms a constant color value based on lighten,darken,saturate,desaturate
   * and mix attributes on a node.
   * @param compiler ModelCompiler instance.
   * @param node Color node with attributes.
   * @param boundValue Constant color value to be transformed.
   * @return Transformed color value.
   */
  private int transformColorValue(ModelCompiler compiler, Model node,
      int boundValue) {
    float[] hslvals = new float[3];

    rgbToHsl((boundValue >> 16) & 0xFF, (boundValue >> 8) & 0xFF,
          boundValue & 0xFF, hslvals);
    try {
      if (node.hasProperty("lighten")) {
        float delta = parsePercent(node.getStringProperty("lighten"));
        hslvals[2] *= (1.0f + delta);
        if (hslvals[2] > 1.0f) {
          hslvals[2] = 1.0f;
        }
      }
      if (node.hasProperty("darken")) {
        float delta = parsePercent(node.getStringProperty("darken"));
        hslvals[2] *= (1.0f - delta);
        if (hslvals[2] < 0.0f) {
          hslvals[2] = 0.0f;
        }
      }
      if (node.hasProperty("saturate")) {
        float delta = parsePercent(node.getStringProperty("saturate"));
        hslvals[1] *= (1.0f + delta);
        if (hslvals[1] > 1.0f) {
          hslvals[1] = 1.0f;
        }
      }
      if (node.hasProperty("desaturate")) {
        float delta = parsePercent(node.getStringProperty("desaturate"));
        hslvals[1] *= (1.0f - delta);
        if (hslvals[1] < 0.0f) {
          hslvals[1] = 0.0f;
        }
      }
    } catch (NumberFormatException e) {
      compiler.getErrors().add(new CompilerError(node.getLineNumber(), node.getColumn(),
          "Invalid color adjustment value"));
      return 0;
    }
    int translatedColor = hslToRgb(hslvals[0], hslvals[1], hslvals[2]) & 0x00FFFFFF;
    int opacity = boundValue & 0xFF000000;
    try {
      if (node.hasProperty("opacity")) {
        double val = parsePercent(node.getStringProperty("opacity"));
        opacity = ((int) (val * 255)) << 24;
      }
    } catch (NumberFormatException e) {
      compiler.getErrors().add(new CompilerError(node.getLineNumber(), node.getColumn(),
          "Invalid color opacity adjustment value"));
      return 0;
    }

    if (node.hasProperty("mix")) {
      if (validateMixAttribute(compiler, node)) {
        String mixValue = node.getStringProperty("mix");
        int a = (translatedColor >> 24) & 0xFF;
        int r = (translatedColor >> 16) & 0xFF;
        int g = (translatedColor >> 8) & 0xFF;
        int b = translatedColor & 0xFF;
        try {
          int colorValue = Long.decode(mixValue).intValue();
          int ratio = (colorValue >> 24) & 0xFF;
          int ratio2 = 255 - ratio;
          r = ((r * ratio2) + (((colorValue >> 16) & 0xFF) * ratio)) / 255;
          g = ((g * ratio2) + (((colorValue >> 8) & 0xFF) * ratio)) / 255;
          b = ((b * ratio2) + ((colorValue & 0xFF) * ratio)) / 255;
        } catch (NumberFormatException e) {
          compiler.getErrors().add(new CompilerError(
              String.format("Invalid color format '%s'", mixValue)));
          return 0;
        }
        translatedColor = ((a << 24) & 0xFF000000) | ((r << 16) & 0xFF0000) |
            ((g << 8) & 0xFF00) | (b & 0xFF);
      }
    }

    translatedColor |= (translatedColor & 0xFFFFFF) | opacity;
    return translatedColor;
  }

  /**
   * Parses a float with optional percentage.
   */
  private float parsePercent(String str) {
    str = str.trim();
    if (str.startsWith("%")) {
      return Float.parseFloat(str.substring(1)) / 100.0f;
    } else if (str.endsWith("%")) {
      return Float.parseFloat(str.substring(0, str.length() - 1)) / 100.0f;
    }
    return Float.parseFloat(str);
  }

  private void rgbToHsl(int ri, int gi, int bi, float[] hsl) {
    // Find min and max values from RGB
    float r = ri / 255.0f;
    float g = gi / 255.0f;
    float b = bi / 255.0f;
    float maxVal = Math.max(Math.max(r, g), b);
    float minVal = Math.min(Math.min(r, g), b);
    float chroma = maxVal - minVal;
    float h = 0.0f;
    float s = 0.0f;
    float l = (maxVal + minVal) / 2.0f; // lightness = center of min and max

    // if M == m, we know the color is strictly lightness based (black, white, gray)
    // so s,h stay 0;
    if (!(Math.abs(chroma) < 0.000001f)) {
      // Find S. keep within 0.0 - 1.0 range.
      s = (l < 0.5f) ? (chroma / (maxVal + minVal)) :
          (chroma / (2.0f - maxVal - minVal));
    }

    // Find H. end result is 0.0 - 1.0 range. 1.0 represents one full rotation.
    if (chroma != 0) {
      if (r == maxVal) {
        h = (g - b) / chroma;
      }
      if (g == maxVal) {
        h = 2.0f + ((b - r) / chroma);
      }
      if (b == maxVal) {
        h = 4.0f + ((r - g) / chroma);
      }
    }
    h /= 6.0f;
    hsl[0] = h;
    hsl[1] = s;
    hsl[2] = l;
  }

  private int hslToRgb(float h, float s, float l) {
    float r = 0;
    float g = 0;
    float b = 0;

    // If S=0, define R, G, and B all to L
    if (s == 0.0f) {
      r = l;
      g = l;
      b = l;
    } else {
      float temp1 = 0.0f;
      float temp2 = 0.0f;
      float temp3r = 0.0f;
      float temp3g = 0.0f;
      float temp3b = 0.0f;

      temp2 = (l < 0.5f) ? l * (1.0f + s) : (l + s) - (l * s);
      temp1 = (2.0f * l) - temp2;

      // R temp
      temp3r = h + (1.0f / 3.0f);
      if (temp3r < 0.0) {
        temp3r += 1.0f;
      } else if (temp3r > 1.0f) {
        temp3r -= 1.0f;
      }

      // G temp
      temp3g = h;
      if (temp3g < 0.0) {
        temp3g += 1.0f;
      } else if (temp3g > 1.0f) {
        temp3g -= 1.0f;
      }

      // B temp
      temp3b = h - (1.0f / 3.0f);
      if (temp3b < 0.0) {
        temp3b += 1.0f;
      } else if (temp3b > 1.0f) {
        temp3b -= 1.0f;
      }

      // for each color component: if 6.0*temp3x < 1, color = temp1 + (temp2 - temp1)*6.0*temp3x
      // else if 2.0*temp3 < 1, color=temp2
      // else if 3.0*temp3 < 2, color=temp1+(temp2-temp1)*((2.0/3.0)-temp3)*6.0
      // else color = temp1

      // R
      if ((6.0f * temp3r) < 1.0f) {
        r = (temp1 + (temp2 - temp1) * 6.0f * temp3r);
      } else if ((2.0f * temp3r) < 1.0f) {
        r = temp2;
      } else if ((3.0f * temp3r) < 2.0f) {
        r = temp1 + (temp2 - temp1) * ((2.0f / 3.0f) - temp3r) * 6.0f;
      } else {
        r = temp1;
      }

      // G
      if ((6.0f * temp3g) < 1.0f) {
        g = (temp1 + (temp2 - temp1) * 6.0f * temp3g);
      } else if ((2.0f * temp3g) < 1.0f) {
        g = temp2;
      } else if ((3.0f * temp3g) < 2.0f) {
        g = temp1 + (temp2 - temp1) * ((2.0f / 3.0f) - temp3g) * 6.0f;
      } else {
        g = temp1;
      }

      // B
      if ((6.0f * temp3b) < 1.0f) {
        b = (temp1 + (temp2 - temp1) * 6.0f * temp3b);
      } else if ((2.0f * temp3b) < 1.0f) {
        b = temp2;
      } else if ((3.0f * temp3b) < 2.0f) {
        b = temp1 + (temp2 - temp1) * ((2.0f / 3.0f) - temp3b) * 6.0f;
      } else {
        b = temp1;
      }
    }
    return (((int) (255 * r)) << 16) | (((int) (255 * g)) << 8) | ((int) (255 * b));
  }
}
