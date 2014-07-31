package com.hello.uxml.tools.codegen;

import com.google.common.collect.Sets;
import com.hello.uxml.tools.framework.ValueTransform;

import java.util.Set;

/**
 * Parses a binding expression of the form.
 *
 * <p>Syntax of binding expression is  {propertyPath, param1, param2...}.
 * Parameters supported: twoway and transform:classPath.
 *
 * @author ferhat@(Ferhat Buyukkokten)
 */
public class BindingParser {

  private static final String BIND_SETTING_TWOWAY = "twoway";
  private static final String BIND_SETTING_TRANSFORM = "transform";
  private static final String BIND_SETTING_REVERSE_TRANSFORM = "revtransform";
  private static final String RESOURCE_PREFIX = "resource.";
  private static final String CHROME_TARGET_PREFIX = "target.";

  /** Controller binding prefix. */
  private static final String DATA_PREFIX = "data.";
  private static final String CONTROLLER_PREFIX = "controller.";
  public static final String CONTROLLER_KEYWORD = "controller";

  private ErrorCode parseResult =  ErrorCode.SUCCESS;
  private boolean explicitResource;
  private boolean explicitTarget;
  private boolean isControllerBinding;
  private boolean isDataBinding;
  private boolean twoWayBinding;
  private String expression;
  private String transformClass;
  private String transformFunction;
  private String transformArg;
  private String revTransformClass;
  private String revTransformFunction;

  /** Value transform for negating a boolean value. */
  public static ValueTransform negateBoolean;

  // Initialize value transformers.
  {
    negateBoolean = new ValueTransform() {
      @Override
      public Object transformValue(Object value, Object transArg) {
        if (value instanceof Boolean) {
          return !((Boolean) value).booleanValue();
        }
        return null;
      }
    };
  }

  /**
   * Constructor.
   *
   * @param binding expression to parse.
   */
  public BindingParser(String binding) {
    parse(binding, true);
  }

  /**
   * Constructor.
   *
   * @param binding expression to parse.
   */
  public BindingParser(String binding, boolean hasBrackets) {
    parse(binding, hasBrackets);
  }

  /**
   * Returns parse result.
   */
  public ErrorCode getResult() {
    return parseResult;
  }

  /**
   * Returns expression part of binding.
   */
  public String getExpression() {
    if (isData()) {
      return expression.substring(DATA_PREFIX.length());
    } else if (isController()) {
      return expression.substring(CONTROLLER_PREFIX.length());
    } else if (isResource()) {
      return expression.substring(RESOURCE_PREFIX.length());
    } else if (isChromeTarget()) {
      return expression.substring(CHROME_TARGET_PREFIX.length());
    }
    return expression;
  }

  /**
   * Returns true if binding is two way.
   */
  public boolean isTwoWay() {
    return twoWayBinding;
  }

  /**
   * Returns true if binding explicitly refers to a resource.
   */
  public boolean isResource() {
    return explicitResource;
  }

  /**
   * Returns true if binding explicitly refers to a resource.
   */
  public boolean isData() {
    return isDataBinding;
  }

  /**
   * Returns true if binding explicitly refers to chrome target.
   */
  public boolean isChromeTarget() {
    return explicitTarget;
  }

  /**
   * Returns true if binding to controller.
   */
  public boolean isController() {
    return isControllerBinding;
  }

  private void parse(String binding, boolean hasBrackets) {
    // Parse binding expression {property path, param1, param2, param3}
    if (hasBrackets) {
      if ((binding.length() < 2) || (binding.charAt(0) != '{') ||
          (binding.charAt(binding.length() - 1) != '}')) {
        parseResult = ErrorCode.INVALID_BINDING_SYNTAX;
        return;
      }
      binding = binding.substring(1, binding.length() - 1);
      // Trim whitespace unless it was escaped.
      int startPos = 0;
      while (startPos < binding.length()) {
        char ch = binding.charAt(startPos);
        if (!Character.isWhitespace(ch)) {
          break;
        }
        ++startPos;
      }
      if (startPos != 0) {
        binding = binding.substring(startPos);
      }
      if (binding.charAt(binding.length() - 2) != '\\') {
        binding = binding.trim();
      }
    }
    if (binding.indexOf(":twoway") != -1) {
      parseResult = ErrorCode.DEPRECATION_ERROR_COLON_IN_BINDING;
      return;
    }

    boolean hasNegateSign = false;
    if (binding.length() > 0 && binding.charAt(0) == '!') {
      hasNegateSign = true;
      binding = binding.substring(1);
    }

    // Split on ',' unless it is escaped by '\'
    String[] bindParts = binding.split("(?<!\\\\),");
    if ((bindParts.length < 1)) {
      parseResult = ErrorCode.INVALID_BINDING_SYNTAX;
      return;
    }
    int bindIndex = 0;
    expression = bindParts[bindIndex++];

    Set<String> parsedOptions = Sets.newHashSet();
    for (int i = 1; i < bindParts.length; i++) {
      // Split on ':' unless it is escaped by '\'
      String[] optionParts = bindParts[i].split("(?<!\\\\):");
      if (parsedOptions.contains(optionParts[0])) {
        parseResult = ErrorCode.DUPLICATE_BINDING_PARAMETER;
      }
      if (optionParts[0].equals(BIND_SETTING_TWOWAY)) {
         twoWayBinding = true;
      } else if (optionParts[0].equals(BIND_SETTING_TRANSFORM)) {
        if ((optionParts.length < 2) || hasNegateSign) {
          parseResult = ErrorCode.INVALID_BINDING_SYNTAX;
          return;
        }
        String transform = optionParts[1];
        // Split on '.' unless it is escaped by '\'
        String[] parts = transform.split("(?<!\\\\)\\.");
        if (parts.length != 0) {
           if (parts.length == 1) {
             // No class for transform example: {selected,,negateBoolean}
             // Default to PropertyBinding transforms.
             transformClass = "com.hello.uxml.tools.framework.PropertyBinding";
             transformFunction = parts[0];
           } else {
             int periodPos = transform.lastIndexOf(".");
             transformClass = transform.substring(0, periodPos);
             transformFunction = transform.substring(periodPos + 1);
           }
           if ((transformClass.length() == 0) || (transformFunction.length() == 0)) {
             parseResult = ErrorCode.INVALID_BINDING_SYNTAX;
             return;
           }
        }
        // Check if transform args are specified
        if (optionParts.length == 3) {
          transformArg = optionParts[2];
          // Handle escaped special characters: ':' '.', ' ' and ','
          transformArg = transformArg.replace("\\:", ":");
          transformArg = transformArg.replace("\\.", ".");
          transformArg = transformArg.replace("\\,", ",");
          transformArg = transformArg.replace("\\ ", " ");
        }
      } else if (optionParts[0].equals(BIND_SETTING_REVERSE_TRANSFORM)) {
        if ((optionParts.length != 2) || hasNegateSign) {
          parseResult = ErrorCode.INVALID_BINDING_SYNTAX;
          return;
        }
        String transform = optionParts[1];
        String[] parts = transform.split("\\.");
        if (parts.length != 0) {
           if (parts.length == 1) {
             // No class for transform example: {selected,,negateBoolean}
             // Default to PropertyBinding transforms.
             revTransformClass = "com.hello.uxml.tools.framework.PropertyBinding";
             revTransformFunction = parts[0];
           } else {
             int periodPos = transform.lastIndexOf("\\.");
             revTransformClass = transform.substring(0, periodPos);
             revTransformFunction = transform.substring(periodPos + 1);
           }
           if ((revTransformClass.length() == 0) || (revTransformFunction.length() == 0)) {
             parseResult = ErrorCode.INVALID_BINDING_SYNTAX;
             return;
           }
        }
      } else {
        parseResult = ErrorCode.UNKNOWN_BINDING_PARAMETER;
        return;
      }
      parsedOptions.add(optionParts[0]);
    }

    if (expression.startsWith(CONTROLLER_PREFIX)) {
      isControllerBinding = true;
    } else if (expression.startsWith(DATA_PREFIX)) {
      isDataBinding = true;
    } else if (expression.startsWith(RESOURCE_PREFIX)) {
      explicitResource = true;
    } else if (expression.startsWith(CHROME_TARGET_PREFIX)) {
      explicitTarget = true;
    }
    if (hasNegateSign) {
      transformClass = "com.hello.uxml.tools.framework.PropertyBinding";
      transformFunction = "negateBoolean";
      revTransformClass = "com.hello.uxml.tools.framework.PropertyBinding";
      revTransformFunction = "negateBoolean";
    }
  }

  /**
   * Returns true if binding has a transform.
   */
  public boolean hasTransform() {
    return transformClass != null || revTransformClass != null;
  }

  /**
   * Returns class name for transform.
   */
  public String getTransformClass() {
    return transformClass;
  }

  /**
   * Returns class transform function.
   */
  public String getTransformFunction() {
    return transformFunction;
  }

  /**
   * Returns transform argument.
   */
  public String getTransformArg() {
    return transformArg;
  }

  /**
   * Returns class name for transform.
   */
  public String getRevTransformClass() {
    return revTransformClass;
  }

  /**
   * Returns class transform function.
   */
  public String getRevTransformFunction() {
    return revTransformFunction;
  }
}
