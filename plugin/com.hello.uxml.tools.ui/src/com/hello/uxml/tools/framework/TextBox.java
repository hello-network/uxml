package com.hello.uxml.tools.framework;

import com.hello.uxml.tools.framework.events.EventArgs;
import com.hello.uxml.tools.framework.events.EventDefinition;
import com.hello.uxml.tools.framework.events.EventManager;

import java.util.EnumSet;

/**
 * Implements a stylable TextEdit control.
 *
 * @author ferhat@(Ferhat Buyukkokten)
 */
public class TextBox extends Control {

  /** Text Property Definition */
  public static PropertyDefinition textPropDef = PropertySystem.register("Text",
      String.class,
      TextBox.class,
      new PropertyData("", EnumSet.of(PropertyFlags.Resize, PropertyFlags.Redraw,
          PropertyFlags.Localizable),
          new PropertyChangeListener() {
        @Override
        public void propertyChanged(PropertyChangedEvent e) {
          TextBox element = (TextBox) e.getSource();
          EventArgs eArgs = new EventArgs(element, textChangedEvent);
          element.raiseEvent(eArgs);
          }
        }
      ));

  /**
   * DisplayAsPassword property definition.
   */
  public static PropertyDefinition displayAsPasswordPropDef = PropertySystem.register(
      "DisplayAsPassword", Boolean.class, TextBox.class,
      new PropertyData(true, EnumSet.of(PropertyFlags.None)));

  /**
   * Multiline property definition.
   */
  public static PropertyDefinition multilinePropDef = PropertySystem.register(
      "Multiline", Boolean.class, TextBox.class,
      new PropertyData(false, EnumSet.of(PropertyFlags.None)));

  /**
   * WordWrap property definition.
   */
  public static PropertyDefinition wordWrapPropDef = PropertySystem.register(
      "WordWrap", Boolean.class, TextBox.class,
      new PropertyData(true, EnumSet.of(PropertyFlags.None)));

  /**
   * HtmlEnabled property definition.
   */
  public static PropertyDefinition htmlEnabledPropDef = PropertySystem.register(
      "HtmlEnabled", Boolean.class, TextBox.class,
      new PropertyData(true, EnumSet.of(PropertyFlags.None)));

  /**
   * Readonly property definition.
   */
  public static PropertyDefinition readOnlyPropDef = PropertySystem.register(
      "ReadOnly", Boolean.class, TextBox.class,
      new PropertyData(true, EnumSet.of(PropertyFlags.None), null));

  /**
   * MaxChars property definition.
   */
  public static PropertyDefinition maxCharsPropDef = PropertySystem.register(
      "MaxChars", Integer.class, TextBox.class,
      new PropertyData(0, EnumSet.of(PropertyFlags.None), null));

  /** TextChanged event definition */
  public static EventDefinition textChangedEvent = EventManager.register(
      "TextChanged", TextBox.class, EventArgs.class, null, null);

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
}
