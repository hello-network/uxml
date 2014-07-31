package com.hello.uxml.tools.codegen;

/**
 * The set of errors possible during code generation.
 *
 * @author ferhat@(Ferhat Buyukkokten)
 */
public enum ErrorCode {

  SUCCESS(0, ""),
  INVALID_BINDING_SYNTAX(-2, "Invalid binding syntax", "Bind expression %s"),
  INVALID_BINDTYPE(-3, "Invalid binding type", "Bindtype '%s'"),
  DUPLICATE_ELEMENT_ID(-4, "Duplicate element id"),
  MISSING_CONTROLLER(-5, "Can't compile events without controller definition on root element."),
  EXPECTING_PROPERTYATTRIBUTE(-6, "Expecting property attribute."),
  INVALID_ROOT_ELEMENT(-7, "Unrecognized root element.", "Type = '%s'"),
  CHILD_ELEMENTS_NOT_SUPPORTED(-8, "Element type does not support children (@ContentType)",
      "Type = '%s'"),
  UNRECOGNIZED_ELEMENT_TAG(-9, "Unrecognized element.", "Tag = '%s'"),
  UNRECOGNIZED_RESOURCE_TYPE(-10, "Unrecognized resource type."),
  EXPECTING_SINGLE_RESOURCES(-11, "Expecting a single Resources node."),
  CANT_FIND_BINDSOURCE(-12, "Can't find binding source", "Binding = '%s'"),
  UNKNOWN_PROPERTY(-13, "Unknown property", "Name = '%s'"),
  UNKNOWN_ELEMENT_ID_IN_TARGET(-14, "Unknown element id", "Attribute = '%s'"),
  NESTED_IMPORTS_NOT_SUPPORTED(-15, "Nested resource imports are not supported"),
  EXPECTING_PATH_ATTRIBUTE(-16, "Expecting path attribute"),
  IMPORT_NOT_SUPPORTED(-17, "Import not supported"),
  INVALID_PARENT_CONTEXT(-18, "Invalid parent context for property"),
  EXPECTING_RESOURCE_ID(-19, "Expecting resource id"),
  INVALID_RESOURCE_TYPE(-20, "Invalid resource type"),
  UNDEFINED_INTERFACE_MEMBER(-21, "Undefined interface resource", "Element id= '%s'"),
  FILE_NOT_FOUND(-22, "File not found.", "Path = '%'"),
  EXPECTING_ALIAS_LINK(-23, "Expecting alias link attribute."),
  EXPECTING_LINK_NOT_FOUND(-24, "Linked resource in alias not found."),
  UNKNOWN_RESOURCE_TYPE_NAME(-25, "Unknown resource type referenced by property"),
  CANNOT_ALIAS_INTERFACE_MEMBER(-26, "Cannot alias a resource that is not defined in this hts."),
  UNKNOWN_BINDING_PARAMETER(-27, "Unknown binding parameter."),
  DUPLICATE_BINDING_PARAMETER(-28, "Binding parameter already defined. Remove duplicate."),
  EXPECTING_COMPONENT_TYPE(-29, "Expecting fully qualified component type attribute."),
  EXPECTING_LOCABUNDLE_TYPE(-30, "Expecting type attribute in localization bundle import"),
  INVALID_LOCALIZATION_SYNTAX(-31, "Invalid localization syntax.", "Expecting %%NAME=literal [%s]"),
  UNKNOWN_LOCALIZATION_ID(-32, "Localization constant not found", "[%s]"),
  UNLOCALIZED_LITERAL(-33, "String literal is not localized", "[%s]"),
  EXPECTING_CONST_TYPE_ATTRIBUTE(-34, "Expecting data type for const declaration"),
  INVALID_CONST_TYPE_ATTRIBUTE(-35, "Invalid data type for const declaration"),
  EXPECTING_CONST_VALUE(-36, "Expecting constant value attribute."),
  // Binding syntax used to be source:twoway etc... after valueTransforms this changed to comma.
  DEPRECATION_ERROR_COLON_IN_BINDING(-1000,
      "Colon is deprecated. Please use {bindingPath,options,transform} syntax."),
  // This should never happen (see valueOf)
  INVALID_ERROR_CODE(-32767, "Invalid or unknown error code");

  private final int code;
  private final String description;
  private final String format;
  /**
   * Constructor.
   * @param code error code
   * @param description description of error
   */
  private ErrorCode(int code, String description) {
    this.code = code;
    this.description = description;
    this.format = "";
  }

  private ErrorCode(int code, String description, String format) {
    this.code = code;
    this.description = description;
    this.format = format;
  }

  /**
  * Gets the error code of the error.
  * @return error code.
  */
  public int getCode() {
    return code;
  }

  /**
  * Gets the description of the error.
  * @return description.
  */
  public String getDescription() {
    return description;
  }

  /**
   * Gets the extended formatting string of the error.
   * @return extended format.
   */
   public String getFormat() {
     return format;
   }

  /**
   * Returns enum value for code.
   */
  public static ErrorCode valueOf(int code) {
    for (ErrorCode c : ErrorCode.values()) {
      if (c.getCode() == code) {
        return c;
      }
    }
    return ErrorCode.INVALID_ERROR_CODE;
  }
}
