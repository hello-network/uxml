package com.hello.uxml.tools.codegen.dom;

import java.util.ArrayList;
import java.util.List;

/**
 * Exposes a ModelProperty that has List<Model> value type.
 * @author ferhat@(Ferhat Buyukkokten)
 *
 */
public class ModelCollectionProperty extends ModelProperty {

  /**
   * Constructor.
   */
  public ModelCollectionProperty(String name) {
    super(name, null);
    value = new ArrayList<Model>();
  }

  public ModelCollectionProperty(String name, List<Model> items) {
    super(name, null);
    this.value = items;
  }

  @SuppressWarnings("unchecked")
  private List<Model> getList() {
    return ((List<Model>) this.value);
  }

  /**
   * Returns number of children.
   */
  public int getChildCount() {
    return getList().size();
  }

  /**
   * Returns child at index.
   */
  public Model getChild(int index) {
    return getList().get(index);
  }

  /**
   * Adds child to collection.
   */
  public void addChild(Model child) {
    getList().add(child);
  }

  /**
   * Removes child from collection.
   */
  public void removeChild(Model child) {
    getList().remove(child);
  }

  /**
   * Removes child at index.
   */
  public void removeChild(int index) {
    getList().remove(index);
  }
}
