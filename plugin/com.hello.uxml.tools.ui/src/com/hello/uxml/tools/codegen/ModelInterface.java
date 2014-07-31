package com.hello.uxml.tools.codegen;

import com.google.common.collect.Sets;
import com.hello.uxml.tools.codegen.ModelCompiler.ResourceInfo;
import com.hello.uxml.tools.codegen.dom.Model;

import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * Verifies hts markup against interface definition and
 * provides color/brushTable slot information for ModelCompiler.
 *
 * @author ferhat
 */
public class ModelInterface {
  // DOM of interface.
  private Model model;

  private static final String ELEMENT_ID = "id";
  private static final String RESOURCES_ID = "Resources";

  // List of elements allowed as resource inside interface definition.
  private static final String[] RESOURCE_ELEMENTS = new String[] {
      "Color",
      "Brush",
      "SolidBrush",
      "LinearBrush",
      "RadialBrush",
      "VecPath",
      "Chrome",
      "Margin",
      "BorderRadius"
    };

  /**
   * Constructor.
   * @param model Interface DOM
   */
  public ModelInterface(Model model) {
    this.model = model;
  }

  /**
   * Returns name attribute of interface element.
   */
  public String getName() {
    return model.getStringProperty("name");
  }

  /**
   * Verifies that htsModel conforms to interface.
   * @param htsModel DOM of hts markup to verify.
   * @param errors Error collection to output to.
   * @return true if verification succeeds.
   */
  public boolean verifyMembers(Model htsModel,
      Map<String, ResourceInfo> importedResources,
      List<CompilerError> errors) {
    boolean hasErrors = false;
    Set<String> resourceIds = getResourceIds(htsModel);

    // Now check that every id defined in interface exists in htsModel
    for (int r = 0; r < model.getChildCount(); r++) {
      String id = model.getChild(r).getStringProperty(ELEMENT_ID);
      if ((!resourceIds.contains(id)) && (!importedResources.containsKey(id))) {
        hasErrors = true;
        addError(errors, ErrorCode.UNDEFINED_INTERFACE_MEMBER,
            id, htsModel);
      }
    }
    return !hasErrors;
  }

  /** Returns list of ids defined in resources section if markup. */
  private static Set<String> getResourceIds(Model markup) {
    Set<String> resourceIds = Sets.newHashSet();
    Model resourcesNode = findResourceNode(markup);
    if (resourcesNode != null) {
      for (int r = 0; r < resourcesNode.getChildCount(); r++) {
        Model resource = resourcesNode.getChild(r);
        if (resource.hasProperty(ELEMENT_ID)) {
          resourceIds.add(resource.getStringProperty(ELEMENT_ID));
        }
      }
    }
    return resourceIds;
  }

  /** Returns Resources element in hts markup. */
  private static Model findResourceNode(Model model) {
    if (model.getTypeName().equals(RESOURCES_ID)) {
      return model;
    }
    for (int c = 0; c < model.getChildCount(); c++) {
      Model child = model.getChild(c);
      if (child.getTypeName().equals(RESOURCES_ID)) {
        return child;
      }
    }
    return null;
  }

  /**
   * Verifies elements defined in the interface itself.
   */
  public boolean verify(List<CompilerError> errors) {
    boolean hasErrors = false;
    Set<String> allowedElements = Sets.newHashSet();
    for (int i = 0; i < RESOURCE_ELEMENTS.length; i++) {
      allowedElements.add(RESOURCE_ELEMENTS[i]);
    }
    for (int c = 0; c < model.getChildCount(); c++) {
      Model child = model.getChild(c);
      if (!child.hasProperty(ELEMENT_ID)) {
        addError(errors, ErrorCode.EXPECTING_RESOURCE_ID, child);
      }
      if (!allowedElements.contains(child.getTypeName())) {
        addError(errors, ErrorCode.INVALID_RESOURCE_TYPE, child.getTypeName(),
            child);
      }
    }
    return !hasErrors;
  }

  /**
   * Adds error to errors collection.
   */
  public void addError(List<CompilerError> errors, ErrorCode errorCode, String detail,
      Model locality) {
    errors.add(new CompilerError(locality.getLineNumber(),
        locality.getColumn(), String.format("%s [%s]", errorCode.getDescription(),
            detail)));
  }

  /**
   * Adds error to errors collection.
   */
  public void addError(List<CompilerError> errors, ErrorCode errorCode, Model locality) {
    errors.add(new CompilerError(locality.getLineNumber(),
        locality.getColumn(), errorCode.getDescription()));
  }
}
