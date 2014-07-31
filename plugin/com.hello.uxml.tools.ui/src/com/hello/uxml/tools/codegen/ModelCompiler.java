package com.hello.uxml.tools.codegen;

import com.google.common.collect.Lists;
import com.google.common.collect.Maps;
import com.google.common.collect.Sets;
import com.hello.uxml.tools.framework.Application;
import com.hello.uxml.tools.framework.Command;
import com.hello.uxml.tools.framework.Controller;
import com.hello.uxml.tools.framework.OverlayContainer;
import com.hello.uxml.tools.framework.PropertyBinding;
import com.hello.uxml.tools.framework.PropertyData;
import com.hello.uxml.tools.framework.PropertyDefinition;
import com.hello.uxml.tools.framework.PropertyFlags;
import com.hello.uxml.tools.framework.UIElement;
import com.hello.uxml.tools.framework.UxmlElement;
import com.hello.uxml.tools.framework.effects.Effect;
import com.hello.uxml.tools.framework.events.EventArgs;
import com.hello.uxml.tools.framework.events.EventDefinition;
import com.hello.uxml.tools.framework.graphics.Brush;
import com.hello.uxml.tools.codegen.dom.ContentNodeType;
import com.hello.uxml.tools.codegen.dom.Model;
import com.hello.uxml.tools.codegen.dom.ModelCollectionProperty;
import com.hello.uxml.tools.codegen.dom.ModelProperty;
import com.hello.uxml.tools.codegen.dom.ModelReflector;
import com.hello.uxml.tools.codegen.dom.ScopeTree;
import com.hello.uxml.tools.codegen.emit.ClassBuilder;
import com.hello.uxml.tools.codegen.emit.CodeModelSerializer;
import com.hello.uxml.tools.codegen.emit.CodeSerializer;
import com.hello.uxml.tools.codegen.emit.FieldAttributes;
import com.hello.uxml.tools.codegen.emit.FieldBuilder;
import com.hello.uxml.tools.codegen.emit.IBindingContext;
import com.hello.uxml.tools.codegen.emit.MemberScope;
import com.hello.uxml.tools.codegen.emit.MethodBuilder;
import com.hello.uxml.tools.codegen.emit.MethodParameter;
import com.hello.uxml.tools.codegen.emit.PackageBuilder;
import com.hello.uxml.tools.codegen.emit.TypeToken;
import com.hello.uxml.tools.codegen.emit.dart.DartPackageBuilder;
import com.hello.uxml.tools.codegen.emit.expressions.AssignmentExpression;
import com.hello.uxml.tools.codegen.emit.expressions.AssignmentExpression.AssignmentExpressionType;
import com.hello.uxml.tools.codegen.emit.expressions.CodeBlock;
import com.hello.uxml.tools.codegen.emit.expressions.CommentStatement;
import com.hello.uxml.tools.codegen.emit.expressions.Condition;
import com.hello.uxml.tools.codegen.emit.expressions.EqualityExpression;
import com.hello.uxml.tools.codegen.emit.expressions.Expression;
import com.hello.uxml.tools.codegen.emit.expressions.ExpressionStatement;
import com.hello.uxml.tools.codegen.emit.expressions.IfStatement;
import com.hello.uxml.tools.codegen.emit.expressions.MethodCall;
import com.hello.uxml.tools.codegen.emit.expressions.NullLiteralExpression;
import com.hello.uxml.tools.codegen.emit.expressions.Reference;
import com.hello.uxml.tools.codegen.emit.expressions.Statement;
import com.hello.uxml.tools.codegen.emit.expressions.StringLiteralExpression;
import com.hello.uxml.tools.codegen.emit.expressions.VariableDefinitionStatement;

import java.util.EnumSet;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.Stack;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Emits class contents from a root model item.
 *
 * @author ferhat
 */
public class ModelCompiler implements IBindingContext {

  /** Resources element name */
  private static final String RESOURCES_NODE_NAME = "Resources";
  private static final String INTERFACE_NODE_NAME = "Interface";
  private static final String CONST_NODE_NAME = "Const";
  private static final String LOCALIZATION_BUNDLE_NODE_NAME = "localizationbundle";
  private static final String COMPONENT_NODE_NAME = "Component";
  private static final String ROOT_ELEMENT_CLASSNAME_ATTRIBUTE = "name";
  private static final String ROOT_ELEMENT_VERSION_ATTRIBUTE = "version";
  private static final String CONTENT_PROPERTY = "content";
  private static final String CHROME_METHOD_TARGET_PARAM_NAME = "targetElement";
  private static final String ID_ATTRIBUTE = "id";
  private static final String VALUE_ATTRIBUTE = "value";
  private static final String NAME_ATTRIBUTE = "name";
  private static final String TYPE_ATTRIBUTE = "type";

  private static final String EFFECT_TAG_NAME = "Effect";
  private static final String EFFECTS_VAR_NAME = "effects";
  private static final String EFFECT_PROPERTY_ATTRIBUTE = "property";

  private static final String ERROR_MSG_EXPECTING_EFFECT_TAG =
    "Expecting Effect tag";
  private static final String ERROR_MSG_MISSING_EFFECT_PROPERTY_ATTR =
    "Effect is missing property attribute";
  private static final String INIT_METHOD_NAME = "init";

  // Special resource elements
  /** Import element name */
  public static final String RESOURCE_TYPE_IMPORT = "Import";
  private static final String RESOURCE_TYPE_IMPLEMENTS = "Implements";
  private static final String RESOURCE_TYPE_ALIAS = "Alias";
  public static final String CONTROLLER_VARIABLE_NAME = "controller";
  private static final String ALIAS_ELEMENT_NAME = "Alias";
  private static final String RESOURCE_PREFIX = "resource.";

  private static Application compileApp;
  private static final Logger logger = Logger.getLogger(ModelCompiler.class.getName());

  // Holds ids we have reported as 'unknown id' to aggregate errors.
  private Set<String> idErrors = Sets.newHashSet();

  /** Root of markup tree */
  private Model modelRoot;

  /** Target class builder */
  private ClassBuilder classBuilder;

  /** Target package builder */
  private PackageBuilder packageBuilder;

  /** Target error collection */
  private List<CompilerError> errors;

  /** Model reflector for introspection */
  private ModelReflector modelReflector;

  /** Maps resource name defined locally to ResourceInfo */
  private Map<String, ResourceInfo> localResources = Maps.newHashMap();

  /** Maps resource name to ResourceInfo for imported resources */
  private Map<String, ResourceInfo> importedResourceLookup = Maps.newHashMap();

  /** Maps resource name to ResourceInfo for interface resources */
  private Map<String, ResourceInfo> interfaceResourceLookup = Maps.newHashMap();

  /** Maps resource id names in current file (non-imported) to Model */
  private Map<String, Model> localIds = Maps.newHashMap();

  private List<ModelInterface> implementedInterfaces = Lists.newArrayList();

  /** List of property bindings for chrome */
  public List<ModelPropertyBinding> chromePropertyBindings;

  /** List of event bindings for chrome element*/
  public List<ModelEventBinding> chromeEventBindings;

  /** List of element to element property bindings */
  private List<ModelPropertyBinding> propertyBindings;

  /** List of event bindings to be attached after controller declaration */
  private List<ModelEventBinding> eventBindings;

  /** data type of root element */
  private TypeToken rootType = null;

  /** reusable chrome compiler, allocated on first chrome resource definition*/
  private ChromeCompiler chromeCompiler = null;

  /** Property definition context stack */
  private Stack<PropertyDefinitionContext> propDefContext =
      new Stack<PropertyDefinitionContext>();

  /** Scope tree used to resolve binding ids and target/source to type mapping */
  private ScopeTree scopeTree;

  /** Import uxml service for resource definitions*/
  private IUXMLImporter importer;

  /** Set if class has controller */
  private boolean hasController;
  /** Reference to controller object. */
  private Reference controller;

  /** Name of source file used to annotate errors. **/
  private String sourceName;

  /** Compiler configuration */
  private Configuration targetConfig;

  /** holds localization table from xlb files. */
  private Map<String, Model> locaTable = new HashMap<String, Model>();

  /**
   * Stack of chrome elements in current compile tree. Used to resolve bindings
   * to chrome targets.
   */
  private Stack<ChromeDefContext> chromeDefContext = new Stack<ChromeDefContext>();

  private static final String[] CONST_TYPE_NAMES = new String[] {
      "int", "num", "bool", "string", "String"};
  private static final TypeToken[] CONST_TYPE_TOKENS = new TypeToken[] {
      TypeToken.INT32, TypeToken.NUMBER, TypeToken.BOOLEAN, TypeToken.STRING, TypeToken.STRING};
  private static final String DEFAULT_CONST_TYPE = "num";

  /**
   * Constructor.
   */
  public ModelCompiler(Model htsModel, ClassBuilder classBuilder, ModelReflector modelReflector,
      List<CompilerError> errors, IUXMLImporter importer, Configuration targetConfig) {
    this.modelRoot = htsModel;
    this.classBuilder = classBuilder;
    this.packageBuilder = classBuilder.getPackage();
    this.modelReflector = modelReflector;
    this.errors = errors;
    this.importer = importer;
    this.targetConfig = targetConfig;
    hasController = modelRoot.hasProperty(CONTROLLER_VARIABLE_NAME);
    initEnv();
  }

  // TODO(ferhat): update tests and deprecate targetConfig=null case.
  public ModelCompiler(Model htsModel, ClassBuilder classBuilder, ModelReflector modelReflector,
      List<CompilerError> errors, IUXMLImporter importer) {
    this(htsModel, classBuilder, modelReflector, errors, importer, null);
  }

  /**
   * Initializes application environment for model compiler.
   */
  public static void initEnv() {
    if (compileApp == null) {
      compileApp = new CompileApp();
      compileApp.verifyClassLoaded(OverlayContainer.class);
    }
  }

  /**
   * Sets name of source file.
   */
  public void setSourceName(String value) {
    sourceName = value;
  }

  /**
   * Constructor.
   */
  public ModelCompiler(Model htsModel, ClassBuilder classBuilder, ModelReflector modelReflector,
        List<CompilerError> errors) {
    this(htsModel, classBuilder, modelReflector, errors, null);
  }
  /**
   * Read model, write to classbuilder.
   */
  public boolean compile() {
    // Prepare array to hold event bindings for postprocessing
    eventBindings = Lists.newArrayList();
    propertyBindings = Lists.newArrayList();

    // Read all ids and report duplicates
    scopeTree = new ScopeTree(modelRoot);
    List<Model> duplicateIdNodes = scopeTree.getDuplicateIdNodes();
    if (!duplicateIdNodes.isEmpty()) {
      for (Model node : duplicateIdNodes) {
        addError(ErrorCode.DUPLICATE_ELEMENT_ID, node);
      }
    }

    // Ready to compile model
    MethodBuilder initMethod = compileRoot();
    if (initMethod != null) {
      compilePropertyBindings(initMethod);
      compileEventBindings(controller, initMethod);
    }

    if (initMethod != null) {
      CodeBlock initBlock = new CodeBlock(initMethod);
      // Read properties of root element.
      readProperties(modelRoot, packageBuilder.createSelfReferenceExpression(), initBlock);
      initMethod.add(initBlock);
    }

    // Generate code to call controller.initCompleted after view is ready.
    if (hasController) {
      Expression callCompleteCall = packageBuilder.createMethodCall(
          new Reference(CONTROLLER_VARIABLE_NAME), "initCompleted");
      initMethod.addStatement(new ExpressionStatement(callCompleteCall));
    }

    // Finally verify that all implemented interface members are defined.
    for (int i = 0; i < implementedInterfaces.size(); i++) {
      ModelInterface iModel = implementedInterfaces.get(i);
      iModel.verifyMembers(modelRoot, importedResourceLookup, errors);
    }

    for (int errorIndex = 0; errorIndex < errors.size(); errorIndex++) {
      if (errors.get(errorIndex).getSeverity().equals(Severity.CRITICAL)) {
        return false;
      }
    }
    return true;
  }

  /**
   * Setup base class for root (typically application / container / resources element).
   */
  private void setupRootClass() {
    String rootTypeName = modelRoot.getTypeName();
    if (rootTypeName == COMPONENT_NODE_NAME) {
      if (!modelRoot.hasProperty(TYPE_ATTRIBUTE)) {
        addError(ErrorCode.EXPECTING_COMPONENT_TYPE, modelRoot);
        return;
      }
      String typeName = modelRoot.getStringProperty(TYPE_ATTRIBUTE);
      TypeToken componentType = TypeToken.fromFullName(typeName);
      packageBuilder.addImport(componentType);
      classBuilder.setBaseClass(componentType);
      rootType = elementTypeToToken(rootTypeName);
    } else {
      if ((rootTypeName != null) && (!rootTypeName.equals(""))) {
        rootType = elementTypeToToken(rootTypeName);
        if (rootType == null) {
          addError(ErrorCode.INVALID_ROOT_ELEMENT,
              String.format(ErrorCode.INVALID_ROOT_ELEMENT.getFormat(), rootTypeName),
              modelRoot);
        } else {
          packageBuilder.addImport(rootType);
          classBuilder.setBaseClass(rootType);
        }
      }
    }
  }

  public TypeToken elementTypeToToken(String elementTypeName) {
    return modelReflector.elementTypeToToken(elementTypeName);
  }

  private MethodBuilder compileRoot() {
    int childCount = modelRoot.getChildCount();
    boolean resourceNodeProcessed = false; // makes sure we read a single resources node.

    setupRootClass();

    // If we have children or a controller to setup, we should create a constructor to
    // build up content.
    boolean needsCtorForProperties = (modelRoot.getPropertyCount() > 1) ||
        (((modelRoot.getPropertyCount() == 1) && (!modelRoot.hasProperty("name"))));
    MethodBuilder ctor = ((childCount != 0) || needsCtorForProperties || hasController) ?
        classBuilder.createDefaultConstructor() : null;

    MethodBuilder initMethod = null;
    if (ctor != null) {
      initMethod = classBuilder.createMethod(INIT_METHOD_NAME, TypeToken.VOID);
      initMethod.setScope(MemberScope.PROTECTED);
      ctor.addStatement(new ExpressionStatement(
          new MethodCall(packageBuilder.createSelfReferenceExpression(), INIT_METHOD_NAME)));
      controller = setupRootController(initMethod);
    }

    String rootTypeName = modelRoot.getTypeName();
    if (rootTypeName.equals("Resources")) {
      // Read resource only hts file.
      if (childCount != 0) {
        CodeBlock resourceBlock = new CodeBlock(initMethod);
        readResources(modelRoot, resourceBlock, packageBuilder.createSelfReferenceExpression());
        initMethod.add(resourceBlock);
      }
    } else if (rootTypeName.equals("Interface")) {
      // nothing to do since we don't generate code for interface.
      return null;
    } else {
      // Read regular hts file.
      for (int childIndex = 0; childIndex < childCount; ++childIndex) {
        Model child = modelRoot.getChild(childIndex);
        String elementType = child.getTypeName();
        if (elementType.equals(RESOURCES_NODE_NAME)) {
          if (resourceNodeProcessed) {
            addError(ErrorCode.EXPECTING_SINGLE_RESOURCES, child);
          }
          CodeBlock initBlock = new CodeBlock(initMethod);
          readClassResources(child, initBlock);
          initMethod.add(initBlock);
          resourceNodeProcessed = true;
        } else {
          CodeBlock initBlock = new CodeBlock(initMethod);
          Expression childExp = readChildNode(child, initBlock);
          initMethod.add(initBlock);

          // Set content of parent element or add to logical child collection
          if (rootType != null) {

            // Convert root type to non  platform specific version to resolve contentNode.
            if (rootType.getName().endsWith("Application")) {
              rootType = TypeToken.fromFullName(Application.class.getName());
            }
            Statement stmt = createContentNodeStatement(child, rootType,
                packageBuilder.createSelfReferenceExpression(), childExp);
            if (stmt != null) {
              initMethod.addStatement(stmt);
            }
          }
        }
      }
    }
    return initMethod;
  }

  /**
   * Creates code to instantiate controller class for the view model.
   * @return Reference to controller definition or null if root element doesn't
   * define a controller.
   */
  private Reference setupRootController(MethodBuilder initMethod) {

    // Setup controller for root
    String controllerVarName = "";
    if (modelRoot.hasProperty(CONTROLLER_VARIABLE_NAME)) {
      String rootControllerTypeName = modelRoot.getStringProperty(CONTROLLER_VARIABLE_NAME);
      if (rootControllerTypeName != null) {
        TypeToken rootControllerType = TypeToken.fromFullName(rootControllerTypeName);
        packageBuilder.addImport(rootControllerType);
        controllerVarName = CONTROLLER_VARIABLE_NAME;
        classBuilder.createField(new Reference(controllerVarName, rootControllerType), EnumSet.of(
            FieldAttributes.Public));
        controller = new Reference(controllerVarName);
        initMethod.addStatement(new ExpressionStatement(new AssignmentExpression(controller,
                packageBuilder.createNewObjectExpression(rootControllerType,
                new Expression[] {packageBuilder.createSelfReferenceExpression()}),
                AssignmentExpressionType.REGULAR)));
      }
    }
    return controller;
  }

  /**
   * Create code for eventbindings.
   */
  private void compileEventBindings(Expression controllerExpr, MethodBuilder initMethod) {
    // Attach events
    for (ModelEventBinding binding : eventBindings) {
      compileEventBinding(binding, controllerExpr, initMethod);
    }
  }

  /**
   * Create event listener code for event binding.
   */
  public void compileEventBinding(ModelEventBinding binding, Expression controllerExpr,
      MethodBuilder method) {

    EventDefinition eventDef = binding.getProperty().getEventDef();

    // Add event owner type, for example CheckBox.click requires Button type
    TypeToken eventOwnerType = TypeToken.fromClass(eventDef.getOwnerType());
    packageBuilder.addImport(eventOwnerType);

    // Create expression that references event. Example: Button.clickEvent
    String eventName = eventDef.getName().substring(0, 1).toLowerCase()
        + eventDef.getName().substring(1) + "Event";
    Expression eventDefExpr = packageBuilder.createGetFieldExpression(
        new Reference(eventDef.getOwnerType().getSimpleName()), eventName);
    TypeToken eventArgsType = TypeToken.fromClass(EventArgs.class);

    // Check if event handler is a command resource.
    if (binding.getProperty().getValue() instanceof String) {
      String commandResName = (String) binding.getProperty().getValue();
      ResourceInfo resInfo = getResourceInfo(commandResName);
      if (resInfo != null) {
        MethodBuilder closure = packageBuilder.createClosure(TypeToken.VOID);
        packageBuilder.addImport(eventArgsType);
        Reference eArgsRef = new Reference("e", eventArgsType);
        closure.addParameter(new MethodParameter(eArgsRef));
        Expression methodRef = null;
        if (localResources.containsKey(resInfo)) {
          // Create a static execute call to commandId.execute(e, params).
          methodRef = resInfo.getReference();
        } else {
          // Create a static execute call with class name of imported id.
          // Commands.commandId.execute(e, params).
          TypeToken resourceOwnerType = resolveResourceOwnerType(resInfo);
          methodRef = packageBuilder.createGetStaticFieldExpression(resourceOwnerType,
              resInfo.id);
        }
        // Check if command has a method reference. If might be null if its from an import.
        if (methodRef == null) {
          methodRef = new Reference(resInfo.getId(), TypeToken.fromClass(Command.class));
        }
        Expression executeExpr  = packageBuilder.createMethodCall(
            methodRef, "execute", new Expression[] {
            eArgsRef, eArgsRef});
        closure.addStatement(new ExpressionStatement(executeExpr));

        // Add source.addListener(eventDef, closure)
        MethodCall bindingCall = packageBuilder.createMethodCall(binding.getSource(),
            "addListener", new Expression[] {eventDefExpr, closure});
        method.addStatement(new ExpressionStatement(bindingCall));
        return;
      }
    }

    // Check if markup has a controller defined.
    if (controllerExpr != null) {
      Expression delegateExpr = packageBuilder.createDelegate(
          controllerExpr, (String) binding.getProperty().getValue());
      // Add listener for the event.
      // Example: checkbox1.addListener(Button.clickEvent, delegateFunc);
      MethodCall bindingCall = packageBuilder.createMethodCall(binding.getSource(),
          "addListener", new Expression[] {eventDefExpr, delegateExpr});
      method.addStatement(new ExpressionStatement(bindingCall));
    } else {
      // No controller, so we need to create expression to call getTargetController
      // to use attached/inherited controller value.
      TypeToken controllerType = TypeToken.fromClass(Controller.class);
      packageBuilder.addImport(controllerType);
      packageBuilder.addImport(eventArgsType);

      MethodBuilder closure = packageBuilder.createClosure(TypeToken.VOID);
      closure.addParameter(new MethodParameter(new Reference("e", eventArgsType)));

      String eventHandlerName = (String) binding.getProperty().getValue();
      BindingParser parser = new BindingParser(eventHandlerName, false);
      Expression controllerExpression;
      if (parser.isData()) {
        // We are calling a function defined as a member of data model.
        controllerExpression  = packageBuilder.createGetPropertyExpression(
            binding.getSource(), "data");
        eventHandlerName = parser.getExpression();
      } else {
        // Default to controller.
          controllerExpression  = packageBuilder.createStaticMethodCall(
            controllerType, "getTargetController", new Expression[] {
            binding.getSource()});
      }
      Expression controllerCall = packageBuilder.createMethodCall(controllerExpression,
          eventHandlerName, new Expression[]{new Reference("e")});
      closure.addStatement(new ExpressionStatement(controllerCall));

      // Add source.addListener(eventDef, closure)
      MethodCall bindingCall = packageBuilder.createMethodCall(binding.getSource(),
          "addListener", new Expression[] {eventDefExpr, closure});
      method.addStatement(new ExpressionStatement(bindingCall));
    }
  }

  /**
   * Create code for property to property bindings.
   */
  private void compilePropertyBindings(MethodBuilder method) {
    for (ModelPropertyBinding bind : propertyBindings) {
      Expression bindingCollectionExpr = packageBuilder.createGetPropertyExpression(
          bind.getTargetBindingsCollection(), "bindings");
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
      TypeToken propertyBindingType = TypeToken.fromClass(PropertyBinding.class);
      packageBuilder.addImport(TypeToken.fromClass(PropertyBinding.class));
      Expression bindingExpr = packageBuilder.createNewObjectExpression(propertyBindingType,
          bindingParameters);
      method.addStatement(packageBuilder.createCollectionAddStatement(
          bindingCollectionExpr, bindingExpr));
    }
  }

  /**
   * Creates code that takes the child element and adds it to the logical child
   * collection of the parent by either setting a field or calling a collection add
   * method.
   */
  public Statement createContentNodeStatement(Model parentNode, TypeToken parentType,
      Expression parentExpr, Expression childElementReference) {

    ContentNodeType nodeType = modelReflector.getContentNodeType(parentType);
    switch (nodeType) {
      case None:
        addError(ErrorCode.CHILD_ELEMENTS_NOT_SUPPORTED, String.format(
            ErrorCode.CHILD_ELEMENTS_NOT_SUPPORTED.getFormat(), parentType.getName()), parentNode);
        break;
      case CollectionMethod:
        MethodCall addChildCall = packageBuilder.createMethodCall(
            parentExpr,
            modelReflector.getContentNodeName(parentType),
            new Expression[] {childElementReference});
        return new ExpressionStatement(addChildCall);
      case Field:
        Expression setPropertyExpr = packageBuilder.createSetPropertyExpression(
            parentExpr,
            modelReflector.getContentNodeName(parentType),
            childElementReference);
        return new ExpressionStatement(setPropertyExpr);
      default:
        throw new AssertionError("Unsupported ContentNodeType: " + nodeType);
    } // end switch nodeType
    return null;
  }

  /**
   * Builds an id to Model map of all resources.
   */
  private void readResourceIds(Model resourcesNode) {
    int resourceCount = resourcesNode.getChildCount();
    for (int r = 0; r < resourceCount; ++r) {
      Model resourceNode = resourcesNode.getChild(r);
      if (resourceNode.hasProperty(ID_ATTRIBUTE)) {
        localIds.put(resourceNode.getStringProperty(ID_ATTRIBUTE),
            resourceNode);
      }
    }
  }

  /**
   * Read resources, generate public static field declarations and add items
   * to resources collection on the class.
   */
  private void readClassResources(Model resourcesNode, CodeBlock codeBlock) {

    // Create code for this.getResources()
    Expression getResourcesExpr = packageBuilder.createGetPropertyExpression(
        packageBuilder.createSelfReferenceExpression(), "resources");
    readResources(resourcesNode, codeBlock, getResourcesExpr);
  }

  /**
   * Read resources and add to resources collection.
   */
  private void readResources(Model resourcesNode, CodeBlock codeBlock,
      Expression resourcesCollectionExpr) {

    readResourceIds(resourcesNode);

    Model resourceNode;
    int childCount = resourcesNode.getChildCount();
    int resourceCount = 0;
    int interfaceCount = 0;
    String resourceType;

    // Process import and implements directives.
    for (int r = 0; r < childCount; ++r) {
      resourceNode = resourcesNode.getChild(r);
      resourceType = resourceNode.getTypeName();
      if (resourceType.equals(RESOURCE_TYPE_IMPORT)) {
        // Uncomment block below to disable nested imports.
        // TODO(ferhat):removes this after final decision on infinite nesting
        // if (modelRoot.getTypeName().equals("Resources")) {
        //   addError(ErrorCode.NESTED_IMPORTS_NOT_SUPPORTED, resourceNode);
        // } else {
        if (!resourceNode.hasProperty("path")) {
          addError(ErrorCode.EXPECTING_PATH_ATTRIBUTE, resourceNode);
        } else {
          String resourcePath = resourceNode.getStringProperty("path");
          importResourceFile(resourcePath, resourceNode);
        }
      } else if (resourceType.equals(RESOURCE_TYPE_IMPLEMENTS)) {
        if (interfaceCount == 0) {
          codeBlock.addStatement(new CommentStatement("Implemented Interfaces"));
        }
        ++interfaceCount;
        readInterfaceResource(resourceNode, codeBlock);
      } else {
        ++resourceCount;
      }
    }

    // Create resources section.
    if (resourceCount != 0) {
      if (codeBlock != null) {
        codeBlock.addStatement(new CommentStatement("Resources"));
      }
    }
    for (int resIndex = 0; resIndex < childCount; ++resIndex) {
      resourceNode = resourcesNode.getChild(resIndex);
      resourceType = resourceNode.getTypeName();
      if (resourceType.equals(RESOURCE_TYPE_IMPORT) ||
          resourceType.equals(RESOURCE_TYPE_IMPLEMENTS)) {
        continue;
      }

      if (resourceType.equals(RESOURCE_TYPE_ALIAS)) {
        readAlias(resourceNode, codeBlock, resourcesCollectionExpr);
        continue;
      }
      // Create code for Element resourceDef = new ....
      ResourceInfo resource = readResource(resourceNode, codeBlock);
      if (resource == null) {
        continue;
      }
      // Call .addChild(resourceDef) on resources.
      MethodCall addChildExpression = packageBuilder.createMethodCall(resourcesCollectionExpr,
          "add", new Expression[] {resource.getKey(), resource.getReference()});
      codeBlock.addStatement(packageBuilder.createExpressionStatement(addChildExpression));
    }
  }

  private void readInterfaceResource(Model resourceNode, CodeBlock codeBlock) {
    if (!resourceNode.hasProperty("path")) {
      addError(ErrorCode.EXPECTING_PATH_ATTRIBUTE, resourceNode);
      return;
    }
    String htsPath = resourceNode.getStringProperty("path");
    Model resourceModel = importer.importModel(htsPath, errors);
    if (resourceModel == null) {
      String importPath = "";
      if (targetConfig.getImportPaths() != null) {
        for (String p : targetConfig.getImportPaths()) {
          importPath += p + "+";
        }
      }
      addError(ErrorCode.FILE_NOT_FOUND, htsPath + " imports= " + importPath, resourceNode);
      return;
    }
    ModelInterface iModel = new ModelInterface(resourceModel);
    implementedInterfaces.add(iModel);
    MethodCall addChildExpression = packageBuilder.createMethodCall(
        packageBuilder.createSelfReferenceExpression(),
        "add", new Expression[] {packageBuilder.createStringLiteralExpression(iModel.getName()),
        packageBuilder.createSelfReferenceExpression()});
    codeBlock.addStatement(packageBuilder.createExpressionStatement(addChildExpression));
  }

  private void readAlias(Model aliasNode, CodeBlock codeBlock,
      Expression resourcesCollectionExpr) {
    if (!aliasNode.hasProperty("id")) {
      addError(ErrorCode.EXPECTING_RESOURCE_ID, aliasNode);
      return;
    }
    String aliasName = aliasNode.getStringProperty("id");
    if (!aliasNode.hasProperty("link")) {
      addError(ErrorCode.EXPECTING_ALIAS_LINK, aliasNode);
    }
    String linkName = aliasNode.getStringProperty("link");
    String bindSource = linkName.substring(1, linkName.length() - 1).trim();
    Expression linkReference = getResourceBindingExpression(bindSource);
    if (linkReference == null) {
      if ((getResourceInfo(linkName) == null) ||
          (getResourceInfo(linkName).getInterface() == null)) {
        addError(ErrorCode.EXPECTING_LINK_NOT_FOUND, aliasNode);
      } else {
        addError(ErrorCode.CANNOT_ALIAS_INTERFACE_MEMBER, aliasNode);
      }
      return;
    }

    ResourceInfo resInfo = getResourceInfo(linkName);
    if (resInfo == null) {
      addError(ErrorCode.EXPECTING_LINK_NOT_FOUND, aliasNode);
      return;
    }
    TypeToken resourceType = modelReflector.elementTypeToToken(resInfo.getModel().getTypeName());
    Reference varReference = createResourceDefinition(aliasName, resourceType,
        linkReference, codeBlock, false);
    resInfo = new ResourceInfo(aliasName, packageBuilder.createStringLiteralExpression(aliasName),
        varReference, aliasNode);
    localResources.put(aliasName, resInfo);

    MethodCall addChildExpression = packageBuilder.createMethodCall(resourcesCollectionExpr,
        "add", new Expression[] {new StringLiteralExpression(aliasName), varReference});
    codeBlock.addStatement(packageBuilder.createExpressionStatement(addChildExpression));

  }

  private ResourceInfo readResource(Model resourceNode, CodeBlock codeBlock) {
    String typeName = resourceNode.getTypeName();
    if (typeName.equals(CONST_NODE_NAME)) {
      return readConstResource(resourceNode, codeBlock);
    }
    TypeToken type = elementTypeToToken(typeName);
    if (type == null) {
      addError(ErrorCode.UNRECOGNIZED_RESOURCE_TYPE, resourceNode);
      return null;
    } else {
      codeBlock.getFunction().getMethod().getClassBuilder().getPackage().addImport(type);
    }

    String id = null;
    ResourceInfo resInfo = null;

    if (typeName.equals("Chrome")) {
      if (chromeCompiler == null) {
        chromeCompiler = new ChromeCompiler(this);
      }
      if (chromePropertyBindings != null) {
        chromePropertyBindings.clear();
      }
      if (chromeEventBindings != null) {
        chromeEventBindings.clear();
      }
      Reference varReference = chromeCompiler.compile(resourceNode, codeBlock);
      if (varReference != null) {
        id = chromeCompiler.getId();
        resInfo = new ResourceInfo(id, chromeCompiler.getKey(),
            varReference, resourceNode);
      }
    } else {
      // Check for custom code serializer for his type (i.e. Color,primitives etc..)
      id = resourceNode.hasProperty(ID_ATTRIBUTE) ?
          resourceNode.getStringProperty(ID_ATTRIBUTE) : null;
      // TODO(ferhat): validate id syntax
      Reference varReference;
      CodeSerializer serializer = packageBuilder.getSerializer(type);
      Expression rhs; // Right hand side of field initializer expression
      if (id == null) {
        addError(ErrorCode.EXPECTING_RESOURCE_ID, resourceNode);
      } else {
        if ((serializer != null) && (serializer instanceof CodeModelSerializer)) {
          rhs = ((CodeModelSerializer) serializer).createExpression(resourceNode, this, codeBlock);
          varReference = createResourceDefinition(id, type, rhs, codeBlock, false);
          resInfo = new ResourceInfo(id, packageBuilder.createStringLiteralExpression(id),
              varReference, resourceNode);
        } else {
          // We don't have a custom code serializer so we should create new instance
          // of element and use it's reference.
          rhs = packageBuilder.createNewObjectExpression(type);
          varReference = createResourceDefinition(id, type, rhs, codeBlock, false);
          // Read node properties and create code to setup object.
          readProperties(resourceNode, varReference, codeBlock);
          readChildren(resourceNode, varReference, codeBlock);
          resInfo = new ResourceInfo(id, packageBuilder.createStringLiteralExpression(id),
              varReference, resourceNode);
        }
      }
    }

    // Add resource to lookup table if key'd by id.
    if (id != null && resInfo != null) {
      localResources.put(id, resInfo);
    }
    return resInfo;
  }

  private ResourceInfo readConstResource(Model resourceNode, CodeBlock codeBlock) {
    if (!resourceNode.hasProperty(ID_ATTRIBUTE)) {
      addError(ErrorCode.EXPECTING_RESOURCE_ID);
      return null;
    }
    String id = resourceNode.getStringProperty(ID_ATTRIBUTE);
    if (id == null) {
      addError(ErrorCode.EXPECTING_RESOURCE_ID);
      return null;
    }
    String valueStr = resourceNode.getStringProperty(VALUE_ATTRIBUTE);
    if (valueStr == null) {
      addError(ErrorCode.EXPECTING_CONST_VALUE);
      return null;
    }
    String typeName = DEFAULT_CONST_TYPE;
    if (resourceNode.hasProperty(TYPE_ATTRIBUTE)) {
      typeName = resourceNode.getStringProperty(TYPE_ATTRIBUTE);
    }
    int typeIndex = -1;
    TypeToken type = null;
    for (int i = 0; i < CONST_TYPE_NAMES.length; i++) {
      if (CONST_TYPE_NAMES[i].equals(typeName)) {
        typeIndex = i;
        type = CONST_TYPE_TOKENS[i];
        break;
      }
    }
    if (typeIndex == -1) {
      addError(ErrorCode.INVALID_CONST_TYPE_ATTRIBUTE);
      return null;
    }
    Expression rhs = null;
    if (type.equals(TypeToken.STRING)) {
      rhs = packageBuilder.createStringLiteralExpression(valueStr);
    } else {
      CodeSerializer serializer = packageBuilder.getSerializer(type);
      if (serializer != null) {
        rhs = serializer.createExpression(valueStr, this, codeBlock);
      }
    }
    if (rhs == null) {
      return null; // serialization failed and logged error.
    }
    Reference varReference = createResourceDefinition(id, type, rhs, codeBlock, true);
    ResourceInfo resInfo = new ResourceInfo(id, packageBuilder.createStringLiteralExpression(id),
        varReference, resourceNode);
    resInfo.isConst = true;
    // Add resource to lookup table if key'd by id.
    if (id != null && resInfo != null) {
      localResources.put(id, resInfo);
    }
    return resInfo;
  }

  private void importResourceFile(String relativePath, Model node) {
    List<CompilerError> importErrors = Lists.newArrayList();
    if (importer == null) {
      addError(ErrorCode.IMPORT_NOT_SUPPORTED);
      return;
    }
    Model importedModel = importer.importModel(relativePath, importErrors);
    if (importedModel == null) {
      String importPath = "";
      if (targetConfig.getImportPaths() != null) {
        for (String p : targetConfig.getImportPaths()) {
          importPath += p + "+";
        }
      }
      addError(ErrorCode.FILE_NOT_FOUND, relativePath + " imports= " + importPath, node);
      return;
    }
    String typeName = importedModel.getTypeName();
    if (typeName.equals(RESOURCES_NODE_NAME) || typeName.equals(INTERFACE_NODE_NAME)) {
      boolean isInterfaceResource = importedModel.getTypeName().equals(INTERFACE_NODE_NAME);

      for (int resIndex = 0; resIndex < importedModel.getChildCount(); ++resIndex) {
        Model resourceNode = importedModel.getChild(resIndex);
        if (resourceNode.hasProperty(ID_ATTRIBUTE)) {
          String id = resourceNode.getStringProperty(ID_ATTRIBUTE);
          // TODO(ferhat): validateIdSyntax
          ResourceInfo resInfo = new ResourceInfo(id,
              packageBuilder.createStringLiteralExpression(id), null, resourceNode);
          if (isInterfaceResource) {
            resInfo.setInterface(resourceNode.getParent().getStringProperty("name"));
            interfaceResourceLookup.put(id, resInfo);
          } else {
            // A resource might be defined both in interface and
            // a shared resource file. Don't add to both, interface takes precendence.
            if (!interfaceResourceLookup.containsKey(id)) {
              importedResourceLookup.put(id, resInfo);
            }
          }
        }
      }
    } else if (typeName.equals(LOCALIZATION_BUNDLE_NODE_NAME) &&
        (importedModel.getChildCount() != 0)) {
      // Read XLB localization bundle into locaTable.
      if (!node.hasProperty(TYPE_ATTRIBUTE)) {
        addError(ErrorCode.EXPECTING_LOCABUNDLE_TYPE, relativePath);
        return;
      }
      String locaTypeName = node.getStringProperty(TYPE_ATTRIBUTE);
      Model messages = importedModel.getChild(0);
      for (int resIndex = 0; resIndex < messages.getChildCount(); ++resIndex) {
        Model msgNode = messages.getChild(resIndex);
        if (msgNode.getTypeName().equals("msg")) {
          String id = msgNode.getStringProperty(NAME_ATTRIBUTE);
          msgNode.createProperty(TYPE_ATTRIBUTE, locaTypeName);
          locaTable.put(id, msgNode);
        }
      }
    }
  }

  /** Create a resource variable or field definition */
  private Reference createResourceDefinition(String id, TypeToken type, Expression initExpression,
      CodeBlock codeBlock, boolean isConst) {
    // If id == null create a local variable and return reference
    if (id == null) {
      id = codeBlock.createVariableName(type.getName());
      VariableDefinitionStatement varDef = packageBuilder.createVariableDefinition(
          packageBuilder.createReferenceExpression(id, type), initExpression);
      codeBlock.addStatement(varDef);
      return varDef.getReference();
    } else {
      // If id was provided, create a public class instance
      MethodBuilder method = codeBlock.getFunction().getMethod();
      ClassBuilder builder = method.getClassBuilder();
      FieldBuilder field;
      Reference varReference;
      if (isConst) {
        field = builder.createField(new Reference(id, type),
            EnumSet.of(FieldAttributes.Public, FieldAttributes.Static, FieldAttributes.Const),
            initExpression);
        return field.getReference();
      } else if (isStaticResourceType(type)) {
        field = builder.createField(new Reference(id, type),
            EnumSet.of(FieldAttributes.Public, FieldAttributes.Static),
            new NullLiteralExpression());
        varReference = field.getReference();
        AssignmentExpression assignmentExpression = new AssignmentExpression(varReference,
            initExpression, AssignmentExpressionType.REGULAR);

        // Generate if (staticRes != null) { staticRes = new ... }.
        Condition condition = new Condition(new EqualityExpression(new NullLiteralExpression(),
            varReference, false, false));
        CodeBlock thenBlock = new CodeBlock();
        thenBlock.addStatement(new ExpressionStatement(assignmentExpression));
        codeBlock.addStatement(new IfStatement(condition, thenBlock));
      } else {
        field = builder.createField(new Reference(id, type),
            EnumSet.of(FieldAttributes.Public));
        varReference = field.getReference();
        AssignmentExpression assignmentExpression = new AssignmentExpression(varReference,
            initExpression, AssignmentExpressionType.REGULAR);
        codeBlock.addStatement(new ExpressionStatement(assignmentExpression));

      }
      return varReference;
    }
  }

  private boolean isStaticResourceType(TypeToken type) {
    for (int i = 0; i < CONST_TYPE_TOKENS.length; i++) {
      if (type.equals(CONST_TYPE_TOKENS[i])) {
        return true;
      }
    }
    return type.equals(TypeToken.fromClass(Command.class));
  }

  /**
   * Read child node.
   *
   * The child should be declared locally if it has no id or as an instance
   * field on the class if it has a defined id. Depending on the data type of the
   * Content property of base class, we either call setContent() or addChild() on the
   * parent class.
   */
  public Expression readChildNode(Model childNode, CodeBlock codeBlock) {
    String typeName = childNode.getTypeName();
    TypeToken type = null;

    boolean isComponent = typeName.equals(COMPONENT_NODE_NAME);

    if (isComponent) {
      if (childNode.hasProperty(TYPE_ATTRIBUTE)) {
        String componentType = childNode.getStringProperty(TYPE_ATTRIBUTE);
        if (componentType.length() == 0) {
          addError(ErrorCode.EXPECTING_COMPONENT_TYPE, childNode);
          type = TypeToken.fromClass(UIElement.class);
        } else {
          type = TypeToken.fromFullName(componentType);
        }
      } else {
        addError(ErrorCode.EXPECTING_COMPONENT_TYPE, childNode);
      }
    } else {
      type = elementTypeToToken(typeName);
    }

    // Add import to element type.
    if (type == null) {
      type = elementTypeToToken(typeName);
      addError(ErrorCode.UNRECOGNIZED_ELEMENT_TAG,
          String.format(ErrorCode.UNRECOGNIZED_ELEMENT_TAG.getFormat(), typeName), childNode);
    } else {
      codeBlock.getFunction().getMethod().getClassBuilder().getPackage().addImport(type);
    }

    // Create variable name for id.
    String variableName;
    boolean hasId = false;
    if (childNode.hasProperty(ID_ATTRIBUTE)) {
      variableName = childNode.getStringProperty(ID_ATTRIBUTE);
      // TODO(ferhat): validate id syntax
      hasId = true;
    } else {
      variableName = codeBlock.createVariableName((type == null) ? typeName : type.getName());
    }

    // recover from unrecognized type error using Object type.
    if (type == null) {
      type = TypeToken.OBJECT;
    }

    CodeSerializer childSerializer = packageBuilder.getSerializer(type);
    if ((childSerializer != null) && (childSerializer instanceof CodeModelSerializer)) {
      // If we have a serializer for the type, use it to construct object (factories..).
      return ((CodeModelSerializer) childSerializer).createExpression(childNode, this, codeBlock);
    } else {
      Reference childReference;
      if (hasId && (chromeDefContext.isEmpty())) { // ids inside a chrome definition are local.
        childReference = createNewMemberObject(type, variableName, codeBlock);
      } else {
        // Create local variable to hold child element.
        childReference = createNewLocalObject(type, variableName, codeBlock);
      }

      // Read node properties and create code to setup object.
      readProperties(childNode, childReference, codeBlock);
      readChildren(childNode, childReference, codeBlock);

      if ((!chromeDefContext.isEmpty()) && packageBuilder.tokenTypeToString(type).equals(
          "ContentContainer")) {
        // If content container doesn't explicitely bind it's content property,
        // bind to chrome target.
        if (!childNode.hasProperty(CONTENT_PROPERTY)) {
          PropertyDefinition propDef = modelReflector.getPropDef(
              chromeDefContext.peek().getTargetType(), CONTENT_PROPERTY);
          if (propDef != null) { // If targetType of Chrome doesn't have content property ignore
            TypeToken ownerType = TypeToken.fromClass(propDef.getDefaultPropData().
                getOwnerClass());
            packageBuilder.addImport(ownerType);
            Expression contentPropDefExpression = createPropDefExpression(propDef);
            addChromeBinding(new ModelPropertyBinding(childReference, childReference,
                CONTENT_PROPERTY, new Reference(CHROME_METHOD_TARGET_PARAM_NAME),
                contentPropDefExpression));
          }
        }
      }
      return childReference;
    }
  }

  private void addChromeBinding(ModelPropertyBinding binding) {
    if (chromePropertyBindings == null) {
      chromePropertyBindings = Lists.newArrayList();
    }
    chromePropertyBindings.add(binding);
  }

  private void addChromeEventBinding(ModelEventBinding binding) {
    if (chromeEventBindings == null) {
      chromeEventBindings = Lists.newArrayList();
    }
    chromeEventBindings.add(binding);
  }

  public void pushContext(PropertyDefinitionContext context) {
    propDefContext.push(context);
  }

  public void popContext() {
    propDefContext.pop();
  }

  private PropertyDefinitionContext peekContext() {
    return propDefContext.isEmpty() ? null : propDefContext.peek();
  }

  // Reads group of children
  private void readChildren(Model parentNode, Reference varReference, CodeBlock codeBlock) {

    // Read children
    int childCount = parentNode.getChildCount();
    for (int c = 0; c < childCount; ++c) {
      Model child = parentNode.getChild(c);

      Expression childExp = readChildNode(child, codeBlock);
      if (childExp != null) {
        TypeToken parentType = elementTypeToToken(parentNode.getTypeName());
        // we need to check for null here since parent type might be invalid (although
        // still compiling to return as many compile errors as we can.
        if (parentType != null) {
          // Get method name from reflector using contentnode annotation and call.
          Statement addChildStatement = this.createContentNodeStatement(parentNode,
              parentType, varReference, childExp);
          if (addChildStatement != null) {
            codeBlock.addStatement(addChildStatement);
          }
        }
      }
    }
  }

  private void readProperties(Model modelNode, Reference varReference, CodeBlock codeBlock) {

    // Now set model properties of new object using.
    int propCount = modelNode.getPropertyCount();
    for (int p = 0; p < propCount; ++p) {
      ModelProperty prop = modelNode.getProperty(p);
      readProperty(modelNode, prop, varReference, codeBlock);
    }
  }

  /**
   * Reads a model property and generates code to assign value.
   * Values are:
   *   EventBindings
   *   Property children.
   *   PropDefs for Effect.property
   *   A Model object.
   *   Resource references
   *   Literal values
   * @param modelNode Owner of property to read.
   * @param prop Property to read.
   * @param varReference Reference to owner of property.
   * @param codeBlock Target code block to write instruction to.
   */
  private void readProperty(Model modelNode, ModelProperty prop, Reference varReference,
      CodeBlock codeBlock) {
    // For root object skip controller and name
    if ((modelNode == modelRoot) && ((prop.getName().equals(CONTROLLER_VARIABLE_NAME)) ||
        (prop.getName().equals(ROOT_ELEMENT_CLASSNAME_ATTRIBUTE)) ||
        (prop.getName().equals(ROOT_ELEMENT_VERSION_ATTRIBUTE)))) {
      return;
    }

    if (modelNode.getTypeName().equals(COMPONENT_NODE_NAME) &&
        prop.getName().equals(TYPE_ATTRIBUTE)) {
      return; // Dont' generate code for Component.type property.
    }

    // Check if attribute is an eventDef
    if (prop.getEventDef() != null) {
      if (!chromeDefContext.isEmpty()) {
        addChromeEventBinding(new ModelEventBinding(varReference, prop));
      } else {
        eventBindings.add(new ModelEventBinding(varReference, prop));
      }
      return;
    }

    // if the property is a ModelCollectionProperty, simply read child nodes
    // and generate code to add children to collection
    if (prop instanceof ModelCollectionProperty) {
      readModelCollection(modelNode, prop, varReference, codeBlock);
      return;
    }

    Class<?> propertyType = resolvePropertyDataType(modelNode, prop);
    if (propertyType == null) {
      addError(ErrorCode.UNKNOWN_PROPERTY, String.format(
          ErrorCode.UNKNOWN_PROPERTY.getFormat(), (String) prop.getValue()), modelNode);
      return;
    }

    // If property is of type PropertyDefinition, resolve the constant and
    // set propertyValueExpr to [someClass.somePropDef]
    if (propertyType == PropertyDefinition.class) {
      Model propertyDefSource = modelNode;
      if (propertyDefSource != null) {
        // Property is on the modelNode object.
        PropertyDefinition propDef = resolvePropertyName(propertyDefSource, prop);
        if (propDef == null) {
          propDef = resolvePropertyName(propertyDefSource, prop);
          addError(ErrorCode.UNKNOWN_PROPERTY, String.format(
              ErrorCode.UNKNOWN_PROPERTY.getFormat(), (String) prop.getValue()), modelNode);
        } else {
          packageBuilder.addImport(TypeToken.fromClass(
              propDef.getDefaultPropData().getOwnerClass()));
          Expression propDefValue = createPropDefExpression(propDef);
          codeBlock.addStatement(generateSetPropertyOnObject(varReference, prop, propDefValue));
          return;
        }
      }
    }

    // Ask for a serializer for the data type.
    CodeSerializer serializer = packageBuilder.getSerializer(TypeToken.fromClass(propertyType));
    Object propVal = prop.getValue();

    // Assignment of model to property
    if (!(propVal instanceof String)) {
      // Convert Model object to temp var and assign
      Expression rhs = readChildNode((Model) propVal, codeBlock);
      codeBlock.addStatement(generateSetPropertyOnObject(varReference, prop, rhs));
      return;
    }

    // Assignment of string value to property.
    String propStrVal = (String) (prop.getValue());

    // Check if code serializer can convert to value.
    if ((serializer != null) && serializer.canSerialize(propStrVal, this)) {
      Expression valueExpr = serializer.createExpression(propStrVal, this, codeBlock);
      codeBlock.addStatement(generateSetPropertyOnObject(varReference, prop, valueExpr));
      return;
    }

    // Check if string literal.
    if (!propStrVal.startsWith("{")) {
      // If binding expression doesn't start with brace, interpret as string value.
      Expression stringLiteral = localizeLiteralString(packageBuilder, propStrVal, modelNode);
      if (targetConfig != null && targetConfig.isLocalizationWarnEnabled() &&
          (stringLiteral instanceof StringLiteralExpression) &&
          propertyNeedsLocalization(modelNode, prop, propStrVal) &&
          (propStrVal.length() != 0)) {
        addWarning(ErrorCode.UNLOCALIZED_LITERAL, propStrVal, modelNode);
      }
      codeBlock.addStatement(generateSetPropertyOnObject(varReference, prop, stringLiteral));
      return;
    }

    // Resolve binding.
    String binding = (String) prop.getValue();
    BindingParser bindingParser = new BindingParser(binding);
    if (bindingParser.getResult() != ErrorCode.SUCCESS) {
      addError(bindingParser.getResult(), modelNode);
      return;
    }
    String bindingExpr = bindingParser.getExpression();
    String[] parts = bindingExpr.split("\\.");

    // Controller.a.b.c.
    if (bindingParser.isController()) {
      createControllerBinding(modelNode, prop, varReference, bindingParser);
      return;
    }

    // data.a.b.c.
    if (bindingParser.isData()) {
      createDataBinding(modelNode, prop, varReference, bindingParser);
      return;
    }

    if (bindingParser.isChromeTarget()) {
      if (!createChromePropertyBinding(varReference, prop, modelNode, codeBlock)) {
        addError(ErrorCode.CANT_FIND_BINDSOURCE,
            String.format(ErrorCode.CANT_FIND_BINDSOURCE.getFormat(), bindingExpr), modelNode);
      }
    }

    // check if first part of the property path is a valid element id in scope.
    String keyPrefix = parts[0];

    if (scopeTree != null) {
      Model sourceModel = this.scopeTree.resolveId(modelNode, keyPrefix);
      if (sourceModel != null && parts.length > 1) {
        createBindingToElement(modelNode, prop, varReference, bindingParser);
        return;
      }
    }

    // Resource binding.
    if (getResourceModel(binding) != null) {
      Expression resourceExpr = expressionFromResource(prop, modelNode, codeBlock);
      if (resourceExpr != null) {
        codeBlock.addStatement(generateSetPropertyOnObject(varReference, prop, resourceExpr));
      }
      return;
    }

    // Finally check if value is a valid chrome binding
    if (!createChromePropertyBinding(varReference, prop, modelNode, codeBlock)) {
      addError(ErrorCode.CANT_FIND_BINDSOURCE,
          String.format(ErrorCode.CANT_FIND_BINDSOURCE.getFormat(), bindingExpr), modelNode);
    }
  }


    private void readModelCollection(Model modelNode, ModelProperty prop, Reference varReference,
        CodeBlock codeBlock) {
      ModelCollectionProperty items = (ModelCollectionProperty) prop;

      TypeToken parentType = elementTypeToToken(modelNode.getTypeName());
      boolean fieldNeedsAllocation = modelReflector.isCollectionField(parentType, prop.getName())
          && (modelReflector.isCollectionFieldPreAllocated(parentType, prop.getName()) == false);

      Expression fieldReference;
      if (fieldNeedsAllocation) {
        TypeToken collectionType = TypeToken.fromClass(prop.getDataType());
        String varName = codeBlock.createVariableName(collectionType.getName());
        fieldReference = createNewLocalObject(collectionType, varName, codeBlock);
        packageBuilder.addImport(collectionType);
      } else {
        fieldReference = packageBuilder.createGetPropertyExpression(varReference, prop.getName());
      }

      for (int childIndex = 0; childIndex < items.getChildCount(); ++childIndex) {
        Model item = items.getChild(childIndex);
        if (item.getTypeName().equals(Effect.class.getSimpleName())) {
          PropertyDefinitionContext defContext = new PropertyDefinitionContext();
          TypeToken effectTargetType = elementTypeToToken(modelNode.getTypeName());
          defContext.addTag("Effect", effectTargetType, "source", "property", "value");
          defContext.addTag("PropertyAction", effectTargetType,
              "target", "property", "value");
          defContext.addTag("AnimateAction", effectTargetType,
              "target", "property", "toValue");
          pushContext(defContext);
          Expression effectsCollection = packageBuilder.createGetPropertyExpression(varReference,
              EFFECTS_VAR_NAME);
          readEffectNode(item, effectsCollection, varReference, effectTargetType, codeBlock);
          popContext();
        } else {
          Expression childExp = readChildNode(item, codeBlock);
          MethodCall addChildCall = packageBuilder.createMethodCall(
              fieldReference, "add", new Expression[] {childExp});
          codeBlock.addStatement(new ExpressionStatement(addChildCall));
        }
      }

      if (fieldNeedsAllocation) {
        codeBlock.addStatement(new ExpressionStatement(
            packageBuilder.createSetPropertyExpression(varReference, prop.getName(),
                fieldReference)));
      }
      return;
    }

  /**
   * Creates an expression that returns the resource at runtime.
   * @param prop Property to set.
   * @param modelNode Model node that owns property, only used for error reporting.
   * @param codeBlock Code block to use to create code in.
   */
  public Expression expressionFromResource(ModelProperty prop,
      Model modelNode, CodeBlock codeBlock) {
    Expression expr = null;

    String binding = (String) prop.getValue();
    BindingParser bindingParser = new BindingParser(binding);
    if (bindingParser.getResult() != ErrorCode.SUCCESS) {
      addError(bindingParser.getResult(),
          String.format(bindingParser.getResult().getFormat(), binding),
          modelNode);
    }
    String resourceName = bindingParser.getExpression();
    ResourceInfo resInfo = getResourceInfo(binding);
    if (resInfo == null) {
      // If there is not resInfo, we might have a resource that is not compiled yet,
      // but accessible through a local id in a chrome context.
      if ((!chromeDefContext.isEmpty()) && localIds.containsKey(resourceName)) {
        return new Reference(resourceName);
      }
      addError(ErrorCode.CANT_FIND_BINDSOURCE,
          String.format(ErrorCode.CANT_FIND_BINDSOURCE.getFormat(), binding));
      return null;
    }

    TypeToken resourceType = getResourceType(resInfo);
    CodeSerializer serializer = null;
    if (resourceType != null) {
      serializer = packageBuilder.getSerializer(resourceType);
    }
    if ((serializer != null) && (serializer instanceof CodeModelSerializer)) {
      expr = ((CodeModelSerializer) serializer).createExpression(resInfo.getModel(), this,
          codeBlock);
      return expr;
    }
    if (resInfo.getInterface() != null) {
      return createGetInterfaceResourceExpression(resInfo.getInterface(), resourceType,
          resourceName);
    }
    expr = getResourceBindingExpression(resourceName);
    if (expr == null) {
      addError(ErrorCode.CANT_FIND_BINDSOURCE,
          String.format(ErrorCode.CANT_FIND_BINDSOURCE.getFormat(), resourceName), modelNode);
    }
    // Cast result to property type if neccessary.
    if (prop.getDataType() != null) {
      TypeToken propType = TypeToken.fromClass(prop.getDataType());
      if (!propType.equals(expr.getType())) {
        if (!packageBuilder.normalizeType(propType).equals(
            packageBuilder.normalizeType(expr.getType()))) {
          packageBuilder.addImport(propType);
          expr = packageBuilder.createTypeCast(propType, expr);
        }
      }
    }
    return expr;
  }

  private TypeToken getResourceType(ResourceInfo resInfo) {
    TypeToken resourceType;
    String typeName = resInfo.getModel().getTypeName();
    if (typeName.equals(ALIAS_ELEMENT_NAME)) {
      ResourceInfo aliasedItem = getResourceInfo(resInfo.getModel().getStringProperty("link"));
      resourceType = elementTypeToToken(aliasedItem.getModel().getTypeName());
    } else {
      resourceType = elementTypeToToken(typeName);
    }
    if (resourceType == null) {
      addError(ErrorCode.UNKNOWN_RESOURCE_TYPE_NAME, typeName);
    }
    return resourceType;
  }

  /**
   * Returns expression to load resource from an interface.
   * @param interfaceName Name of interface.
   * @param dataType Data type of resource.
   * @param id Name of resource.
   * @return Expression to load resource.
   */
  public Expression createGetInterfaceResourceExpression(String interfaceName, TypeToken dataType,
      String id) {
    packageBuilder.addImport(dataType);
    Expression thisExpr;
    if (chromeDefContext.isEmpty() || chromeDefContext.peek().getIsReadingEffects()) {
      thisExpr = packageBuilder.createSelfReferenceExpression();
    } else {
      thisExpr = new Reference(ChromeCompiler.CHROME_METHOD_TARGET_PARAM_NAME);
    }
    Expression expr = packageBuilder.createMethodCall(thisExpr, "findResource",
        new Expression[] {new StringLiteralExpression(id),
            new StringLiteralExpression(interfaceName)});
    return packageBuilder.createTypeCast(dataType, expr);
  }

  private boolean createChromePropertyBinding(Reference ownerReference, ModelProperty property,
      Model modelNode, CodeBlock codeBlock) {
    String binding = (String) property.getValue();
    BindingParser bindingParser = new BindingParser(binding);
    if (bindingParser.getResult() != ErrorCode.SUCCESS) {
      addError(bindingParser.getResult(),
          String.format(bindingParser.getResult().getFormat(), binding),
          modelNode);
    }
    String bindingExpr = bindingParser.getExpression();
    String[] parts = bindingExpr.split("\\.");
    String keyPrefix = parts[0];
    ModelPropertyBinding modelBinding;
    // So the binding is of the form {property} or {elementid.property}
    // If chromeTargetType has the specified property, bind to it.
    if (!chromeDefContext.isEmpty()) {
      ChromeDefContext chromeDef = chromeDefContext.peek();
      if (modelReflector.hasProperty(chromeDef.getTargetType(), keyPrefix)) {
        PropertyDefinition propDef = modelReflector.getPropDef(chromeDef.getTargetType(),
            keyPrefix);
        if (parts.length == 1) {
          // If we can resolve the propdef, use that instead of string constant for
          // new PropertyBinding call.
          Expression bindingSourceExpr;
          if (propDef != null) {
              bindingSourceExpr = createPropDefExpression(propDef);
              TypeToken ownerType = TypeToken.fromClass(propDef.getDefaultPropData().
                  getOwnerClass());
              packageBuilder.addImport(ownerType);
          } else {
            bindingSourceExpr = new StringLiteralExpression(keyPrefix);
          }
          modelBinding = new ModelPropertyBinding(ownerReference,
              ownerReference, property.getName(), new Reference(CHROME_METHOD_TARGET_PARAM_NAME),
              bindingSourceExpr, bindingParser.getTransformClass(),
              bindingParser.getTransformFunction());
        } else {
          Expression[] chainExpression = new Expression[parts.length];
          for (int p = 1; p < parts.length; ++p) {
            chainExpression[p] = new StringLiteralExpression(parts[p]);
          }
          chainExpression[0] = createPropDefExpression(propDef);
          modelBinding = new ModelPropertyBinding(ownerReference,
              ownerReference, property.getName(), new Reference(CHROME_METHOD_TARGET_PARAM_NAME),
              chainExpression, bindingParser.getTransformClass(),
              bindingParser.getTransformFunction());
        }
        addChromeBinding(modelBinding);

        if (bindingParser.isTwoWay()) {
          Expression bindingTargetProperty;
          PropertyDefinition targetPropDef = modelReflector.getPropDef(
              modelReflector.elementTypeToToken(modelNode.getTypeName()), property.getName());
          if (targetPropDef != null) {
            bindingTargetProperty = createPropDefExpression(targetPropDef);
            packageBuilder.addImport(TypeToken.fromClass(
                targetPropDef.getDefaultPropData().getOwnerClass()));
            packageBuilder.addImport(TypeToken.fromClass(targetPropDef.getClass()));
          } else {
            bindingTargetProperty = new StringLiteralExpression(property.getName());
          }
          Reference targetRef = new Reference(CHROME_METHOD_TARGET_PARAM_NAME);
          addChromeBinding(new ModelPropertyBinding(targetRef,
              targetRef, bindingExpr,
              ownerReference, bindingTargetProperty,
              bindingParser.getRevTransformClass(),
              bindingParser.getRevTransformFunction()));
        }
        return true;
      }
    }
    return false;
  }

  /** Sets a property on targetObject */
  public Statement generateSetPropertyOnObject(Reference targetObject,
      ModelProperty prop, Expression propertyValueExpr) {
    // Create code to set the property value on the object.
    // If attached property, call setProperty method with propdef
    PropertyDefinition propDef = prop.getPropDef();
    PropertyData defaultPropData = (propDef == null)
    ? null : propDef.getDefaultPropData();
    if (defaultPropData != null && defaultPropData.getFlags().contains(
        PropertyFlags.Attached)) {
      packageBuilder.addImport(TypeToken.fromClass(defaultPropData.getOwnerClass()));
      Expression getPropDefExpression = packageBuilder.createGetStaticFieldExpression(
          TypeToken.fromClass(defaultPropData.getOwnerClass()), prop.getTargetName() +
          packageBuilder.getPropertyDefPostFix());
      MethodCall setPropertyCall = packageBuilder.createMethodCall(targetObject,
          "setProperty", new Expression[] {getPropDefExpression, propertyValueExpr});
      return new ExpressionStatement(setPropertyCall);
    } else {
      Expression setPropExpr = packageBuilder.createSetPropertyExpression(
          targetObject, prop.getTargetName(), propertyValueExpr);
      return new ExpressionStatement(setPropExpr);
    }
  }

  /**
   * Detects localization ids and returns assigned string value.
   * Example : %LOCALID=literal string syntax
   */
  private Expression localizeLiteralString(PackageBuilder packageBuilder, String str,
      Model refNode) {
    // Check if package overrides default implementation.
    Expression expr = packageBuilder.localizeLiteralString(str);
    if (expr != null) {
      return expr;
    }
    if (str.startsWith("%%")) {
      str = str.substring(1);
    } else if (str.startsWith("%")) {
      int pos = str.indexOf('=');
      if (pos == -1) {
        addError(ErrorCode.INVALID_LOCALIZATION_SYNTAX, str, refNode);
      } else {
        String localizationId = str.substring(1, pos);
        if (!locaTable.containsKey(localizationId)) {
          addError(ErrorCode.UNKNOWN_LOCALIZATION_ID, str, refNode);
        } else {
          Model msgNode = locaTable.get(localizationId);
          TypeToken bundleType = TypeToken.fromFullName(msgNode.getStringProperty(TYPE_ATTRIBUTE));
          packageBuilder.addImport(bundleType);
          return packageBuilder.createStaticMethodCall(bundleType, "getMsg", new Expression[] {
              packageBuilder.createGetStaticFieldExpression(bundleType, localizationId)});
        }
      }
    }
    return packageBuilder.createStringLiteralExpression(str);
  }

  /**
   * Creates a property binding to controller.
   */
  private void createControllerBinding(Model bindingOwner, ModelProperty prop,
      Reference varReference, BindingParser bindingParser) {
    String bindingExpr = bindingParser.getExpression();
    String[] parts = bindingExpr.split("\\.");
    ModelPropertyBinding modelBinding = null;
    ModelPropertyBinding modelBindingReverse = null; // for two way

    Expression[] chainExpression = new Expression[parts.length];
    for (int p = 0; p < parts.length; ++p) {
      chainExpression[p] = new StringLiteralExpression(parts[p]);
    }
    Expression controllerRef;
    if (!chromeDefContext.isEmpty()) {
      // No controller, so we need to change chain to access control.controller.foo
      controllerRef = chromeDefContext.peek().requestTargetController();
      chainExpression = new Expression[parts.length + 1];
      for (int part = 0; part < parts.length; ++part) {
        chainExpression[part + 1] = new StringLiteralExpression(parts[part]);
      }
      chainExpression[0] = new StringLiteralExpression(BindingParser.CONTROLLER_KEYWORD);
      modelBinding = new ModelPropertyBinding(varReference, varReference,
          prop.getTargetName(), varReference,  chainExpression,
          bindingParser.getTransformClass(), bindingParser.getTransformFunction(),
          bindingParser.getTransformArg());
    } else {
      // TODO(ferhat): remove special case when actionscript code is changed
      // and controller.primitive bindings are deprecated.
      if (packageBuilder instanceof DartPackageBuilder) {
        controllerRef = new Reference(BindingParser.CONTROLLER_KEYWORD + "." + parts[0]);
        Expression[] chain = new Expression[parts.length - 1];
        for (int p = 1; p < parts.length; ++p) {
          chain[p - 1] = new StringLiteralExpression(parts[p]);
        }
        modelBinding = new ModelPropertyBinding(varReference, varReference,
            prop.getTargetName(), controllerRef,  chain,
            bindingParser.getTransformClass(), bindingParser.getTransformFunction(),
            bindingParser.getTransformArg());
      } else {
        controllerRef = new Reference(BindingParser.CONTROLLER_KEYWORD);
        modelBinding = new ModelPropertyBinding(varReference, varReference,
            prop.getTargetName(), controllerRef,  chainExpression,
            bindingParser.getTransformClass(), bindingParser.getTransformFunction(),
            bindingParser.getTransformArg());
      }
    }

    if (bindingParser.isTwoWay()) {
      if (controllerRef instanceof Reference) {
        if (packageBuilder instanceof DartPackageBuilder && (parts.length >= 2)) {
          StringBuilder chain = new StringBuilder(parts[1]);
          for (int p = 2; p < (parts.length - 1); ++p) {
            chain.append("." + parts[p]);
          }
          modelBindingReverse = new ModelPropertyBinding(varReference,
              (Reference) controllerRef, chain.toString(), varReference,
              new StringLiteralExpression(prop.getTargetName()),
              bindingParser.getRevTransformClass(),
              bindingParser.getRevTransformFunction(),
              bindingParser.getTransformArg());
        } else {
          modelBindingReverse = new ModelPropertyBinding((Reference) controllerRef,
              (Reference) controllerRef, bindingExpr, varReference,
              new StringLiteralExpression(prop.getTargetName()),
              bindingParser.getRevTransformClass(),
              bindingParser.getRevTransformFunction(),
              bindingParser.getTransformArg());
        }
      } else {
        // Binding inside chrome to {controller.foo:two} is not allowed.
        addError(ErrorCode.INVALID_BINDTYPE);
      }
    }
    addBinding(modelBinding, modelBindingReverse);
  }

  private void addBinding(ModelPropertyBinding modelBinding,
      ModelPropertyBinding modelBindingReverse) {
    if (modelBinding != null) {
      if (!chromeDefContext.isEmpty()) {
        addChromeBinding(modelBinding);
        if (modelBindingReverse != null) {
          addChromeBinding(modelBindingReverse);
        }
      } else {
        propertyBindings.add(modelBinding);
        if (modelBindingReverse != null) {
          propertyBindings.add(modelBindingReverse);
        }
      }
    }
  }

  private void createDataBinding(Model bindingOwner, ModelProperty prop,
      Reference varReference, BindingParser bindingParser) {
    String bindingExpr = bindingParser.getExpression();
    String[] parts = bindingExpr.split("\\.");
    ModelPropertyBinding modelBinding = null;
    ModelPropertyBinding modelBindingReverse = null; // for two way
    String[] dataParts = bindingExpr.split("\\.");
    Expression[] sourceChainExpression = new Expression[dataParts.length + 1];
    sourceChainExpression[0] = createPropDefExpression(UxmlElement.dataPropDef);
    for (int partIndex = 0; partIndex < dataParts.length; ++partIndex) {
        sourceChainExpression[partIndex + 1] =
          new StringLiteralExpression(dataParts[partIndex]);
    }
    modelBinding = new ModelPropertyBinding(varReference, varReference,
        prop.getTargetName(), varReference, sourceChainExpression,
        bindingParser.getTransformClass(), bindingParser.getTransformFunction(),
        bindingParser.getTransformArg());
    if (bindingParser.isTwoWay()) {
      StringBuilder target = new StringBuilder(BindingParser.CONTROLLER_KEYWORD);
      for (int p = 0; p < (parts.length - 1); ++p) {
        target.append("." + parts[p]);
      }
      modelBindingReverse = new ModelPropertyBinding(
          varReference, varReference, "data." + bindingExpr,
          varReference, new StringLiteralExpression(prop.getTargetName()),
          bindingParser.getRevTransformClass(),
          bindingParser.getRevTransformFunction(),
          bindingParser.getTransformArg());
    }
    packageBuilder.addImport(TypeToken.fromClass(UxmlElement.class));
    addBinding(modelBinding, modelBindingReverse);
  }

  private void createBindingToElement(Model bindingOwner, ModelProperty prop,
      Reference varReference, BindingParser bindingParser) {
    String bindingExpr = bindingParser.getExpression();
    String[] parts = bindingExpr.split("\\.");
    ModelPropertyBinding modelBinding = null;
    ModelPropertyBinding modelBindingReverse = null; // for two way

    // We have a dynamic binding of the form {element.property}.
    Model sourceModel = this.scopeTree.resolveId(bindingOwner, parts[0]);
    if (sourceModel == null) {
      reportUnknownId(bindingExpr, bindingOwner);
      return;
    }

    String sourceModelId = sourceModel.getStringProperty(ID_ATTRIBUTE);
    Reference sourceRef;
    if (sourceModel.equals(modelRoot)) {
      // We have rootElementId.property , so use 'this' as destination reference
      sourceRef = packageBuilder.createSelfReferenceExpression();
    } else {
       // We have elementid.property, so use reference to local variable holding instance
      sourceRef = new Reference(sourceModelId);
    }

    if (parts.length == 1) {
      // directly binding to element.
      addError(ErrorCode.INVALID_BINDING_SYNTAX, "Direct binding to element not supported yet.",
          sourceModel);
      return;
    }

    // elementId.a.b.c binding.
    // Create propdef reference for binding
    StringBuilder sourcePath = new StringBuilder();
    for (int p = 1; p < parts.length; ++p) {
      if (p != 1) {
        sourcePath.append(".");
      }
      sourcePath.append(parts[p]);
    }
    Expression source = null;
    Expression[] sourceChain = null;
    PropertyDefinition propDef = resolvePropDefForBinding(sourceModel,
        sourcePath.toString());
    if (propDef != null) {
      source = createPropDefExpression(propDef);
    } else {
      PropertyDefinition potentialAttached = resolvePropDefForBinding(
          sourceModel.getParent(), sourcePath.toString());
      if ((potentialAttached != null) &&
          potentialAttached.getDefaultPropData().getAttached()) {
        propDef = potentialAttached;
        source = createPropDefExpression(propDef);
      } else {
        // Not propDef, not attached propdef. In that case take the
        // sourcePath parts and place it in an array as bindSource.
        sourceChain = new Expression[parts.length - 1];
        for (int p = 1; p < parts.length; ++p) {
          sourceChain[p - 1] = packageBuilder.createStringLiteralExpression(parts[p]);
        }
      }
    }

    if (source != null) {
      modelBinding = new ModelPropertyBinding(varReference, varReference,
          prop.getTargetName(), sourceRef, source,
          bindingParser.getTransformClass(), bindingParser.getTransformFunction(),
          bindingParser.getTransformArg());
      if (bindingParser.isTwoWay()) {
        modelBindingReverse = new ModelPropertyBinding(sourceRef,
            sourceRef, prop.getTargetName(), varReference,
            new StringLiteralExpression(prop.getTargetName()),
            bindingParser.getRevTransformClass(),
            bindingParser.getRevTransformFunction(),
            bindingParser.getTransformArg());
      }
    } else {
      modelBinding = new ModelPropertyBinding(varReference, varReference,
          prop.getTargetName(), sourceRef, sourceChain,
          bindingParser.getTransformClass(), bindingParser.getTransformFunction(),
          bindingParser.getTransformArg());
      if (bindingParser.isTwoWay()) {
        modelBindingReverse = new ModelPropertyBinding(sourceRef,
            sourceRef, prop.getTargetName(), varReference,
            new StringLiteralExpression(prop.getTargetName()),
            bindingParser.getRevTransformClass(),
            bindingParser.getRevTransformFunction(),
            bindingParser.getTransformArg());
      }
    }
    addBinding(modelBinding, modelBindingReverse);
  }

  /**
   * Returns data type of property.
   */
  private Class<?> resolvePropertyDataType(Model modelNode, ModelProperty prop) {
    Class<?> propertyType = null;

    // Check propdef context , in case this property is a propdef or value node
    PropertyDefinitionContext context = peekContext();
    if (context != null) {
      PropertyDefinitionContext.PropDefInfo propDefInfo = context.getPropertyDefinition(
          modelNode.getTypeName());
      if (propDefInfo != null) {
        String propertyName = prop.getName();
        TypeToken ownerType = propDefInfo.getTargetType();
        String targetPropertyName = propDefInfo.getTargetAttributeName();
        if (modelNode.hasProperty(targetPropertyName)) {
          String targetId = modelNode.getStringProperty(targetPropertyName);
          ownerType = resolveOwnerTypeFromId(modelNode, targetId);
          if (ownerType == null) {
            reportUnknownId(targetId, modelNode);
            return null;
          }
        }

        if (propertyName.equals(propDefInfo.getPropertyAttributeName())) {
          packageBuilder.addImport(ownerType);
          return PropertyDefinition.class;
        } else if (propertyName.equals(propDefInfo.getValueAttributeName())) {
          // To translate the string value correctly (since it's of type Object)
          // we look at the property name and ownertype to get it's propertydefinition
          // first and then use that data type to generate code.
          if (!modelNode.hasProperty(propDefInfo.getPropertyAttributeName())) {
            addError(ErrorCode.EXPECTING_PROPERTYATTRIBUTE, modelNode);
            return null;
          }
          String actualPropertyName = modelNode.getStringProperty(
              propDefInfo.getPropertyAttributeName());
          packageBuilder.addImport(ownerType);

          PropertyDefinition propDef = modelReflector.getPropDef(ownerType, actualPropertyName);
          if (propDef == null) {
            boolean isAttached = false;
            if (modelNode.hasProperty(targetPropertyName)) {
              String targetId = modelNode.getStringProperty(targetPropertyName);
              ownerType = resolveOwnerTypeFromId(modelNode, targetId);

              // check for attached property.
              Model targetNode = scopeTree.resolveId(modelNode, targetId);
              PropertyDefinition potentialAttached = null;
              if (targetNode.getParent() != null) {
                potentialAttached = resolvePropDefForBinding(
                    targetNode.getParent(), actualPropertyName);
              }
              if ((potentialAttached != null) &&
                  potentialAttached.getDefaultPropData().getAttached()) {
                isAttached = true;
                propDef = potentialAttached;
              }
            }
            if (!isAttached) {
              addError(ErrorCode.UNKNOWN_PROPERTY, String.format(
                  ErrorCode.UNKNOWN_PROPERTY.getFormat(), actualPropertyName), modelNode);
              return null;
            }
          }
          propertyType = propDef.getDataType();
        }
      }
    }
    if (propertyType == null) {
      if (prop.getPropDef() != null) {
        propertyType = prop.getPropDef().getDataType();
      } else {
        if (prop.getDataType() == null) {
          TypeToken nodeType = elementTypeToToken(modelNode.getTypeName());
          if (nodeType != null) {
            propertyType = modelReflector.getDataType(nodeType, prop.getName());
          }
        } else {
          propertyType = prop.getDataType();
        }
      }
    }
    return propertyType;
  }

  /**
   * Resolves property definition for a ModelProperty that holds a property name.
   * <p>Determines what ownerType the property belongs too by checking the
   * PropertyDefinition context. Typically a chrome definition will push a
   * context for Property and Effect nodes so the correct target can be resolved.
   */
  private PropertyDefinition resolvePropertyName(Model modelNode, ModelProperty prop) {

    // If we have an attribute of type PropertyDefinition , we just want
    // to set the value to the static propdef declared on the ownertype(class)
    PropertyDefinitionContext context = peekContext();
    if (context == null) {
      String msg = String.format("Parent type %s , property %s",
          modelNode.getParent().getTypeName(), prop.getName());
      addError(ErrorCode.INVALID_PARENT_CONTEXT, msg, modelNode.getParent());
      return null;
    }
    PropertyDefinitionContext.PropDefInfo propDefInfo = context.getPropertyDefinition(
        modelNode.getTypeName());
    if (propDefInfo != null) {
      TypeToken ownerType = propDefInfo.getTargetType();
      String targetPropertyName = propDefInfo.getTargetAttributeName();
      if (modelNode.hasProperty(targetPropertyName)) {
        String targetId = modelNode.getStringProperty(targetPropertyName);
        ownerType = resolveOwnerTypeFromId(modelNode, targetId);
        PropertyDefinition propDef = modelReflector.getPropDef(ownerType, (String) prop.getValue());
        if (propDef != null) {
          return propDef;
        }

        // prop.getValue might be an attached property
        Model targetNode = scopeTree.resolveId(modelNode, targetId);
        PropertyDefinition potentialAttached = null;
        if (targetNode.getParent() != null) {
          potentialAttached = resolvePropDefForBinding(targetNode.getParent(),
            (String) prop.getValue());
        }
        if ((potentialAttached != null) && potentialAttached.getDefaultPropData().getAttached()) {
          return potentialAttached;
        }
      }
      return modelReflector.getPropDef(ownerType, (String) prop.getValue());
    }
    return null;
  }

  /**
   * Returns PropertyDefinition for a property name to use for binding.
   */
  private PropertyDefinition resolvePropDefForBinding(Model modelNode, String propertyName) {
    TypeToken ownerType = modelReflector.elementTypeToToken(modelNode.getTypeName());
    return modelReflector.getPropDef(ownerType, propertyName);
  }

  /**
   * Returns owner type from id.
   * <p>Example: "myButton.transform" will return Transform type token.
   */
  private TypeToken resolveOwnerTypeFromId(Model referenceNode, String targetId) {
    if (targetId.indexOf('.') == -1) {
      Model targetNode = scopeTree.resolveId(referenceNode, targetId);
      if (targetNode == null) {
        reportUnknownId(targetId, referenceNode);
        return null;
      } else {
        return elementTypeToToken(targetNode.getTypeName());
      }
    } else {
      String[] targetChain = targetId.split("\\.");
      Model targetNode = scopeTree.resolveId(referenceNode, targetChain[0]);
      if (targetNode == null) {
        reportUnknownId(targetId, referenceNode);
        return null;
      }
      TypeToken ownerType = elementTypeToToken(targetNode.getTypeName());
      for (int i = 1; i < targetChain.length; ++i) {
        PropertyDefinition propDef = modelReflector.getPropDef(ownerType, targetChain[i]);
        if (propDef == null) {
          addError(ErrorCode.UNKNOWN_ELEMENT_ID_IN_TARGET);
          return null;
        }
        ownerType = TypeToken.fromClass(propDef.getDataType());
      }
      return ownerType;
    }
  }

  /**
   * Creates a property definition expression (UIElement.visiblePropDef).
   */
  private Expression createPropDefExpression(PropertyDefinition propDef) {
    String propDefName = propDef.getName().substring(0, 1).toLowerCase() +
        propDef.getName().substring(1) + packageBuilder.getPropertyDefPostFix();
    packageBuilder.addImport(TypeToken.fromClass(
        propDef.getDefaultPropData().getOwnerClass()));
    return packageBuilder.createGetStaticFieldExpression(
        TypeToken.fromClass(propDef.getDefaultPropData().getOwnerClass()),
        propDefName);
  }

  /**
   * Creates a local variable and assigns a new instance of the given type to it.
   * @param type Type to instantiate
   * @param variableName Local name
   * @return reference to the local variable
   */
  private Reference createNewLocalObject(TypeToken type, String variableName,
      CodeBlock codeBlock) {
    packageBuilder.addImport(type);
    Expression expr = packageBuilder.createNewObjectExpression(type);
    VariableDefinitionStatement varDef = packageBuilder.createVariableDefinition(
        packageBuilder.createReferenceExpression(variableName, type), expr);
    codeBlock.addStatement(varDef);
    return varDef.getReference();
  }

  /**
   * Creates a class member variable and assigns a new instance of the given type to it.
   * @param type Type to instantiate
   * @param variableName Local name
   * @return reference to the local variable
   */
  private Reference createNewMemberObject(TypeToken type, String variableName,
      CodeBlock codeBlock) {
    packageBuilder.addImport(type);
    Expression expr = packageBuilder.createNewObjectExpression(type);
    Reference fieldRef = classBuilder.createField(new Reference(variableName, type),
        EnumSet.of(FieldAttributes.Public)).getReference();
    Statement stmt = new ExpressionStatement(new AssignmentExpression(fieldRef, expr,
        AssignmentExpressionType.REGULAR));
    codeBlock.addStatement(stmt);
    return fieldRef;
  }

  /**
   * Returns Model of resource given a bindingExpression (IBindingContext).
   * If the resource doesn't exist returns null;
   */
  @Override
  public Model getResourceModel(String bindingExpression) {
    String bindSource = bindingExpression.substring(1, bindingExpression.length() - 1).trim();
    if (bindSource.startsWith(RESOURCE_PREFIX)) {
      bindSource = bindSource.substring(RESOURCE_PREFIX.length());
    }
    if (localResources.containsKey(bindSource)) {
      ResourceInfo resInfo = localResources.get(bindSource);
      return resInfo.getModel();
    } else if (importedResourceLookup.containsKey(bindSource)) {
      return importedResourceLookup.get(bindSource).getModel();
    } else if (interfaceResourceLookup.containsKey(bindSource)) {
      return interfaceResourceLookup.get(bindSource).getModel();
    } else if (localIds.containsKey(bindSource)) {
      return localIds.get(bindSource);
    }
    return null;
  }

  /**
   * Returns ResourceInfo given a bindingExpression (IBindingContext).
   */
  public ResourceInfo getResourceInfo(String bindingExpression) {
    String bindSource = bindingExpression.substring(1, bindingExpression.length() - 1).trim();
    if (localResources.containsKey(bindSource)) {
      return localResources.get(bindSource);
    } else if (interfaceResourceLookup.containsKey(bindSource)) {
      return interfaceResourceLookup.get(bindSource);
    } else if (importedResourceLookup.containsKey(bindSource)) {
      return importedResourceLookup.get(bindSource);
    }
    return null;
  }

  /**
   * Returns true if binding source is defined in interface.
   */
  public boolean isBindingSourceInterface(String bindingExpression) {
    if (localResources.containsKey(bindingExpression)) {
      return false;
    }
    return interfaceResourceLookup.containsKey(bindingExpression);
  }

  /**
   * Returns Reference to an object specified through a bindingExpression (IBindingContext).
   */
  public Expression getBindingExpression(String bindingExpression) {
    String bindSource = bindingExpression.substring(1, bindingExpression.length() - 1);
    Expression resourceExpression = getResourceBindingExpression(bindSource);
    if (resourceExpression != null) {
      return resourceExpression;
    }
    addError(ErrorCode.CANT_FIND_BINDSOURCE,
        String.format(ErrorCode.CANT_FIND_BINDSOURCE.getFormat(), bindSource));
    return null;
  }

  /**
   * Returns true if the bindingexpression resolves to a resource.
   */
  public boolean isValidBindingExpression(String bindingExpression) {
    String bindSource = bindingExpression.substring(1, bindingExpression.length() - 1);
    Expression resourceExpression = getResourceBindingExpression(bindSource);
    return  (resourceExpression != null);
  }

  /**
   * Reads effect tags and adds them to chrome effects collection.
   * @param effectsNode Effects element
   * @param ownerReference Variable reference to UIElement or chrome instance.
   * @param ownerType Element type of chrome that owns effects collection.
   */
  public void readEffects(Model effectsNode, Reference ownerReference,
      TypeToken ownerType, CodeBlock codeBlock) {
    int childCount = effectsNode.getChildCount();
    TypeToken effectType = TypeToken.fromClass(Effect.class);
    if (childCount != 0) {
      packageBuilder.addImport(effectType);
    }
    Expression effectsCollection = packageBuilder.createGetPropertyExpression(ownerReference,
        EFFECTS_VAR_NAME);
    for (int c = 0; c < childCount; ++c) {
      Model effectNode = effectsNode.getChild(c);
      readEffectNode(effectNode, effectsCollection, ownerReference, ownerType, codeBlock);
    }
  }

  /**
   * Reads effect tags and adds them to chrome effects collection.
   * @param effectsNode Effects element
   * @param ownerReference Variable reference to UIElement or chrome instance.
   * @param ownerType Element type of chrome that owns effect collection.
   */
  public void readEffects(ModelCollectionProperty effectsNode, Reference ownerReference,
      TypeToken ownerType, CodeBlock codeBlock) {
    int childCount = effectsNode.getChildCount();
    Expression effectsCollection = packageBuilder.createGetPropertyExpression(ownerReference,
        EFFECTS_VAR_NAME);
    for (int c = 0; c < childCount; ++c) {
      Model effectNode = effectsNode.getChild(c);
      readEffectNode(effectNode, effectsCollection, ownerReference, ownerType, codeBlock);
    }
  }

  private boolean readEffectNode(Model effectNode, Expression effectsCollection,
      Reference ownerReference, TypeToken ownerType, CodeBlock codeBlock) {
    if (effectNode.getTypeName() != EFFECT_TAG_NAME) {
      addError(new CompilerError(effectNode.getLineNumber(), effectNode.getColumn(),
          ERROR_MSG_EXPECTING_EFFECT_TAG));
      return false;
    }

    if (!effectNode.hasProperty(EFFECT_PROPERTY_ATTRIBUTE)) {
      addError(new CompilerError(effectNode.getLineNumber(), effectNode.getColumn(),
          ERROR_MSG_MISSING_EFFECT_PROPERTY_ATTR));
      return false;
    }

    TypeToken effectType = TypeToken.fromClass(Effect.class);
    packageBuilder.addImport(effectType);

    // Read effect node and add to chrome.effects
    Expression effect = readChildNode(effectNode, codeBlock);
    codeBlock.getStatements().add(packageBuilder.createCollectionAddStatement(
        effectsCollection, effect));
    // We need chromeTree root to be model root explicitely.
    if (chromeDefContext.isEmpty()) {
      codeBlock.getStatements().add(packageBuilder.createExpressionStatement(
          packageBuilder.createSetPropertyExpression(effect, CHROME_METHOD_TARGET_PARAM_NAME,
            packageBuilder.createSelfReferenceExpression())));
    }
    return true;
  }

  /**
   * Returns a reference to a resource.
   */
  public Expression getResourceBindingExpression(String bindSource) {
    if (bindSource.startsWith(RESOURCE_PREFIX)) {
      bindSource = bindSource.substring(RESOURCE_PREFIX.length());
    }
    if (localResources.containsKey(bindSource)) {
      return localResources.get(bindSource).getReference();
    } else if (importedResourceLookup.containsKey(bindSource)) {
      ResourceInfo resInfo = importedResourceLookup.get(bindSource);
      /* TODO(ferhat): implement static access for static resources. uncomment block
       * to support.
       if (rootType.getName().equals("Resources")) {
        TypeToken resourceType = TypeToken.fromFullName((String)
            resInfo.getModel().getParent().getProperty("name").getValue());
        packageBuilder.addImport(resourceType);
        return packageBuilder.createGetStaticFieldExpression(
            resourceType, (String) resInfo.getModel().getProperty(ID_ATTRIBUTE).getValue());
      } else */ {
        Expression expr = packageBuilder.createMethodCall(
            packageBuilder.createSelfReferenceExpression(), "findResource",
            new Expression[] {resInfo.getKey()});
        TypeToken resourceType = getResourceType(resInfo);
        if (resourceType != null) {
          packageBuilder.addImport(resourceType);
          expr = packageBuilder.createTypeCast(resourceType, expr);
        }
        return expr;
      }
    // !!! Checking localResources before interface resources so we
    // can override interface members.
    } else if (interfaceResourceLookup.containsKey(bindSource)) {
      Expression resExpr = interfaceResourceLookup.get(bindSource).getReference();
      if (resExpr == null) {
        ResourceInfo resInfo = getResourceInfo("{" + bindSource + "}");
        Expression intfResExpr = createGetInterfaceResourceExpression(resInfo.getInterface(),
            getResourceType(resInfo), bindSource);
        TypeToken resourceType = getResourceType(resInfo);
        if (resourceType != null) {
          packageBuilder.addImport(resourceType);
          intfResExpr = packageBuilder.createTypeCast(resourceType, intfResExpr);
        }
        return intfResExpr;
      }
    } else if (localIds.containsKey(bindSource)) {
      return packageBuilder.createMethodCall(
          packageBuilder.createSelfReferenceExpression(), "findResource",
          new Expression[] {new StringLiteralExpression(bindSource)});
    }
    return null;
  }

  private TypeToken resolveResourceOwnerType(ResourceInfo resInfo) {
    Model m = resInfo.model;
    do {
      m = m.getParent();
    } while (m.getParent().getTypeName() != "Root");
    return TypeToken.fromFullName(m.getStringProperty("name"));
  }

  /**
   * Returns target packageBuilder.
   */
  public PackageBuilder getPackageBuilder() {
    return packageBuilder;
  }

  /**
   * Returns target errors collection.
   */
  public List<CompilerError> getErrors() {
    return errors;
  }

  /**
   * Adds error to model compiler errors.
   */
  public void addError(CompilerError error) {
    error.setSource(sourceName);
    errors.add(error);
  }

//  /**
//   * Adds error to model compiler errors.
//   */
//  public void addError(String errorMessage, Model locality) {
//    addError(new CompilerError(locality.getLineNumber(),
//        locality.getColumn(), errorMessage));
//  }

  /**
   * Adds error to model compiler errors.
   */
  public void addError(ErrorCode errorCode, String detail, Model locality) {
    addError(new CompilerError(locality.getLineNumber(),
        locality.getColumn(), String.format("%s [%s]", errorCode.getDescription(),
            detail)));
  }

  /**
   * Adds error to model compiler errors.
   */
  public void addWarning(ErrorCode errorCode, String detail, Model locality) {
    CompilerError error = new CompilerError(locality.getLineNumber(),
        locality.getColumn(), String.format("%s [%s]", errorCode.getDescription(), detail));
    error.setSeverity(Severity.WARNING);
    addError(error);
  }

  /**
   * Adds error to model compiler errors.
   */
  public void addError(ErrorCode errorCode, String detail) {
    addError(new CompilerError(String.format("%s [%s]", errorCode.getDescription(),
            detail)));
  }

  /**
   * Adds error to model compiler errors.
   */
  public void addError(ErrorCode errorCode, Model locality) {
    addError(new CompilerError(locality.getLineNumber(),
        locality.getColumn(), errorCode.getDescription()));
  }

  /**
   * Adds error to model compiler errors.
   */
  public void addError(ErrorCode errorCode) {
    addError(new CompilerError(errorCode.getDescription()));
  }

  private void reportUnknownId(String id, Model referenceNode) {
    if (!idErrors.contains(id)) {
      addError(ErrorCode.UNKNOWN_ELEMENT_ID_IN_TARGET, String.format(
          ErrorCode.UNKNOWN_ELEMENT_ID_IN_TARGET.getFormat(), id),
          referenceNode);
      idErrors.add(id);
    }
  }

  /**
   * Pushes a chrome definition to context.
   */
  public void pushChromeContext(ChromeDefContext def) {
    chromeDefContext.push(def);
  }

  /**
   * Pops a chrome definition from context.
   */
  public void popChromeContext() {
    chromeDefContext.pop();
  }

  /**
   * Returns model reflector used by compiler.
   */
  public ModelReflector getModelReflector() {
    return modelReflector;
  }

  /**
   * Returns true if property definition of a property indicates it can be localized.
   * @param modelNode Parent node of property.
   * @param prop Property node.
   * @return true if property can be localized.
   */
  private boolean propertyNeedsLocalization(Model modelNode, ModelProperty prop, String propVal) {
    int len = propVal.length();
    if (len > 0 && Character.isDigit(propVal.charAt(0))) {
      boolean isNumeric = true;
      for (int i = 1; i < len; i++) {
        int ch = propVal.charAt(i);
        if (!(Character.isDigit(ch) || ch == '-' || ch == '%')) {
          // Allow 1x..40x type factors.
          if (!((i == (propVal.length() - 1)) && (ch == 'x' || ch == 'X'))) {
            // Non digit.
            isNumeric = true;
            break;
          }
        }
      }
      if (isNumeric) {
        return false;
      }
      boolean hasLetter = false;
      // If string has no letters no need for loca.
      for (int i = 1; i < len; i++) {
        int ch = propVal.charAt(i);
        if (Character.isLetter(ch)) {
          hasLetter = true;
        }
      }
      if (hasLetter == false || (propVal.length() == 1)) {
        return false;
      }
    }
    boolean hasAlphaOrDigit = false;
    for (int i = 0; i < len; i++) {
      if (Character.isLetterOrDigit(propVal.charAt(i))) {
        hasAlphaOrDigit = true;
        break;
      }
    }
    if (!hasAlphaOrDigit) {
      return false;
    }
    PropertyDefinition propDef = prop.getPropDef();
    return (propDef != null) && propDef.getDefaultPropData().getFlags().contains(
        PropertyFlags.Localizable);
  }

  /**
   * Provides Resource information from ReadResource method.
   */
  public static class ResourceInfo {
    private String id;
    private Expression key;
    private Reference reference;
    private Model model;
    private String interfaceName = null;
    /** Sets or returns if resource is constant. */
    public boolean isConst = false;

    /** Constructor */
    public ResourceInfo(String id, Expression key, Reference reference, Model model) {
      this.id = id;
      this.key = key;
      this.reference = reference;
      this.model = model;
    }

    /** Returns id of resource */
    public String getId() {
      return id;
    }

    /** Returns key in resource collection */
    public Expression getKey() {
      return key;
    }

    /** Sets name of interface owning resource */
    public void setInterface(String name) {
      interfaceName = name;
    }

    /** Returns name of interface owning resource */
    public String getInterface() {
      return interfaceName;
    }

    /** Returns true if we have a reference expression for the resource */
    public boolean hasReference() {
      return reference != null;
    }

    /** Returns reference to variable/field that holds resource */
    public Reference getReference() {
      return reference;
    }

    /** Returns Model of resource */
    public Model getModel() {
      return model;
    }
  }

  private static class CompileApp extends Application {
    @Override
    protected Object readDynamicValue(Object source, String keyName) {
      //just use the dynamic getter
      try {
        return source.getClass().getDeclaredField(keyName).get(source);
      } catch (IllegalAccessException exp) {
        logger.log(Level.SEVERE, "Illegal access on field binding", exp);
        return null;
      } catch (NoSuchFieldException noFieldExp) {
        logger.log(Level.SEVERE, "Invalid field binding", noFieldExp);
        return null;
      }
    }

    @Override
    protected void writeDynamicValue(Object targetObject, String keyName, Object value) {
    // just use the dynamic setter
    try {
      targetObject.getClass().getDeclaredField(keyName).set(targetObject, value);
    } catch (IllegalAccessException exp) {
      logger.log(Level.SEVERE, "Illegal access on field binding", exp);
    } catch (NoSuchFieldException noFieldExp) {
      logger.log(Level.SEVERE, "Invalid field binding", noFieldExp);
    }
    }

    /**
     * Verifies that a class has been loaded. Classes have to be loaded for
     * PropertyDefinitions to be registered.
     */
    @Override
    public boolean verifyClassLoaded(Class<? extends UxmlElement> ownerClass) {
      if (classLoaded.contains(ownerClass)) {
        return true;
      }
      classLoaded.add(ownerClass);
      if (ownerClass.equals(Brush.class)) { // skip abstract
        return true;
      }
      try {
        ownerClass.newInstance();
        return true;
      } catch (IllegalAccessException e) {
        logger.log(Level.SEVERE, "getPropertyDefinitions failed to initialize class", e);
      } catch (InstantiationException e) {
        logger.log(Level.SEVERE, "getPropertyDefinitions failed to initialize class." +
            "Expecting constructor with no parameters for class", e);
      }
      return false;
    }
  }
}
