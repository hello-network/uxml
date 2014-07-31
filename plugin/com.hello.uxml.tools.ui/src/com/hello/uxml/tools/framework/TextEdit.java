package com.hello.uxml.tools.framework;

import com.hello.uxml.tools.framework.events.EventArgs;
import com.hello.uxml.tools.framework.events.EventDefinition;
import com.hello.uxml.tools.framework.events.EventManager;
import com.hello.uxml.tools.framework.graphics.UISurface;
import com.hello.uxml.tools.framework.graphics.UITextSurface;

import java.util.EnumSet;

/**
 * Displays single or multiline dynamic text.
 *
 * @author ferhat@(Ferhat Buyukkokten)
 */
public class TextEdit extends Control {

  /** Text Property Definition */
  public static PropertyDefinition textPropDef = PropertySystem.register("Text",
      String.class,
      TextEdit.class,
      new PropertyData("", EnumSet.of(PropertyFlags.Resize, PropertyFlags.Localizable,
          PropertyFlags.Redraw, PropertyFlags.Inherit), new PropertyChangeListener() {
        @Override
        public void propertyChanged(PropertyChangedEvent e) {
          TextEdit element = (TextEdit) e.getSource();
          element.updateTextSurface();
          EventArgs eArgs = new EventArgs(element, textChangedEvent);
          element.raiseEvent(eArgs);
          }
        }
      ));

  /**
   * DisplayAsPassword property definition.
   */
  public static PropertyDefinition displayAsPasswordPropDef = PropertySystem.register(
      "DisplayAsPassword", Boolean.class, TextEdit.class,
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
      "Multiline", Boolean.class, TextEdit.class,
      new PropertyData(false, EnumSet.of(PropertyFlags.None), new PropertyChangeListener() {
        @Override
        public void propertyChanged(PropertyChangedEvent e) {
          // TODO(ferhat) set UITextSurface property.
          // ((UIElement) e.getSource()).cachedVisible = ((Boolean) e.getNewValue()).booleanValue();
        }}));

  /**
   * WordWrap property definition.
   */
  public static PropertyDefinition wordWrapPropDef = PropertySystem.register(
      "WordWrap", Boolean.class, TextEdit.class,
      new PropertyData(true, EnumSet.of(PropertyFlags.None), new PropertyChangeListener() {
        @Override
        public void propertyChanged(PropertyChangedEvent e) {
          // TODO(ferhat) set UITextSurface property.
          // ((UIElement) e.getSource()).cachedVisible = ((Boolean) e.getNewValue()).booleanValue();
        }}));

  /**
   * HtmlEnabled property definition.
   */
  public static PropertyDefinition htmlEnabledPropDef = PropertySystem.register(
      "HtmlEnabled", Boolean.class, TextEdit.class,
      new PropertyData(true, EnumSet.of(PropertyFlags.None), new PropertyChangeListener() {
        @Override
        public void propertyChanged(PropertyChangedEvent e) {
          // TODO(ferhat) set UITextSurface property.
          // ((UIElement) e.getSource()).cachedVisible = ((Boolean) e.getNewValue()).booleanValue();
        }}));

  /**
   * Readonly property definition.
   */
  public static PropertyDefinition readOnlyPropDef = PropertySystem.register(
      "ReadOnly", Boolean.class, TextEdit.class,
      new PropertyData(true, EnumSet.of(PropertyFlags.None), new PropertyChangeListener() {
        @Override
        public void propertyChanged(PropertyChangedEvent e) {
          // TODO(ferhat) set UITextSurface property.
          // ((UIElement) e.getSource()).cachedVisible = ((Boolean) e.getNewValue()).booleanValue();
        }}));

  /**
   * MaxChars property definition.
   */
  public static PropertyDefinition maxCharsPropDef = PropertySystem.register(
      "MaxChars", Integer.class, TextEdit.class,
      new PropertyData(0, EnumSet.of(PropertyFlags.None), new PropertyChangeListener() {
        @Override
        public void propertyChanged(PropertyChangedEvent e) {
          // TODO(ferhat) set UITextSurface property.
          // ((UIElement) e.getSource()).cachedVisible = ((Boolean) e.getNewValue()).booleanValue();
        }}));

  /** TextChanged event definition */
  public static EventDefinition textChangedEvent = EventManager.register(
      "TextChanged", TextEdit.class, EventArgs.class, null, null);

  /**
   * Returns text.
   */
  public String getText() {
    return (String) getProperty(textPropDef);
  }

  /**
   * Sets text.
   */
  public void setText(String text) {
    setProperty(textPropDef, text);
  }


  /**
  * Sets/returns displayAsPassword property.
  */
  public void setDisplayAsPassword(boolean value) {
    setProperty(displayAsPasswordPropDef, value);
  }

  public boolean getDisplayAsPassword() {
    return ((Boolean) getProperty(displayAsPasswordPropDef));
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
   * Sets/returns if word wrapping is enabled.
   */
  public void setWordWrap(boolean value) {
    setProperty(wordWrapPropDef, value);
  }

  public boolean getWordWrap() {
    return ((Boolean) getProperty(wordWrapPropDef));
  }

  /**
   * Sets/returns if editor is readonly.
   */
  public void setReadOnly(boolean value) {
    setProperty(readOnlyPropDef, value);
  }

  public boolean getReadOnly() {
    return ((Boolean) getProperty(readOnlyPropDef));
  }

  /**
   * Sets/returns max chars allowed in the textedit.
   */
  public void setMaxChars(int value) {
    setProperty(maxCharsPropDef, value);
  }

  public int getMaxChars() {
    return ((Integer) getProperty(maxCharsPropDef));
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

  @Override
  protected void onMeasure(double availWidth, double availableHeight) {
    if (hostSurface == null) {
      setMeasuredDimension(0, 0);
    } else {
      Size textSize = ((UITextSurface) hostSurface).measureText(getText(), availWidth,
          availableHeight);
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
    }
  }

  @Override
  public void initSurface(UISurface parentSurface) {
    hostSurface = parentSurface.createChildTextSurface();
    hostSurface.setTarget(this);
    updateTextSurface();
  }
}
