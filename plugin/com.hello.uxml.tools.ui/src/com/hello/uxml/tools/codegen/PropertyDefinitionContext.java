package com.hello.uxml.tools.codegen;

import com.google.common.collect.Maps;
import com.hello.uxml.tools.codegen.emit.TypeToken;

import java.util.Map;

/**
 * Provides a context for ModelCompiler to resolve PropertyDefinition and value
 * attributes inside chrome tags such as PropertyAction and AnimateAction.
 *
 * @author ferhat@(Ferhat Buyukkokten)
 */
public class PropertyDefinitionContext {
  // Maps tag name to PropDefInfo
  private Map<String, PropDefInfo> tagMap = Maps.newHashMap();

  /**
   * Adds property definition information for a specific hts markup tag.
   *
   * <p>For a tag such as <TagName source="mybutton" property="ischecked" value="true">
   * the targetType would be set to 'Button' , targetAttributeName set to 'source'
   * and propertyAttributeName='property' and valueAttributeName='value'.
   *
   * <p>This allows the ModelCompiler to resolve attributes of data type PropertyDefinition
   * and do correct serialization of value.
   * @param tagName Hts tag name
   * @param targetType If targetAttribute is empty this type is used to resolve property.
   * @param targetAttributeName Name of attribute that contains id of target
   * @param propertyAttributeName Name of attribute that contains a property definition
   * @param valueAttributeName Name of attribute that contains a value for the property
   * definition.
   */
  public void addTag(String tagName, TypeToken targetType, String targetAttributeName,
        String propertyAttributeName, String valueAttributeName) {
    PropDefInfo propDefInfo = new PropDefInfo(targetType, targetAttributeName,
        propertyAttributeName, valueAttributeName);
    tagMap.put(tagName, propDefInfo);
  }

  public PropDefInfo getPropertyDefinition(String tagName) {
    return tagMap.get(tagName);
  }

  /**
   * Holds information for resolving property definitions and values.
   */
  public static class PropDefInfo {
    // Specifies base targetType when targetAttribute is not specified in markup.
    // For example the chrome target type is used for effect actions if user
    // doesn't specify an id inside the chrome element tree as the target.
    private TypeToken targetType;
    // Name of attribute to be used to lookup target id
    private String targetAttributeName;
    // Name of property that maps to a PropertyDefinition
    private String propertyAttributeName;
    // Name of property that holds value (optional, null if not used)
    private String valueAttributeName;

    public PropDefInfo(TypeToken targetType, String targetAttributeName,
        String propertyAttributeName, String valueAttributeName) {
      this.targetType = targetType;
      this.targetAttributeName = targetAttributeName;
      this.propertyAttributeName = propertyAttributeName;
      this.valueAttributeName = valueAttributeName;
    }

    /**
     * Returns target type.
     */
    public TypeToken getTargetType() {
      return targetType;
    }

    /**
     * Returns target attribute name.
     */
    public String getTargetAttributeName() {
      return targetAttributeName;
    }

    /**
     * Returns property attribute name.
     */
    public String getPropertyAttributeName() {
      return propertyAttributeName;
    }

    /**
     * Returns value attribute name.
     */
    public String getValueAttributeName() {
      return valueAttributeName;
    }
  }
}
