package com.hello.uxml.tools.codegen.emit.java;

import com.google.common.base.Preconditions;
import com.google.common.collect.Lists;
import com.hello.uxml.tools.codegen.emit.ClassBuilder;
import com.hello.uxml.tools.codegen.emit.FieldAttributes;
import com.hello.uxml.tools.codegen.emit.FieldBuilder;
import com.hello.uxml.tools.codegen.emit.FieldComparator;
import com.hello.uxml.tools.codegen.emit.MethodBuilder;
import com.hello.uxml.tools.codegen.emit.PackageBuilder;
import com.hello.uxml.tools.codegen.emit.SourceWriter;
import com.hello.uxml.tools.codegen.emit.TypeToken;
import com.hello.uxml.tools.codegen.emit.UniqueNameGenerator;
import com.hello.uxml.tools.codegen.emit.expressions.Expression;
import com.hello.uxml.tools.codegen.emit.expressions.Reference;

import java.util.ArrayList;
import java.util.Collections;
import java.util.EnumSet;
import java.util.List;

/**
 * Implements class builder for ActionScript3.
 *
 * @author ferhat
 */
public class JClassBuilder implements ClassBuilder {
  private String name;
  private TypeToken baseClass;
  private JPackageBuilder owner;
  /** Class comments */
  private String comments;

  // Holds a list of instance and class fields.
  private List<JFieldBuilder> fields;

  // Holds a list of member functions and constructors of class
  private List<JMethodBuilder> methods;

  // Holds a list of classes that this class implements
  private List<TypeToken> implementedClasses;

  private UniqueNameGenerator nameGenerator;

  /**
   * Constructor.
   */
  public JClassBuilder(JPackageBuilder owner, String name) {
    this.name = name;
    this.owner = owner;
    this.implementedClasses = new ArrayList<TypeToken>();
  }

  /**
   * Returns name of class.
   */
  @Override
  public String getName() {
    return this.name;
  }

  /**
   * Sets or returns class comments.
   */
  @Override
  public String getComments() {
    return comments;
  }

  @Override
  public void setComments(String value) {
    comments = value;
  }

  /**
   * Returns package of class
   */
  @Override
  public PackageBuilder getPackage() {
    return owner;
  }

  /**
   * Returns base class.
   */
  @Override
  public TypeToken getBaseClass() {
    return baseClass;
  }

  /** Sets base class */
  @Override
  public void setBaseClass(TypeToken type) {
    baseClass = type;
  }

  @Override
  public FieldBuilder createField(Reference fieldReference,
      EnumSet<FieldAttributes> fieldAttributes) {
    return createField(fieldReference, fieldAttributes, null);
  }
  @Override
  public FieldBuilder createField(Reference fieldReference,
      EnumSet<FieldAttributes> fieldAttributes, Expression initExpression) {
    if (fields == null) {
      fields = Lists.newArrayList();
    }
    JFieldBuilder fieldBuilder = new JFieldBuilder(fieldReference, fieldAttributes,
        initExpression);
    fields.add(fieldBuilder);
    return fieldBuilder;
  }

  /**
   * Creates default constructor
   */
  @Override
  public MethodBuilder createDefaultConstructor() {
    MethodBuilder constructor = createMethod("", null);
    constructor.isConstructor = true;
    return constructor;
  }


  /**
   * Creates a method.
   */
  @Override
  public MethodBuilder createMethod(String methodName, TypeToken returnType) {
    if (this.methods == null) {
      this.methods = Lists.newArrayList();
    }
    JMethodBuilder method = new JMethodBuilder(methodName, returnType, owner, this);
    this.methods.add(method);
    return method;
  }


  @Override
  public boolean write(SourceWriter writer) {
    // TODO(ericarnold): remove write

    // Write class comments
    if ((comments != null) && (comments.length() != 0)) {
      String[] lines = comments.split("\n");
      writer.println("/**");
      for (String line : lines) {
        writer.print(" * ");
        writer.println(line);
      }
      writer.println(" */");
    }

    writer.print("public class ");
    writer.print(name);
    if ((baseClass != null) && (baseClass != TypeToken.OBJECT)) {
      writer.print(" extends ");
      writer.print(baseClass.getName());
    }

    if (implementedClasses.size() != 0) {
      writer.print(" implements ");
      final int implementedClassesLength = implementedClasses.size();
      boolean first = true;
      for (int implementedClassIndex = 0; implementedClassIndex < implementedClassesLength;
          implementedClassIndex++) {
        TypeToken implementedClass = implementedClasses.get(implementedClassIndex);
        if (first) {
          first = false;
        } else {
          writer.print(", ");
        }
        writer.print(implementedClass.getName());
      }
    }

    writer.println(" {");
    writer.indent();

    if (fields != null) {
      Collections.sort(fields, new FieldComparator());
      for (FieldBuilder field : fields) {
        writeField(field, writer);
      }
    }

    if (methods != null) {
      for (MethodBuilder method : methods) {
        writer.printEmptyLine();
        writeMethod(method, writer);
      }
    }

    writer.outdent();
    writer.println("}");
    return true;
  }

  private void writeField(FieldBuilder field, SourceWriter writer) {
    Preconditions.checkNotNull(field);
    String fieldAttrib = fieldAttributeToString(field);
    if (fieldAttrib.length() != 0) {
      writer.print(fieldAttrib);
      writer.print(" ");
    }
    writer.print(getPackage().tokenTypeToString(field.getType()));
    writer.print(" ");
    writer.print(field.getName());
    Expression initExpression = field.getInitExpression();
    if (initExpression != null) {
      writer.print(" = ");
      initExpression.toCode(writer);
    }
    writer.println(";");
  }

  private String fieldAttributeToString(FieldBuilder field) {
    String str = "";
    if (field.getAttributes().contains(FieldAttributes.Public)) {
      str = "public";
    } else if (field.getAttributes().contains(FieldAttributes.Protected)) {
      str = "protected";
    } else if (field.getAttributes().contains(FieldAttributes.Private)) {
      str = "private";
    } else if (field.getAttributes().contains(FieldAttributes.Internal)) {
      str = "";
    }

    if (field.getAttributes().contains(FieldAttributes.Const)) {
      str += " static final";
    } else if (field.getAttributes().contains(FieldAttributes.Static)) {
      str += " static";
    }
    return str;
  }

  private void writeMethod(MethodBuilder method, SourceWriter writer) {
    Preconditions.checkNotNull(method);
    ((JMethodBuilder) method).write(writer);
  }

  /**
   * Returns unique variable name generator.
   */
  @Override
  public UniqueNameGenerator getNameGenerator() {
    if (nameGenerator == null) {
      nameGenerator = new UniqueNameGenerator();
    }
    return nameGenerator;
  }

  @Override
  public void addImplements(TypeToken implementsClass) {
    this.implementedClasses.add(implementsClass);
  }

  @Override
  public List<TypeToken> getImplementedClasses() {
    return this.implementedClasses;
  }
}
