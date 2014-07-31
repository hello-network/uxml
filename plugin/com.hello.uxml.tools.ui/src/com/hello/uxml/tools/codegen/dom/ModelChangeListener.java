package com.hello.uxml.tools.codegen.dom;

/**
 * Implements listener for model changes.
 *
 * @author ferhat
 */
public interface ModelChangeListener {
  void modelPropertyChanged(ModelProperty property, Object oldValue, Object newValue);
}
