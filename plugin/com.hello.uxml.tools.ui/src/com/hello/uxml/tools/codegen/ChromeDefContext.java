package com.hello.uxml.tools.codegen;

import com.hello.uxml.tools.framework.Controller;
import com.hello.uxml.tools.framework.events.EventArgs;
import com.hello.uxml.tools.codegen.emit.MethodBuilder;
import com.hello.uxml.tools.codegen.emit.PackageBuilder;
import com.hello.uxml.tools.codegen.emit.TypeToken;
import com.hello.uxml.tools.codegen.emit.expressions.Expression;
import com.hello.uxml.tools.codegen.emit.expressions.Reference;
import com.hello.uxml.tools.codegen.emit.expressions.VariableDefinitionStatement;

/**
 * Provides Chrome definition information for ModelCompiler so bindings to
 * chrome targets can be resolved.
 *
 * @author ferhat@
 */
public class ChromeDefContext {
  // Chrome id
  private String id;
  // Target type of chrome
  private TypeToken targetType;
  // Reference to variable holding chrome
  private Reference varReference;
  // Holds variable reference for shared targetController instance.
  private Reference sharedController = null;
  // Holds method reference to chrome apply function used to create shared
  // instances.
  private MethodBuilder methodBuilder;
  private boolean isReadingEffects = false;

  /**
   * Constructor.
   */
  public ChromeDefContext(String id, TypeToken targetType, Reference varReference,
      MethodBuilder methodBuilder) {
    this.id = id;
    this.targetType = targetType;
    this.varReference = varReference;
    this.methodBuilder = methodBuilder;
  }

  /**
   * Returns id.
   */
  public String getId() {
    return id;
  }

  /**
   * Returns target type of chrome.
   */
  public TypeToken getTargetType() {
    return targetType;
  }

  /**
   * Returns reference to variable holding chrome instance.
   */
  public Reference getVarReference() {
    return varReference;
  }

  /**
   * Returns shared target controller to use for bindings.
   */
  public Expression requestTargetController() {
    if (sharedController == null) {
      PackageBuilder packageBuilder = methodBuilder.getClassBuilder().getPackage();
      TypeToken controllerType = TypeToken.fromClass(Controller.class);
      TypeToken eventArgsType = TypeToken.fromClass(EventArgs.class);
      packageBuilder.addImport(controllerType);
      packageBuilder.addImport(eventArgsType);
      Expression controllerExpr = packageBuilder.createTypeCast(controllerType,
          packageBuilder.createStaticMethodCall(controllerType,
              "getTargetController", new Expression[] {new Reference("targetElement")}));
      String varName = methodBuilder.getNameGenerator().createVariableName("controller");
      VariableDefinitionStatement varDef = packageBuilder.createVariableDefinition(
          packageBuilder.createReferenceExpression(varName, TypeToken.OBJECT), controllerExpr);
      methodBuilder.addStatement(varDef);
      sharedController = varDef.getReference();
    }
    return sharedController;
  }

  /**
   * Sets/returns isReadEffects state.
   */
  public void setIsReadingEffects(boolean value) {
    isReadingEffects = value;
  }

  public boolean getIsReadingEffects() {
    return isReadingEffects;
  }
}
