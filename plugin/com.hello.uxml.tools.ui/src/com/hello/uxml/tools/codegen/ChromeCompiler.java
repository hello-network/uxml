package com.hello.uxml.tools.codegen;

import com.hello.uxml.tools.framework.Application;
import com.hello.uxml.tools.framework.Chrome;
import com.hello.uxml.tools.framework.Controller;
import com.hello.uxml.tools.framework.PropertyBinding;
import com.hello.uxml.tools.framework.PropertyData;
import com.hello.uxml.tools.framework.PropertyDefinition;
import com.hello.uxml.tools.framework.UIElement;
import com.hello.uxml.tools.framework.events.EventArgs;
import com.hello.uxml.tools.framework.events.EventDefinition;
import com.hello.uxml.tools.codegen.ModelCompiler.ResourceInfo;
import com.hello.uxml.tools.codegen.dom.Model;
import com.hello.uxml.tools.codegen.dom.ModelProperty;
import com.hello.uxml.tools.codegen.dom.ModelReflector;
import com.hello.uxml.tools.codegen.emit.ClassBuilder;
import com.hello.uxml.tools.codegen.emit.CodeSerializer;
import com.hello.uxml.tools.codegen.emit.FieldAttributes;
import com.hello.uxml.tools.codegen.emit.FieldBuilder;
import com.hello.uxml.tools.codegen.emit.MethodBuilder;
import com.hello.uxml.tools.codegen.emit.MethodParameter;
import com.hello.uxml.tools.codegen.emit.PackageBuilder;
import com.hello.uxml.tools.codegen.emit.TypeToken;
import com.hello.uxml.tools.codegen.emit.expressions.AssignmentExpression;
import com.hello.uxml.tools.codegen.emit.expressions.AssignmentExpression.AssignmentExpressionType;
import com.hello.uxml.tools.codegen.emit.expressions.CodeBlock;
import com.hello.uxml.tools.codegen.emit.expressions.Expression;
import com.hello.uxml.tools.codegen.emit.expressions.ExpressionStatement;
import com.hello.uxml.tools.codegen.emit.expressions.MethodCall;
import com.hello.uxml.tools.codegen.emit.expressions.NullLiteralExpression;
import com.hello.uxml.tools.codegen.emit.expressions.Reference;
import com.hello.uxml.tools.codegen.emit.expressions.ReturnStatement;
import com.hello.uxml.tools.codegen.emit.expressions.StringLiteralExpression;
import com.hello.uxml.tools.codegen.emit.expressions.VariableDefinitionStatement;
import com.hello.uxml.tools.codegen.emit.java.JClosure;

import java.util.EnumSet;
import java.util.List;

/**
 * Compiles a chrome definition for ModelCompiler
 *
 * @author ferhat@(Ferhat Buyukkokten)
 */
public class ChromeCompiler {

  // Chrome child tag names
  private static final String CHROME_CHILD_ELEMENTS = "Elements";
  private static final String CHROME_CHILD_PROPERTIES = "Properties";
  private static final String CHROME_CHILD_PROPERTY = "Property";
  private static final String CHROME_CHILD_EFFECTS = "Effects";

  private static final String CHROME_TARGET_VAR_NAME = "target";
  public static final String CHROME_METHOD_TARGET_PARAM_NAME = "targetElement";

  // Error messages
  private static final String ERROR_MSG_ELEMENTS_SINGLE_CHILD =
      "Expecting a single child node under chrome elements tag";
  private static final String ERROR_MSG_UNKNOWN_CHROME_CHILD =
      "Unknown tag '%s' in Chrome definition";
  private static final String ERROR_MSG_UNRECOGNIZED_ELEMENT_TAG =
      "Unrecognized element tag '%s'";
  private static final String ERROR_MSG_MISSING_CHROME_TYPE =
      "Missing required chrome type attribute";
  private static final String ERROR_MSG_INVALID_PROPERTIES_CHILD =
      "Invalid properties tag. Expecting 'Property'";
  private static final String ERROR_MSG_MISSING_PROPERTY_NAME =
      "Missing name attribute in 'Property' tag";
  private static final String ERROR_MSG_MISSING_PROPERTY_VALUE =
      "Missing property value";
  private static final String ERROR_MSG_MISSING_CHROME_TARGET_TYPE =
      "Missing 'type' attribute on Chrome element";

  private ModelCompiler modelCompiler;
  private PackageBuilder packageBuilder;
  private MethodBuilder chromeMethod;
  private Reference controller;
  private ModelReflector modelReflector;

  /** Key to be used in resources collection*/
  private String chromeId;
  private Expression chromeKey;

  /**
   * Constructor.
   */
  public ChromeCompiler(ModelCompiler modelCompiler) {
    this.modelCompiler = modelCompiler;
    packageBuilder = modelCompiler.getPackageBuilder();
    modelReflector = modelCompiler.getModelReflector();
  }

  /**
   * Compiles a chrome resource to code and returns reference to chrome instance.
   */
  public Reference compile(Model chromeNode, CodeBlock codeBlock) {

    // resolve targettype and id
    String typeName = chromeNode.getTypeName();
    TypeToken chromeType = modelCompiler.elementTypeToToken(typeName);
    chromeMethod = null;
    if (!chromeNode.hasProperty("type")) {
      addError(new CompilerError(chromeNode.getLineNumber(), chromeNode.getColumn(),
          ERROR_MSG_MISSING_CHROME_TARGET_TYPE));
      return null;
    }
    String targetTypeName = chromeNode.getStringProperty("type");
    TypeToken chromeTargetType = null;

    if ((targetTypeName == null) || (targetTypeName.length() == 0)) {
      addError(new CompilerError(chromeNode.getLineNumber(),
          chromeNode.getColumn(), ERROR_MSG_MISSING_CHROME_TYPE));
      targetTypeName = "missingType";
    } else {
      chromeTargetType = modelCompiler.elementTypeToToken(targetTypeName);
      if (chromeTargetType == null) {
        addError(new CompilerError(chromeNode.getLineNumber(), chromeNode.getColumn(),
            String.format(ERROR_MSG_UNRECOGNIZED_ELEMENT_TAG, targetTypeName)));
        // recover from error to continue compile
        chromeTargetType = TypeToken.fromClass(UIElement.class);
      }
    }
    chromeId = chromeNode.hasProperty("id") ? chromeNode.getStringProperty("id") : null;

    // If we have an id, create a field otherwise create chrome on stack before
    // adding to resources collection.
    Reference varReference = null;

    if ((chromeId == null) || (chromeId.length() == 0)) {
      chromeId = targetTypeName;
      String varName = targetTypeName.substring(0, 1).toLowerCase() + targetTypeName.substring(1);
      varName = codeBlock.createVariableName(varName + "Chrome");
      VariableDefinitionStatement varDef = packageBuilder.createVariableDefinition(
          packageBuilder.createReferenceExpression(varName, chromeType));
      codeBlock.addStatement(varDef);
      varReference = varDef.getReference();
      chromeKey = packageBuilder.createClassReferenceExpression(chromeTargetType);
    } else {
      MethodBuilder method = codeBlock.getFunction().getMethod();
      ClassBuilder classBuilder = method.getClassBuilder();
      FieldBuilder field = classBuilder.createField(new Reference(chromeId,
          chromeType), EnumSet.of(FieldAttributes.Public));
      varReference = field.getReference();
      chromeKey = packageBuilder.createStringLiteralExpression(chromeId);
    }

    MethodBuilder method = codeBlock.getFunction().getMethod();
    createChromeMethod(chromeNode, chromeId, method.getClassBuilder());

    Expression idExpr = packageBuilder.createStringLiteralExpression(chromeId);
    ChromeDefContext chromeDefContext;
    chromeDefContext = new ChromeDefContext(chromeId, chromeTargetType, varReference,
        chromeMethod);
    modelCompiler.pushChromeContext(chromeDefContext);
    // Create field to hold chrome instance

    // We need to create a function to build up the chrome element tree to pass
    // to new Chrome(...).
    Expression chromeTreeRoot = new NullLiteralExpression();
    int childCount = chromeNode.getChildCount();
    for (int c = 0; c < childCount; ++c) {
      Model child = chromeNode.getChild(c);
      if (child.getTypeName().equals(CHROME_CHILD_ELEMENTS)) {
        chromeTreeRoot = readChromeElements(chromeNode, chromeId, child, codeBlock);
      }
    }

    if (chromeTargetType == null) {
      // recover from target type error so compile can continue to uncover more errors.
      chromeTargetType = TypeToken.fromClass(UIElement.class);
    }

    Reference targetElementReference = new Reference("targetElement");

    // Create chrome instance: new Chrome(id, TargetType.class, createElementsDelegate)
    packageBuilder.addImport(chromeTargetType);
    Expression chromeTargetTypeExpression =
        packageBuilder.createElementTypeReferenceExpression(chromeTargetType);
    Expression delegateExpr = chromeMethod == null ? new NullLiteralExpression()
      : packageBuilder.createChromeDelegate(chromeMethod.getName());
    Expression[] parameters = {idExpr, chromeTargetTypeExpression, delegateExpr};
    Expression assignmentValue = packageBuilder.createNewObjectExpression(
      TypeToken.fromClass(Chrome.class), parameters);
    AssignmentExpression assignmentExpression = new AssignmentExpression(
      varReference, assignmentValue, AssignmentExpressionType.REGULAR);
    ExpressionStatement assignmentStatement = new ExpressionStatement(assignmentExpression);
    codeBlock.addStatement(assignmentStatement);

    // Create code for properties and effects
    for (int c = 0; c < childCount; ++c) {
      Model child = chromeNode.getChild(c);
      if (child.getTypeName().equals(CHROME_CHILD_PROPERTIES)) {
        CodeBlock chromeBlock = new CodeBlock(chromeMethod);
        readChromeProperties(child, chromeTargetType, chromeBlock);
        chromeMethod.add(chromeBlock);
      } else if (child.getTypeName().equals(CHROME_CHILD_EFFECTS)) {
        PropertyDefinitionContext propDefContext = new PropertyDefinitionContext();
        propDefContext.addTag("Effect", chromeTargetType, "source", "property", "value");
        propDefContext.addTag("PropertyAction", chromeTargetType,
            "target", "property", "value");
        propDefContext.addTag("AnimateAction", chromeTargetType,
            "target", "property", "toValue");
        modelCompiler.pushContext(propDefContext);

        //CodeBlock chromeBlock = new CodeBlock(chromeMethod);
        chromeDefContext.setIsReadingEffects(true);
        modelCompiler.readEffects(child, varReference, chromeTargetType, codeBlock);
        chromeDefContext.setIsReadingEffects(false);
        //chromeMethod.add(chromeBlock);
        modelCompiler.popContext();
      } else if (!child.getTypeName().equals(CHROME_CHILD_ELEMENTS)) {
        addError(new CompilerError(child.getLineNumber(), child.getColumn(),
            String.format(ERROR_MSG_UNKNOWN_CHROME_CHILD, child.getTypeName())));
      }
    }

    modelCompiler.popChromeContext();

    // Create code for bindings (property and event bindings)
    // Typical binding code for content:
    //
    //   var binding:PropertyBinding =
    //       new PropertyBinding(contentContainer1, ContentContainer.contentPropDef,
    //           targetElement, [Button.contentPropDef]);
    //   contentContainer1.bindings.push(binding);
    if (modelCompiler.chromePropertyBindings != null) {
      TypeToken propertyBindingType = TypeToken.fromClass(PropertyBinding.class);
      for (ModelPropertyBinding bind : modelCompiler.chromePropertyBindings) {
        packageBuilder.addImport(TypeToken.fromClass(PropertyBinding.class));
        Expression bindingCollectionExpr = packageBuilder.createGetPropertyExpression(
            targetElementReference, "bindings");
        Expression targetPropertyExpression = new StringLiteralExpression(bind.getTargetProperty());
        Expression[] sourcePropertyExpression = bind.getSourceProperty();

        Expression[] bindingParameters;
        if (bind.hasTransform()) {
          TypeToken transformClass = TypeToken.fromFullName(bind.getTransformClass());
          packageBuilder.addImport(transformClass);
          Expression transformClosure = packageBuilder.createGetStaticFieldExpression(
              transformClass, bind.getTransformFunction());
          if (bind.getTransformArg() == null) {
            bindingParameters = new Expression[] {bind.getTarget(), targetPropertyExpression,
                bind.getSource(), packageBuilder.createArray(TypeToken.OBJECT,
                    sourcePropertyExpression), transformClosure};
          } else {
            bindingParameters = new Expression[] {bind.getTarget(), targetPropertyExpression,
                bind.getSource(), packageBuilder.createArray(TypeToken.OBJECT,
                    sourcePropertyExpression), transformClosure,
                    new StringLiteralExpression(bind.getTransformArg())};
          }
        } else {
          bindingParameters = new Expression[] {bind.getTarget(), targetPropertyExpression,
              bind.getSource(), packageBuilder.createArray(TypeToken.OBJECT,
                  sourcePropertyExpression)};
        }
        Expression bindingExpr = packageBuilder.createNewObjectExpression(propertyBindingType,
            bindingParameters);
        chromeMethod.addStatement(packageBuilder.createCollectionAddStatement(
            bindingCollectionExpr, bindingExpr));
      }
    }

    compileEventBindings(modelCompiler.chromeEventBindings);

    if (chromeNode.hasProperty(ModelCompiler.CONTROLLER_VARIABLE_NAME)) {
      // Call preInit on controller.
      Expression callCompleteCall = packageBuilder.createMethodCall(
          controller, "preInit");
      packageBuilder.addImport(TypeToken.fromClass(Controller.class));
      chromeMethod.addStatement(new ExpressionStatement(callCompleteCall));
    }

    if (chromeMethod != null) {
      chromeMethod.addStatement(new ReturnStatement(chromeTreeRoot));
    }
    return varReference;
  }

  /**
   * Reads Elements tag contents and create a method to build chrome tree.
   */
  private Expression readChromeElements(Model chromeNode, String chromeName, Model elementsNode,
      CodeBlock codeBlock) {

    if (elementsNode.getChildCount() == 0) {
      return null; // valid case where chrome doesn't modify element tree of target
    }

    // Report error if elements node has more than one child.
    if (elementsNode.getChildCount() > 1) {
      modelCompiler.addError(new CompilerError(elementsNode.getLineNumber(),
          elementsNode.getColumn(), ERROR_MSG_ELEMENTS_SINGLE_CHILD));
    }

    MethodBuilder method = codeBlock.getFunction().getMethod();
    createChromeMethod(chromeNode, chromeName, method.getClassBuilder());
    CodeBlock chromeBlock = new CodeBlock(chromeMethod);
    // Convert Chrome Elements tag children to code.
    Expression childExpr = modelCompiler.readChildNode(elementsNode.getChild(0), chromeBlock);
    chromeMethod.add(chromeBlock);
    return childExpr;
  }

  /**
   * Creates chrome elements method on demand. The method is not needed if we only
   * have effects that defines the chrome.
   */
  private void createChromeMethod(Model chromeNode, String chromeName, ClassBuilder classBuilder) {
    String chromeMethodName = classBuilder.getNameGenerator().createVariableName(
        createChromeMethodName(chromeName));
    TypeToken uiElementType = TypeToken.fromClass(UIElement.class);
    packageBuilder.addImport(uiElementType);
    if (chromeMethod == null) {
      chromeMethod = classBuilder.createMethod(chromeMethodName, uiElementType);
      chromeMethod.addParameter(new MethodParameter(new Reference(
          CHROME_METHOD_TARGET_PARAM_NAME, TypeToken.fromClass(UIElement.class))));

      if (chromeNode.hasProperty(ModelCompiler.CONTROLLER_VARIABLE_NAME)) {
        // Create controller instance.
        String controllerTypeName = chromeNode.getStringProperty(
            ModelCompiler.CONTROLLER_VARIABLE_NAME);
        if (controllerTypeName != null) {
          TypeToken controllerType = TypeToken.fromFullName(controllerTypeName);
          packageBuilder.addImport(controllerType);
          Reference targetElementRef = new Reference("targetElement");
          VariableDefinitionStatement varDef = packageBuilder.createVariableDefinition(
              packageBuilder.createReferenceExpression(ModelCompiler.CONTROLLER_VARIABLE_NAME,
              controllerType), packageBuilder.createNewObjectExpression(controllerType,
              new Expression[] {targetElementRef}));
          controller = varDef.getReference();
          chromeMethod.addStatement(varDef);
          TypeToken controllerClass = TypeToken.fromClass(Controller.class);
          chromeMethod.addStatement(new ExpressionStatement(
              packageBuilder.createStaticMethodCall(controllerClass, "setTargetController",
              new Expression[] {targetElementRef, controller})));
        }
      }
    }
  }

  /**
   * Creates a unique method name for chrome element.
   */
  private String createChromeMethodName(String id) {
    return "create" + id.substring(0, 1).toUpperCase() + id.substring(1);
  }

  /**
   * Reads Chrome properties collection and converts property settings to
   * statements in the createElementsMethod.
   */
  private void readChromeProperties(Model propertiesNode, TypeToken chromeTargetType,
      CodeBlock codeBlock) {
    int childCount = propertiesNode.getChildCount();
    if (childCount != 0) {
      // Convert from UIElement to chrome target type:
      //     var target:ChromeTargetType = ChromeTargetType(targetElement)
      packageBuilder.addImport(chromeTargetType);
      codeBlock.addStatement(packageBuilder.createVariableDefinition(
          packageBuilder.createReferenceExpression(CHROME_TARGET_VAR_NAME,
          chromeTargetType), packageBuilder.createTypeCast(chromeTargetType,
          new Reference(CHROME_METHOD_TARGET_PARAM_NAME))));
    }
    for (int c = 0; c < childCount; ++c) {
      Model child = propertiesNode.getChild(c);
      if (child.getTypeName().equals(CHROME_CHILD_PROPERTY)) {
        readChromeProperty(child, chromeTargetType, codeBlock);
      } else {
        addError(new CompilerError(child.getLineNumber(),
            child.getColumn(), ERROR_MSG_INVALID_PROPERTIES_CHILD));
      }
    }
  }

  /**
   * Reads a single property node and generates code in createElements of chrome
   * to set value of target type.
   */
  private void readChromeProperty(Model propertyNode, TypeToken chromeTargetType,
      CodeBlock codeBlock) {
    if (!propertyNode.hasProperty("name")) {
      addError(new CompilerError(propertyNode.getLineNumber(),
          propertyNode.getColumn(), ERROR_MSG_MISSING_PROPERTY_NAME));
      return;
    }

    String propertyName = propertyNode.getStringProperty("name");

    PropertyDefinition propDef = modelReflector.getPropDef(chromeTargetType, propertyName);
    if (propDef == null) {
      addError(new CompilerError(propertyNode.getLineNumber(), propertyNode.getColumn(),
          String.format("Unknown property '%s' of element type '%s'", propertyName,
              chromeTargetType.getFullName())));
      return;
    }

    Class< ? > dataType = propDef.getDataType();
    TypeToken propTypeToken = modelCompiler.elementTypeToToken(dataType.getSimpleName());
    if (propTypeToken != null) {
      packageBuilder.addImport(propTypeToken);
    }

    CodeSerializer serializer = packageBuilder.getSerializer(TypeToken.fromClass(dataType));

    // The value of the property either is specified as attribute or
    // childnode.
    Expression propertyValueExpr = null;
    Reference chromeTargetReference = new Reference(CHROME_TARGET_VAR_NAME);
    if (propertyNode.hasProperty("value")) {
      Object propVal = propertyNode.getStringProperty("value");
      String propStrVal = (String) propVal;
      if (serializer != null) {
        propertyValueExpr = serializer.createExpression(propStrVal, modelCompiler, codeBlock);
      } else {
        if (!propStrVal.startsWith("{")) {
          // simple string value.
          propertyValueExpr = packageBuilder.createStringLiteralExpression((String) propVal);
        } else {
          // Resolve binding
          ModelProperty targetProp = new ModelProperty(propertyName, propStrVal);
          Expression resourceExpr = modelCompiler.expressionFromResource(targetProp, propertyNode,
              codeBlock);
          if (resourceExpr != null) {
            codeBlock.addStatement(modelCompiler.generateSetPropertyOnObject(
                chromeTargetReference, targetProp, resourceExpr));
          }
          return;
        }
      }
    }

    // Skip expression if propertyValue serializer failed (error reported).
    // Otherwise set the property value on the object.
    PropertyData defaultPropData = (propDef == null) ? null : propDef.getDefaultPropData();
    TypeToken propertyOwnerClass = TypeToken.fromClass(defaultPropData.getOwnerClass());
    packageBuilder.addImport(propertyOwnerClass);
    Expression getPropDefExpression = packageBuilder.createGetStaticFieldExpression(
        propertyOwnerClass, propertyName +
        packageBuilder.getPropertyDefPostFix());
    if (propertyValueExpr == null) {
      if (propertyNode.getChildCount() == 0) {
        addError(new CompilerError(propertyNode.getLineNumber(), propertyNode.getColumn(),
            ERROR_MSG_MISSING_PROPERTY_VALUE));
      } else {
        // Convert Model object to temp var and assign
        propertyValueExpr = modelCompiler.readChildNode(propertyNode.getChild(0), codeBlock);
      }
    }
    TypeToken chromeType = TypeToken.fromClass(Chrome.class);
    packageBuilder.addImport(chromeType);
    Expression applyPropExpression = packageBuilder.createStaticMethodCall(
        chromeType, "applyProperty", new Expression[] {
            chromeTargetReference, getPropDefExpression, propertyValueExpr
        });
    codeBlock.addStatement(new ExpressionStatement(applyPropExpression));
  }

  private void compileEventBindings(List<ModelEventBinding> chromeEventBindings) {
    if (chromeEventBindings == null) {
      // No bindings.
      return;
    }
    TypeToken controllerType = TypeToken.fromClass(Controller.class);
    TypeToken eventArgsType = TypeToken.fromClass(EventArgs.class);
    for (ModelEventBinding binding : modelCompiler.chromeEventBindings) {

      MethodBuilder closure = packageBuilder.createClosure(TypeToken.VOID);
      Reference eArgsRef = new Reference("e", eventArgsType);
      closure.addParameter(new MethodParameter(eArgsRef));
      EventDefinition eventDef = binding.getProperty().getEventDef();
      // Add event owner type, for example CheckBox.click requires Button type
      TypeToken eventOwnerType = TypeToken.fromClass(eventDef.getOwnerType());
      packageBuilder.addImport(eventOwnerType);

      String eventName = eventDef.getName().substring(0, 1).toLowerCase()
          + eventDef.getName().substring(1) + "Event";
      Expression eventDefExpr = packageBuilder.createGetFieldExpression(
          new Reference(eventDef.getOwnerType().getSimpleName()), eventName);

      String eventHandlerName = (String) binding.getProperty().getValue();

      ResourceInfo resInfo = modelCompiler.getResourceInfo(eventHandlerName);
      if (resInfo != null) {
        packageBuilder.addImport(eventArgsType);
        // Create a static execute call to CommandOwner.commandId.execute(e, params).
        Expression executeExpr  = packageBuilder.createMethodCall(
            resInfo.getReference(), "execute", new Expression[] {
            eArgsRef, eArgsRef});
        closure.addStatement(new ExpressionStatement(executeExpr));

        // Add source.addListener(eventDef, closure)
        MethodCall bindingCall = packageBuilder.createMethodCall(binding.getSource(),
            "addListener", new Expression[] {eventDefExpr, closure});
        chromeMethod.addStatement(new ExpressionStatement(bindingCall));
      } else {
        packageBuilder.addImport(controllerType);
        packageBuilder.addImport(eventArgsType);
        BindingParser parser = new BindingParser(eventHandlerName, false);
        Expression controllerExpression;
        Expression controllerCall;
        // TODO(ferhat): remove check for JClosure.
        if (closure instanceof JClosure) {
          TypeToken appType = TypeToken.fromClass(Application.class);
          packageBuilder.addImport(appType);
          Expression appInstance = packageBuilder.createStaticMethodCall(appType, "getCurrent");
          controllerCall = packageBuilder.createMethodCall(appInstance, "callListener",
              new Expression[] {new Reference(CHROME_METHOD_TARGET_PARAM_NAME),
              packageBuilder.createStringLiteralExpression(eventHandlerName)});
        } else {
          if (parser.isData()) {
            controllerExpression  = packageBuilder.createGetPropertyExpression(
                binding.getSource(), "data");
            eventHandlerName = parser.getExpression();
          } else {
            controllerExpression  = packageBuilder.createStaticMethodCall(
                controllerType, "getTargetController", new Expression[] {
                    new Reference(CHROME_METHOD_TARGET_PARAM_NAME)});
          }
          controllerCall = packageBuilder.createDynamicCall(controllerExpression,
              eventHandlerName, new Expression[]{packageBuilder.createReferenceExpression("e",
              TypeToken.fromClass(EventArgs.class))}, closure);
        }
        closure.addStatement(new ExpressionStatement(controllerCall));
        // Add source.addListener(eventDef, closure)
        MethodCall bindingCall = packageBuilder.createMethodCall(binding.getSource(),
            "addListener", new Expression[] {eventDefExpr, closure});
        chromeMethod.addStatement(new ExpressionStatement(bindingCall));
      }
    }
  }

  /**
   * Adds error to compile-chain error collection.
   * @param error
   */
  private void addError(CompilerError error) {
    modelCompiler.addError(error);
  }

  /**
   * Returns id of chrome.
   */
  public String getId() {
    return chromeId;
  }

  /**
   * Returns key of chrome.
   */
  public Expression getKey() {
    return chromeKey;
  }
}
