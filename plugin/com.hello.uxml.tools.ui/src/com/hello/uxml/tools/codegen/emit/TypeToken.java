package com.hello.uxml.tools.codegen.emit;

/**
 * Represents a handle to a type.
 *
 * <p>This class is used to refer to a language neutral type. TypeToken also
 * acts as a factory for language neural base data types (int , string etc..).
 * @author ferhat
 */
public class TypeToken {

  // Predefined lang neutral types
  public static final TypeToken INT8 = new TypeToken("byte");
  public static final TypeToken UINT8 = new TypeToken("sbyte");
  public static final TypeToken INT16 = new TypeToken("short");
  public static final TypeToken UINT16 = new TypeToken("ushort");
  public static final TypeToken INT32 = new TypeToken("int");
  public static final TypeToken UINT32 = new TypeToken("uint");
  public static final TypeToken STRING = new TypeToken("String");
  public static final TypeToken BOOLEAN = new TypeToken("bool");
  public static final TypeToken DOUBLE = new TypeToken("double");
  public static final TypeToken NUMBER = new TypeToken("num");
  public static final TypeToken OBJECT = new TypeToken("Object");
  public static final TypeToken VOID = new TypeToken("void");

  private String namespace;
  private String name;
  private String fullName; // redundant but used a lot

  /**
   * Constructor.
   */
  public TypeToken(String namespace, String name) {
    if (namespace != null && namespace.length() == 0) {
      namespace = null;
    }
    this.namespace = namespace;
    this.name = name;
    this.fullName = namespace == null ? name : (namespace + "." + name);
  }

  /**
   * Constructor.
   */
  public TypeToken(String name) {
    this.name = name;
    this.fullName = name;
  }

  /**
   * Creates a type token from fully qualified name (namespace+class).
   */
  public static TypeToken fromFullName(String fullName) {
    String name;
    String namespace = null;
    int pos = fullName.lastIndexOf('.');
    if (pos == -1) {
      name = fullName;
    } else {
      namespace = fullName.substring(0, pos);
      name = fullName.substring(pos + 1);
    }
    return new TypeToken(namespace, name);
  }

  /**
   * Creates a type token from a framework class.
   */
  public static TypeToken fromClass(Class<?> value) {
    return TypeToken.fromFullName(value.getName());
  }

  /**
   * Returns namespace qualified name.
   */
  public String getFullName() {
    return fullName;
  }

  /**
   * Returns short name of type.
   */
  public String getName() {
    return name;
  }

  /**
   * Returns namespace.
   */
  public String getNamespace() {
    return namespace;
  }

  @Override
  public int hashCode() {
    return fullName.hashCode();
  }

  @Override
  public boolean equals(Object obj) {
    if (!(obj instanceof TypeToken)) {
      return false;
    }
    return fullName.equals(((TypeToken) obj).fullName);
  }

  @Override
  public String toString() {
    return getFullName();
  }
}
