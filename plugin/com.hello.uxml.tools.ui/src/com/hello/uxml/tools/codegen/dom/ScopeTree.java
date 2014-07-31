package com.hello.uxml.tools.codegen.dom;

import com.google.common.collect.Lists;
import com.google.common.collect.Maps;
import com.hello.uxml.tools.framework.UIElement;

import java.util.List;
import java.util.Map;

/**
 * Calculates element scope information of a model tree.
 *
 * <p>Scope information can be used to resolve Hts DOM element id's used in binding
 * expressions. Typically ids inside Chrome definitions are islands to themselves
 * and therefore have their own scope.
 *
 * <p>BindingScope creates a tree of Scope objects. Each scope has a map to
 * quickly access the Model node given an id. The BindingScope class resolves
 * an id by traversing the scope tree using a start node.
 *
 * @author ferhat@(Ferhat Buyukkokten)
 */
public class ScopeTree {

  /**
   * Maps an element to a particular scope.
   */
  private Map<Model, Scope>modelToScopeMap = Maps.newHashMap();

  /**
   * Holds duplicate id nodes. This is used to report duplicate node ids to
   * compiler.
   */
  private List<Model> duplicateIdNodes = Lists.newArrayList();

  public ScopeTree(Model model) {
    buildScopeTree(null, model);
  }

  private void buildScopeTree(Scope parentScope, Model node) {
    String nodeType = node.getTypeName();
    if (parentScope == null) {
      parentScope = new Scope(null, node);
    } else if (nodeType.equals("Chrome")) {
      Scope newScope = new Scope(parentScope, node);
      parentScope.add(newScope);
      parentScope = newScope;
    }
    if (node.hasProperty("id")) {
      String id = node.getStringProperty("id");
      if (parentScope.get(id) != null) {
        duplicateIdNodes.add(node);
      }
      parentScope.put(id, node);
    }

    modelToScopeMap.put(node, parentScope);

    for (int i = 0; i < node.getChildCount(); ++i) {
      buildScopeTree(parentScope, node.getChild(i));
    }
    // Check properties that hold logical children
    for (int p = 0; p < node.getPropertyCount(); ++p) {
      ModelProperty prop = node.getProperty(p);
      if (prop instanceof ModelCollectionProperty) {
        ModelCollectionProperty items = (ModelCollectionProperty) node.getProperty(p);
        for (int itemIndex = 0; itemIndex < items.getChildCount(); ++itemIndex) {
          buildScopeTree(parentScope, items.getChild(itemIndex));
        }
      } else if (prop.getDataType() != null && prop.getDataType().isAssignableFrom(
          UIElement.class) && (prop.value instanceof Model)) {
        buildScopeTree(parentScope, (Model) prop.value);
      }
    }
  }

  /**
   * Returns model node given an id and relative element.
   */
  public Model resolveId(Model startingNode, String id) {
    Scope scope = modelToScopeMap.get(startingNode);
    if (scope == null) {
      return null;
    }
    do {
      Model result = scope.get(id);
      if (result != null) {
        return result;
      }
      scope = scope.getParent();
    } while (scope != null);
    return null;
  }

  /**
   * Returns list of duplicate nodes.
   */
  public List<Model> getDuplicateIdNodes() {
    return duplicateIdNodes;
  }

  /**
   * Keeps a hashmap from id's to Model nodes for a scope.
   */
  private class Scope {
    /**
     * Root node in model tree where scope starts.
     */
    private Model scopeRoot;

    private Scope parent;

    private List<Scope> children = Lists.newArrayList();

    /**
     * Maps id's to nodes.
     */
    private Map<String, Model> idMap = Maps.newHashMap();

    /**
     * Constructor.
     */
    public Scope(Scope parent, Model scopeRoot) {
      this.parent = parent;
      this.scopeRoot = scopeRoot;
    }

    /**
     * Adds a child scope.
     */
    public void add(Scope child) {
      children.add(child);
    }

    /**
     * Adds a model node to the scope.
     */
    public void put(String id, Model node) {
      idMap.put(id, node);
    }

    /**
     * Returns model that has given id. If id not found, returns null.
     */
    public Model get(String id) {
      return idMap.get(id);
    }

    /**
     * Returns root of scope.
     */
    @SuppressWarnings("unused")
    public Model getRoot() {
      return scopeRoot;
    }

    /**
     * Returns parent scope.
     */
    public Scope getParent() {
      return parent;
    }

    @SuppressWarnings("unused")
    public List<Scope> getChildren() {
      return children;
    }
  }
}
