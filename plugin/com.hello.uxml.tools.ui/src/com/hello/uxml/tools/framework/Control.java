package com.hello.uxml.tools.framework;

import com.hello.uxml.tools.framework.graphics.Brush;
import com.hello.uxml.tools.framework.graphics.Color;
import com.hello.uxml.tools.framework.graphics.UISurface;

import java.util.EnumSet;

/**
 * Provides control level properties such as FontName, FontSize,
 * tabbing support, etc.
 *
 * @author ferhat@(Ferhat Buyukkokten)
 */
public class Control extends UIElement {

  /**
   * Chrome element tree.
   */
  protected UIElement chromeTree;
  public static final String DEFAULT_FONT_NAME = "Arial";
  public static final double DEFAULT_FONT_SIZE = 10.0;
  public static final Boolean DEFAULT_FONT_BOLD = false;
  /** cached padding */
  protected Margin cachedPadding = Margin.EMPTY;

  /** FontName Property Definition */
  public static PropertyDefinition fontNamePropDef = PropertySystem.register("FontName",
      String.class,
      Control.class,
      new PropertyData(DEFAULT_FONT_NAME, EnumSet.of(PropertyFlags.Resize,
          PropertyFlags.Redraw, PropertyFlags.Inherit)));

  /** FontSize Property Definition */
  public static PropertyDefinition fontSizePropDef = PropertySystem.register("FontSize",
      Double.class,
      Control.class,
      new PropertyData(DEFAULT_FONT_SIZE, EnumSet.of(PropertyFlags.Resize,
          PropertyFlags.Redraw, PropertyFlags.Inherit)));

  /** FontBold Property Definition */
  public static PropertyDefinition fontBoldPropDef = PropertySystem.register("FontBold",
      Boolean.class,
      Control.class,
      new PropertyData(DEFAULT_FONT_BOLD, EnumSet.of(PropertyFlags.Resize,
          PropertyFlags.Redraw, PropertyFlags.Inherit)));

  /** TextColor Property Definition */
  public static PropertyDefinition textColorPropDef = PropertySystem.register("TextColor",
      Color.class,
      Control.class,
      new PropertyData(Color.BLACK, EnumSet.of(PropertyFlags.Redraw, PropertyFlags.Inherit)));

  /** Background property definition */
  public static PropertyDefinition backgroundPropDef = PropertySystem.register("Background",
      Brush.class, Control.class, new PropertyData(null, null, EnumSet.of(
          PropertyFlags.Redraw)));

  /** Padding Property Definition */
  public static PropertyDefinition paddingPropDef = PropertySystem.register("Padding",
      Margin.class, Control.class,
      new PropertyData(Margin.EMPTY, new PropertyChangeListener() {
        @Override
        public void propertyChanged(PropertyChangedEvent e) {
          ((Control) e.getSource()).cachedPadding = ((Margin) e.getNewValue());
          ((Control) e.getSource()).invalidateSize();
        }}));

  /** Border radius Property Definition */
  public static PropertyDefinition borderRadiusPropDef = PropertySystem.register("BorderRadius",
      BorderRadius.class, Control.class,
      new PropertyData(BorderRadius.EMPTY, EnumSet.of(PropertyFlags.Redraw)));

  /** Prompt message property definition */
  public static PropertyDefinition promptMessagePropDef = PropertySystem.register("PromptMessage",
      String.class,
      Control.class,
      new PropertyData("", EnumSet.of(PropertyFlags.Redraw, PropertyFlags.Localizable)));

  /** Validation error message property definition */
  public static PropertyDefinition errorMessagePropDef = PropertySystem.register("ErrorMessage",
      String.class,
      Control.class,
      new PropertyData("", EnumSet.of(PropertyFlags.None, PropertyFlags.Localizable)));

  /** Chrome property definition */
  public static PropertyDefinition chromePropDef = PropertySystem.register("Chrome",
      Chrome.class, Control.class, new PropertyData(null, EnumSet.of(PropertyFlags.None),
          new PropertyChangeListener() {
            @Override
            public void propertyChanged(PropertyChangedEvent e) {
              ((Control) e.getSource()).onChromeChanged((Chrome) e.getNewValue());
            }}));

  /**
   * Sets or returns font name.
   */
  public String getFontName() {
    return ((String) getProperty(fontNamePropDef));
  }

  public void setFontName(String name) {
    setProperty(fontNamePropDef, name);
  }

  /**
   * Sets or returns prompt message.
   */
  public String getPromptMessage() {
    return ((String) getProperty(promptMessagePropDef));
  }

  public void setPromptMessage(String name) {
    setProperty(promptMessagePropDef, name);
  }

  /**
   * Sets or returns validation error message.
   */
  public String getErrorMessage() {
    return ((String) getProperty(errorMessagePropDef));
  }

  public void setErrorMessage(String name) {
    setProperty(errorMessagePropDef, name);
  }

  /**
   * Sets or returns font size.
   */
  public double getFontSize() {
    return ((Double) getProperty(fontSizePropDef)).doubleValue();
  }

  public void setFontSize(double size) {
    setProperty(fontSizePropDef, size);
  }

  /**
   * Sets or returns font bold.
   */
  public boolean getFontBold() {
    return ((Boolean) getProperty(fontBoldPropDef));
  }

  public void setFontBold(boolean bold) {
    setProperty(fontBoldPropDef, bold);
  }

  /**
   * Sets or returns text color.
   */
  public Color getTextColor() {
    return (Color) getProperty(textColorPropDef);
  }

  public void setTextColor(Color color) {
    setProperty(textColorPropDef, color);
  }

  /** Gets or sets background fill brush */
  public Brush getBackground() {
    return (Brush) getProperty(backgroundPropDef);
  }

  public void setBackground(Brush value) {
    setProperty(backgroundPropDef, value);
  }

  /**
   * Sets/returns border radius.
   */
  public void setBorderRadius(BorderRadius value) {
    setProperty(borderRadiusPropDef, value);
  }

  public BorderRadius getBorderRadius() {
    return (BorderRadius) getProperty(borderRadiusPropDef);
  }

  /**
   * Sets/returns padding.
   */
  public void setPadding(Margin value) {
    setProperty(paddingPropDef, value);
  }

  public Margin getPadding() {
    return cachedPadding;
  }

  @Override
  protected void onRedraw(UISurface surface) {
    Brush backgroundBrush = getBackground();
    if (backgroundBrush != null) {
      surface.drawRect(backgroundBrush, null, new Rectangle(0, 0, getLayoutRect().width,
          getLayoutRect().height));
    }
  }

  protected void onChromeChanged(Chrome chrome) {
    // Remove old chrome tree
    if (chromeTree != null) {
      removeRawChild(chromeTree);
      chromeTree = null;
    }
    if (chrome != null) {
      chromeTree = chrome.apply(this);
      if (chromeTree != null) {
        addRawChild(chromeTree);
      }
    }
  }

  @Override
  public void initSurface(UISurface parentSurface) {
    // Initialize chrome before surface initialization
    if (getChrome() == null) {
      Chrome chrome = (Chrome) findResource(getClass());
      if (chrome != null) {
        setChrome(chrome);
      }
    }
    super.initSurface(parentSurface);
  }

  /**
   * Sets/returns chrome of control.
   */
  public Chrome getChrome() {
    return (Chrome) getProperty(chromePropDef);
  }

  public void setChrome(Chrome chrome) {
    setProperty(chromePropDef, chrome);
  }

  @Override
  protected int getRawChildCount() {
    return (chromeTree == null) ? 0 : 1;
  }

  @Override
  protected UIElement getRawChild(int index) {
    return chromeTree;
  }

  @Override
  protected void onMeasure(double availableWidth, double availableHeight) {
    double maxWidth = 0;
    double maxHeight = 0;
    if (chromeTree != null) {
      chromeTree.measure(availableWidth, availableHeight);
      maxWidth = chromeTree.getMeasuredWidth();
      maxHeight = chromeTree.getMeasuredHeight();
    } else if (getRawChildCount() != 0) {
      UIElement child = getRawChild(0);
      child.measure(availableWidth, availableHeight);
      maxWidth = child.getMeasuredWidth();
      maxHeight = child.getMeasuredHeight();
    }
    setMeasuredDimension(maxWidth, maxHeight);
  }

  @Override
  protected void onLayout(Rectangle targetRect) {
    if (chromeTree != null) {
      chromeTree.layout(targetRect);
    } else if (getRawChildCount() != 0) {
      getRawChild(0).layout(targetRect);
    }
  }
}
