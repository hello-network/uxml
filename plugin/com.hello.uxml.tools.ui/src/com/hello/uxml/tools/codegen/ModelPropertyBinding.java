package com.hello.uxml.tools.codegen;

import com.hello.uxml.tools.codegen.emit.expressions.Expression;
import com.hello.uxml.tools.codegen.emit.expressions.Reference;

/**
 * Holds information about property bindings to be processed in second phase
 * of ModelCompiler/ChromeCompiler.
 *
 * @author ferhat
 */
public class ModelPropertyBinding {
  private Reference targetBindingsCollection;
  private Expression sourceObject;
  private Expression[] sourceProperty;
  private Reference targetObject;
  private String targetProperty;
  private String transformClass;
  private String transformFunction;
  private String transformArg;

  /**
   * Constructor.
   */
  public ModelPropertyBinding(Reference targetBindingsCollection,
      Reference target, String targetProperty,
      Expression source, Expression sourceProperty) {
    this(targetBindingsCollection, target, targetProperty, source,
        new Expression[] {sourceProperty});
  }

  /**
   * Constructor.
   */
  public ModelPropertyBinding(Reference targetBindingsCollection,
      Reference target, String targetProperty,
      Expression source, Expression[] sourceProperty) {
    this(targetBindingsCollection, target, targetProperty, source,
        sourceProperty, null, null);
  }

  /**
   * Constructor.
   */
  public ModelPropertyBinding(Reference targetBindingsCollection,
      Reference target, String targetProperty,
      Expression source, Expression sourceProperty, String transformClass,
      String transformFunction) {
    this(targetBindingsCollection, target, targetProperty, source,
        new Expression[] {sourceProperty}, transformClass, transformFunction);
  }

  /**
   * Constructor.
   */
  public ModelPropertyBinding(Reference targetBindingsCollection,
      Reference target, String targetProperty,
      Expression source, Expression sourceProperty, String transformClass,
      String transformFunction, String transformArg) {
    this(targetBindingsCollection, target, targetProperty, source,
        new Expression[] {sourceProperty}, transformClass, transformFunction, transformArg);
  }

  /**
   * Constructor.
   */
  public ModelPropertyBinding(Reference targetBindingsCollection,
      Reference target, String targetProperty,
      Expression source, Expression[] sourceProperty, String transformClass,
      String transformFunction) {
    this(targetBindingsCollection, target, targetProperty, source,
        sourceProperty, transformClass, transformFunction, null);
  }

  /**
   * Constructor.
   */
  public ModelPropertyBinding(Reference targetBindingsCollection,
      Reference target, String targetProperty,
      Expression source, Expression[] sourceProperty, String transformClass,
      String transformFunction, String transformArg) {
    sourceObject = source;
    this.sourceProperty = sourceProperty;
    targetObject = target;
    this.targetProperty = targetProperty;
    this.targetBindingsCollection = targetBindingsCollection;
    this.transformClass = transformClass;
    this.transformFunction = transformFunction;
    this.transformArg = transformArg;
  }

  /**
   * Returns reference to source of binding.
   */
  public Expression getSource() {
    return sourceObject;
  }

  /**
   * Returns reference to target bindings collection.
   */
  public Reference getTargetBindingsCollection() {
    return targetBindingsCollection;
  }

  /**
   * Returns reference to target of binding.
   */
  public Reference getTarget() {
    return targetObject;
  }

  /**
   * Returns source property identifier.
   */
  public Expression[] getSourceProperty() {
    return sourceProperty;
  }

  /**
   * Returns target property identifier.
   */
  public String getTargetProperty() {
    return targetProperty;
  }

  /**
   * Returns true if binding has transform.
   */
  public boolean hasTransform() {
    return transformClass != null && transformClass.length() != 0;
  }

  /**
   * Returns binding transform class name.
   */
  public String getTransformClass() {
    return transformClass;
  }

  /**
   * Returns binding transform function name.
   */
  public String getTransformFunction() {
    return transformFunction;
  }

  /**
   * Returns binding transform argument.
   */
  public String getTransformArg() {
    return transformArg;
  }
}
