package com.hello.uxml.tools.codegen.emit.dart;

import com.google.common.collect.Maps;
import com.hello.uxml.tools.codegen.emit.TypeToken;

import java.util.HashMap;

/**
 * Converts element types to TypeTokens for dash framework.
 * 
 * @author ferhat
 * 
 */
public final class DartFrameworkTypes {

	// Contains TypeTokens for framework element types.
	private static final HashMap<String, TypeToken> frameworkTokens = Maps
			.newHashMap();

	// Contains TypeToken id to primitive type name map.
	private static final HashMap<TypeToken, String> primitiveTypeNames = Maps
			.newHashMap();

	private static final String FRAMEWORK_NAMESPACE = "";
	private static final String FRAMEWORK_NAMESPACE_APP = "";
	private static final String FRAMEWORK_GRAPHICS_NAMESPACE = "";
	private static final String FRAMEWORK_EFFECTS_NAMESPACE = "";

	static {
		primitiveTypeNames.put(TypeToken.BOOLEAN, "bool");
		primitiveTypeNames.put(TypeToken.INT16, "int");
		primitiveTypeNames.put(TypeToken.UINT16, "int");
		primitiveTypeNames.put(TypeToken.INT32, "int");
		primitiveTypeNames.put(TypeToken.UINT32, "int");
		primitiveTypeNames.put(TypeToken.INT8, "byte");
		primitiveTypeNames.put(TypeToken.UINT8, "byte");
		primitiveTypeNames.put(TypeToken.STRING, "String");
		primitiveTypeNames.put(TypeToken.DOUBLE, "double");

		frameworkTokens.put("Application", new TypeToken(
				FRAMEWORK_NAMESPACE_APP, "Application"));
		frameworkTokens.put("Group",
				new TypeToken(FRAMEWORK_NAMESPACE, "Group"));
		frameworkTokens.put("Shape",
				new TypeToken(FRAMEWORK_NAMESPACE, "Shape"));
		frameworkTokens.put("PathShape", new TypeToken(FRAMEWORK_NAMESPACE,
				"PathShape"));
		frameworkTokens.put("LineShape", new TypeToken(FRAMEWORK_NAMESPACE,
				"LineShape"));
		frameworkTokens.put("RectShape", new TypeToken(FRAMEWORK_NAMESPACE,
				"RectShape"));
		frameworkTokens.put("EllipseShape", new TypeToken(FRAMEWORK_NAMESPACE,
				"EllipseShape"));
		frameworkTokens.put("Point",
				new TypeToken(FRAMEWORK_NAMESPACE, "Coord"));
		frameworkTokens.put("WrapBox", new TypeToken(FRAMEWORK_NAMESPACE,
				"WrapBox"));
		frameworkTokens.put("Border", new TypeToken(FRAMEWORK_NAMESPACE,
				"Border"));
		frameworkTokens.put("Canvas", new TypeToken(FRAMEWORK_NAMESPACE,
				"Canvas"));
		frameworkTokens.put("Image",
				new TypeToken(FRAMEWORK_NAMESPACE, "Image"));
		frameworkTokens.put("Label",
				new TypeToken(FRAMEWORK_NAMESPACE, "Label"));
		frameworkTokens.put("TextBox", new TypeToken(FRAMEWORK_NAMESPACE,
				"TextBox"));
		frameworkTokens.put("TextEdit", new TypeToken(FRAMEWORK_NAMESPACE,
				"TextEdit"));
		frameworkTokens.put("VBox", new TypeToken(FRAMEWORK_NAMESPACE, "VBox"));
		frameworkTokens.put("HBox", new TypeToken(FRAMEWORK_NAMESPACE, "HBox"));
		frameworkTokens.put("DockBox", new TypeToken(FRAMEWORK_NAMESPACE,
				"DockBox"));
		frameworkTokens.put("Margin", new TypeToken(FRAMEWORK_NAMESPACE,
				"Margin"));
		frameworkTokens.put("BorderRadius", new TypeToken(FRAMEWORK_NAMESPACE,
				"BorderRadius"));
		frameworkTokens.put("Matrix", new TypeToken(FRAMEWORK_NAMESPACE,
				"Matrix"));
		frameworkTokens.put("Color", new TypeToken(
				FRAMEWORK_GRAPHICS_NAMESPACE, "Color"));
		frameworkTokens.put("VecPath", new TypeToken(FRAMEWORK_GRAPHICS_NAMESPACE,
				"VecPath"));
		frameworkTokens.put("LinearBrush", new TypeToken(
				FRAMEWORK_GRAPHICS_NAMESPACE, "LinearBrush"));
		frameworkTokens.put("RadialBrush", new TypeToken(
				FRAMEWORK_GRAPHICS_NAMESPACE, "RadialBrush"));
		frameworkTokens.put("SolidBrush", new TypeToken(
				FRAMEWORK_GRAPHICS_NAMESPACE, "SolidBrush"));
		frameworkTokens.put("GradientStop", new TypeToken(
				FRAMEWORK_GRAPHICS_NAMESPACE, "GradientStop"));
		frameworkTokens.put("SolidPen", new TypeToken(
				FRAMEWORK_GRAPHICS_NAMESPACE, "SolidPen"));
		frameworkTokens.put("Filters", new TypeToken(
				FRAMEWORK_GRAPHICS_NAMESPACE, "Filters"));
		frameworkTokens.put("BlurFilter", new TypeToken(
				FRAMEWORK_GRAPHICS_NAMESPACE, "BlurFilter"));
		frameworkTokens.put("GlowFilter", new TypeToken(
				FRAMEWORK_GRAPHICS_NAMESPACE, "GlowFilter"));
		frameworkTokens.put("DropShadowFilter", new TypeToken(
				FRAMEWORK_GRAPHICS_NAMESPACE, "DropShadowFilter"));
		frameworkTokens.put("BevelFilter", new TypeToken(
				FRAMEWORK_GRAPHICS_NAMESPACE, "BevelFilter"));
		frameworkTokens.put("Chrome", new TypeToken(FRAMEWORK_NAMESPACE,
				"Chrome"));
		frameworkTokens.put("Button", new TypeToken(FRAMEWORK_NAMESPACE,
				"Button"));
		frameworkTokens.put("CheckBox", new TypeToken(FRAMEWORK_NAMESPACE,
				"CheckBox"));
		frameworkTokens.put("RadioButton", new TypeToken(FRAMEWORK_NAMESPACE,
				"RadioButton"));
		frameworkTokens.put("ContentContainer", new TypeToken(
				FRAMEWORK_NAMESPACE, "ContentContainer"));
		frameworkTokens.put("ListBox", new TypeToken(FRAMEWORK_NAMESPACE,
				"ListBox"));
		frameworkTokens.put("ItemsContainer", new TypeToken(
				FRAMEWORK_NAMESPACE, "ItemsContainer"));
		frameworkTokens.put("Effect", new TypeToken(
				FRAMEWORK_EFFECTS_NAMESPACE, "Effect"));
		frameworkTokens.put("PropertyAction", new TypeToken(
				FRAMEWORK_EFFECTS_NAMESPACE, "PropertyAction"));
		frameworkTokens.put("AnimateAction", new TypeToken(
				FRAMEWORK_EFFECTS_NAMESPACE, "AnimateAction"));
		frameworkTokens.put("Panel",
				new TypeToken(FRAMEWORK_NAMESPACE, "Panel"));
		frameworkTokens.put("Resources", new TypeToken(FRAMEWORK_NAMESPACE,
				"Resources"));
		frameworkTokens.put("OverlayContainer", new TypeToken(
				FRAMEWORK_NAMESPACE, "OverlayContainer"));
		frameworkTokens.put("Transform", new TypeToken(FRAMEWORK_NAMESPACE,
				"UITransform"));
		frameworkTokens.put("LabeledControl", new TypeToken(
				FRAMEWORK_NAMESPACE, "LabeledControl"));
		frameworkTokens.put("DropDownButton", new TypeToken(
				FRAMEWORK_NAMESPACE, "DropDownButton"));
		frameworkTokens.put("PageControl", new TypeToken(FRAMEWORK_NAMESPACE,
				"PageControl"));
		frameworkTokens.put("Popup",
				new TypeToken(FRAMEWORK_NAMESPACE, "Popup"));
		frameworkTokens.put("ScrollBox", new TypeToken(FRAMEWORK_NAMESPACE,
				"ScrollBox"));
		frameworkTokens.put("ScrollBar", new TypeToken(FRAMEWORK_NAMESPACE,
				"ScrollBar"));
		frameworkTokens.put("Slider", new TypeToken(FRAMEWORK_NAMESPACE,
				"Slider"));
		frameworkTokens.put("Item", new TypeToken(FRAMEWORK_NAMESPACE, "Item"));
		frameworkTokens.put("ComboBox", new TypeToken(FRAMEWORK_NAMESPACE,
				"ComboBox"));
		frameworkTokens.put("Control", new TypeToken(FRAMEWORK_NAMESPACE,
				"Control"));
		frameworkTokens.put("TableColumns", new TypeToken(FRAMEWORK_NAMESPACE,
				"TableColumns"));
		frameworkTokens.put("TableColumn", new TypeToken(FRAMEWORK_NAMESPACE,
				"TableColumn"));
		frameworkTokens.put("TableRows", new TypeToken(FRAMEWORK_NAMESPACE,
				"TableRows"));
		frameworkTokens.put("TableRow", new TypeToken(FRAMEWORK_NAMESPACE,
				"TableRow"));
		frameworkTokens.put("Table",
				new TypeToken(FRAMEWORK_NAMESPACE, "Table"));
		frameworkTokens.put("ToolTip", new TypeToken(FRAMEWORK_NAMESPACE,
				"ToolTip"));
		frameworkTokens.put("ValueRangeControl", new TypeToken(
				FRAMEWORK_NAMESPACE, "ValueRangeControl"));
		frameworkTokens.put("ProgressControl", new TypeToken(
				FRAMEWORK_NAMESPACE, "ProgressControl"));
		frameworkTokens.put("WaitIndicator", new TypeToken(FRAMEWORK_NAMESPACE,
				"WaitIndicator"));
		frameworkTokens.put("TabControl", new TypeToken(FRAMEWORK_NAMESPACE,
				"TabControl"));
		frameworkTokens.put("Brush", new TypeToken(
				FRAMEWORK_GRAPHICS_NAMESPACE, "Brush"));
		frameworkTokens.put("DisclosureBox", new TypeToken(FRAMEWORK_NAMESPACE,
				"DisclosureBox"));
	}

	/** Static helper class constructor */
	private DartFrameworkTypes() {
	}

	/**
	 * Translate primitive type names to target.
	 */
	public static String tokenTypeToString(TypeToken type) {
		// translate primitive types
		String name = primitiveTypeNames.get(type);
		if (name != null) {
			return name;
		}
		if (type.getNamespace() != null
				&& type.getNamespace().equals("com.hello.uxml.tools.framework")) {
			TypeToken targetType = frameworkTokens.get(type.getName());
			if (targetType != null) {
				name = targetType.getName();
			}
		}
		return (name != null) ? name : type.getName();
	}
}
