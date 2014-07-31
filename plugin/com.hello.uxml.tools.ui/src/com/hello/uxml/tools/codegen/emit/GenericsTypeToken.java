package com.hello.uxml.tools.codegen.emit;

import java.util.ArrayList;

/**
 * Defines a generics TypeToken (ie. genericsName< Type1, Type2 >)
 *
 * @author ericarnold@ (Eric Arnold)
 *
 */
public class GenericsTypeToken extends TypeToken {

  ArrayList<TypeToken> typeParameters;

  /**
   * Constructs a generics TypeToken (ie. genericsName< Type1, Type2 >) without a namespace.
   *
   * @param name The name of the genericsTypeToken
   */
  public GenericsTypeToken(String name) {
    super(name);
    init();
  }

  /**
   * Constructs a generics TypeToken (ie. com.google.genericsName< Type1, Type2 >) with a namespace.
   *
   * @param namespace The namespace of the genericsTypeToken (ie. <namespace>.genericsName<int>)
   * @param name The name of the genericsTypeToken (ie. <name><int>)
   */
  public GenericsTypeToken(String namespace, String name) {
    super(namespace, name);
    init();
  }

  /**
   * Adds a type parameter to the generics type (ie. genericsName< Type1, <typeParameter> >)
   *
   * @param typeParameter The type parameter to add
   */
  public void addParameter(TypeToken typeParameter) {
    typeParameters.add(typeParameter);
  }

  @Override
  public String getFullName() {
    return super.getFullName() + getParameters();
  }

  @Override
  public String getName() {
    return super.getName() + getParameters();
  }

  private String getParameters() {
    String genericsReturn = "<";
    final int typeParametersLength = typeParameters.size();
    Boolean firstType = true;
    for (int typeParameterIndex = 0; typeParameterIndex < typeParametersLength;
        typeParameterIndex++) {
      if (firstType) {
        firstType = false;
      } else {
        genericsReturn += ", ";
      }
      TypeToken typeParameter = typeParameters.get(typeParameterIndex);
      genericsReturn += typeParameter.getName();
    }
    genericsReturn += ">";
    return genericsReturn;
  }

  @Override
  public String toString() {
    return getFullName();
  }

  private void init() {
    typeParameters = new ArrayList<TypeToken>();
  }
}
