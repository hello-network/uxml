package com.hello.uxml.tools.framework;

import com.hello.uxml.tools.framework.events.DataEvent;
import com.hello.uxml.tools.framework.events.EventDefinition;
import com.hello.uxml.tools.framework.events.EventManager;
import com.hello.uxml.tools.framework.graphics.UISurface;
import com.hello.uxml.tools.framework.graphics.UITextSurface;

import java.util.EnumSet;

/**
 * Displays single or multiline static text.
 *
 * @author ferhat@(Ferhat Buyukkokten)
 */
public class Label extends Control {

  /** Text Property Definition */
  public static PropertyDefinition textPropDef = PropertySystem.register("Text",
      String.class,
      Label.class,
      new PropertyData("", EnumSet.of(PropertyFlags.Resize, PropertyFlags.Localizable,
          PropertyFlags.Redraw, PropertyFlags.Inherit), new PropertyChangeListener() {
        @Override
        public void propertyChanged(PropertyChangedEvent e) {
          Label element = (Label) e.getSource();
          element.updateTextSurface();
          }
        }
      ));

  /** CharSpacing Property Definition */
  public static PropertyDefinition charSpacingPropDef = PropertySystem.register(
      "CharSpacing",
      Double.class,
      Label.class,
      new PropertyData(0, EnumSet.of(PropertyFlags.Resize,
          PropertyFlags.Redraw)));

  /**
   * WordWrap property definition.
   */
  public static PropertyDefinition wordWrapPropDef = PropertySystem.register(
      "WordWrap", Boolean.class, Label.class,
      new PropertyData(false, EnumSet.of(PropertyFlags.None), new PropertyChangeListener() {
        @Override
        public void propertyChanged(PropertyChangedEvent e) {
          // TODO(ferhat) set UITextSurface property.
          // ((UIElement) e.getSource()).cachedVisible = ((Boolean) e.getNewValue()).booleanValue();
        }}));

  /**
   * Multiline property definition.
   */
  public static PropertyDefinition multilinePropDef = PropertySystem.register(
      "Multiline", Boolean.class, Label.class,
      new PropertyData(false, EnumSet.of(PropertyFlags.None)));

  /**
   * Selectable property definition.
   */
  public static PropertyDefinition selectablePropDef = PropertySystem.register(
      "Selectable", Boolean.class, Label.class,
      new PropertyData(false, EnumSet.of(PropertyFlags.None)));

  /**
   * SizeToBold property definition.
   */
  public static PropertyDefinition sizeToBoldPropDef = PropertySystem.register(
      "SizeToBold", Boolean.class, Label.class,
      new PropertyData(false, EnumSet.of(PropertyFlags.None)));

  /**
   * Ellipsis property definition.
   */
  public static PropertyDefinition ellipsisPropDef = PropertySystem.register(
      "Ellipsis", Boolean.class, Label.class,
      new PropertyData(false, EnumSet.of(PropertyFlags.None)));

  /**
   * HtmlEnabled property definition.
   */
  public static PropertyDefinition htmlEnabledPropDef = PropertySystem.register(
      "HtmlEnabled", Boolean.class, Label.class,
      new PropertyData(false, EnumSet.of(PropertyFlags.None)));

  /** LinkClick event definition */
  public static EventDefinition linkClickEvent = EventManager.register(
      "LinkClick", Label.class, DataEvent.class);

  /** Text align property definition. */
  public static PropertyDefinition textAlignPropDef = PropertySystem.register("TextAlign",
      TextAlign.class, UIElement.class,
      new PropertyData(TextAlign.Left, EnumSet.of(PropertyFlags.ParentRelayout)));

  /**
   * Sets or returns text of label.
   */
  public String getText() {
    return (String) getProperty(textPropDef);
  }

  public void setText(String text) {
    setProperty(textPropDef, text);
  }

  /**
   * Sets/returns if word wrapping is enabled.
   */
  public void setWordWrap(boolean value) {
    setProperty(wordWrapPropDef, value);
  }

  public boolean getWordWrap() {
    return ((Boolean) getProperty(wordWrapPropDef));
  }

  /**
   * Sets/returns if label should be measured with bold style.
   */
  public void setSizeToBold(boolean value) {
    setProperty(sizeToBoldPropDef, value);
  }

  public boolean getSizeToBold() {
    return ((Boolean) getProperty(sizeToBoldPropDef));
  }

  /**
   * Sets/returns if multiline is enabled.
   */
  public void setMultiline(boolean value) {
    setProperty(multilinePropDef, value);
  }

  public boolean getMultiline() {
    return ((Boolean) getProperty(multilinePropDef));
  }

  /**
   * Sets/returns if selection is enabled.
   */
  public void setSelectable(boolean value) {
    setProperty(selectablePropDef, value);
  }

  public boolean getSelectable() {
    return ((Boolean) getProperty(selectablePropDef));
  }

  /**
   * Sets/returns if ellipsis is enabled when text is larger than frame.
   */
  public void setEllipsis(boolean value) {
    setProperty(ellipsisPropDef, value);
  }

  public boolean getEllipsis() {
    return ((Boolean) getProperty(ellipsisPropDef));
  }

  /**
   * Sets/returns if text content is html.
   */
  public void setHtmlEnabled(boolean value) {
    setProperty(htmlEnabledPropDef, value);
  }

  public boolean getHtmlEnabled() {
    return ((Boolean) getProperty(htmlEnabledPropDef));
  }

  /**
   * Sets or returns character spacing.
   */
  public double getCharSpacing() {
    return ((Double) getProperty(charSpacingPropDef)).doubleValue();
  }

  public void setCharSpacing(double amount) {
    setProperty(charSpacingPropDef, amount);
  }

  @Override
  protected void onMeasure(double availWidth, double availableHeight) {
    if (hostSurface == null) {
      setMeasuredDimension(0, 0);
    } else {
      Size textSize = ((UITextSurface) hostSurface).measureText(getText(),
          availWidth, availableHeight);
      setMeasuredDimension(textSize.width, textSize.height);
    }
  }

  /**
   * Updates text and font properties of text surface
   */
  private void updateTextSurface() {
    if (this.hostSurface != null) {
      UITextSurface surface = (UITextSurface) this.hostSurface;
      surface.setText(getText());
      surface.setFontName(getFontName());
      surface.setFontSize(getFontSize());
      surface.setFontBold(getFontBold());
      surface.setTextColor(getTextColor());
      surface.updateTextView();
    }
  }

  @Override
  public void initSurface(UISurface parentSurface) {
    hostSurface = parentSurface.createChildTextSurface();
    hostSurface.setTarget(this);
    updateTextSurface();
  }
}
