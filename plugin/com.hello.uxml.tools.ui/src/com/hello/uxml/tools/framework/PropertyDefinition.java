package com.hello.uxml.tools.framework;

import java.util.HashMap;

/**
 * Uniquely identifies a property and maps the owner type to PropertyData.
 *
 * @author ferhat
 */
public class PropertyDefinition {

    private String name;
    /**
     * Maps an owner class to class specific PropertyData.
     */

    private HashMap<Class <? extends UxmlElement>, PropertyData> dataMap;

    /**
     * Holds unique property id
     */
    private int id;

    /**
     * Holds data type of property.
     */
    private Class<?> dataType;

    /**
     * Holds default property data for attached property queries.
     */
    private PropertyData defaultPropData;

    /**
     * Constructor.
     */
    PropertyDefinition(int id, String name, Class<?> dataType,
        Class<? extends UxmlElement> ownerClass) {
      this.id = id;
      this.name = name;
      this.dataType = dataType;
      this.dataMap = new HashMap<Class<? extends UxmlElement>, PropertyData>();
      this.dataMap.put(ownerClass, null);
    }

    /**
     * Constructor.
     */
    PropertyDefinition(int id, String name, Class<?> dataType,
        Class<? extends UxmlElement> ownerClass, PropertyData propData) {
      this.id = id;
      this.name = name;
      this.dataType = dataType;
      this.dataMap = new HashMap<Class<? extends UxmlElement>, PropertyData>();
      this.dataMap.put(ownerClass, propData);
      this.defaultPropData = propData;
      propData.setOwner(ownerClass);
    }

    /**
     * Get PropertyData registered for an owner.
     *
     * @param ownerClass class that owns the property data override
     */
    @SuppressWarnings("unchecked")  // unchecked, Loop terminates at Element superClass
    public PropertyData getPropData(Class<? extends UxmlElement> ownerClass) {
      do {
        PropertyData d = dataMap.get(ownerClass);
        if (d != null) {
          return d;
        }
        ownerClass = (Class<? extends UxmlElement>) ownerClass.getSuperclass();
      } while (ownerClass != null);
      return null;
    }


    /**
     * Returns default property data.
     */
    public PropertyData getDefaultPropData() {
      return defaultPropData;
    }

    /**
     * Registers new ownerClass and property data.
     *
     * <p>Returns PropertyDefinition so that static propDefs on subclasses are more readable
     * and easier to create.
     */
    public PropertyDefinition addPropData(Class<? extends UxmlElement> ownerClass,
        PropertyData propdata) {
      dataMap.put(ownerClass, propdata);
      propdata.setOwner(ownerClass);
      return this;
    }

    /**
     * Returns name of property
     */
    public String getName() {
      return name;
    }

    /**
     * Returns unique id of property
     */
    public int getId() {
      return id;
    }

    /**
     * Returns data type of property.
     */
    public Class<?> getDataType() {
      return dataType;
    }

    /**
     * (non-Javadoc)
     * @see java.lang.Object
     */
    @Override public int hashCode() {
      return id;
    }
}
