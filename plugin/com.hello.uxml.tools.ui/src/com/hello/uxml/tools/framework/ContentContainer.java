package com.hello.uxml.tools.framework;

import java.util.EnumSet;

/**
 * Implements a placeholder for the content of skinnable controls.
 *
 * @author ferhat
 */
public class ContentContainer extends Control {

  /** child control */
  protected UIElement cachedContentControl;

  /** Content Property Definition */
  public static PropertyDefinition contentPropDef = PropertySystem.register("Content", Object.class,
      ContentContainer.class,
      new PropertyData(null, EnumSet.of(PropertyFlags.Resize, PropertyFlags.Localizable),
          new PropertyChangeListener() {
            @Override
            public void propertyChanged(PropertyChangedEvent e) {
              ((ContentContainer) e.getSource()).updateContent(e.getNewValue());
            }
      }));

  /**
   * Sets content of container.
   */
  @ContentNode
  public void setContent(Object content) {
    setProperty(contentPropDef, content);
  }

  /**
   * Returns content.
   */
  public Object getContent() {
    return getProperty(contentPropDef);
  }

  @Override
  protected int getRawChildCount() {
    return ((cachedContentControl != null) || (chromeTree != null)) ? 1 : 0;
  }

  @Override
  protected UIElement getRawChild(int index) {
    if (index != 0) {
      throw new IndexOutOfBoundsException();
    }
    return chromeTree != null ? chromeTree : cachedContentControl;
  }

  protected void updateContent(Object newContent) {
    if (cachedContentControl != null) {
      removeRawChild(cachedContentControl);
    }
    cachedContentControl = createControlFromContent(newContent);
    if (cachedContentControl != null) {
      addRawChild(cachedContentControl);
    }
  }

  protected UIElement createControlFromContent(Object newContent) {
    if (newContent instanceof String) {
      Label label = new Label();
      label.setHAlign(HAlign.Center);
      label.setMargins(new Margin(4, 2, 4, 2));
      label.setText((String) newContent);
      return label;
    } else if (newContent instanceof UIElement) {
      return (UIElement) newContent;
    }
    return null;
  }

  @Override
  protected void onMeasure(double availableWidth, double availableHeight) {
    if (chromeTree != null) {
      chromeTree.measure(availableWidth, availableHeight);
      setMeasuredDimension(chromeTree.getMeasuredWidth(), chromeTree.getMeasuredHeight());
    } else if (cachedContentControl != null) {
      cachedContentControl.measure(availableWidth, availableHeight);
      setMeasuredDimension(cachedContentControl.getMeasuredWidth(),
          cachedContentControl.getMeasuredHeight());
    } else {
      setMeasuredDimension(0, 0);
    }
  }

  @Override
  protected void onLayout(Rectangle layoutRectangle) {
    if (chromeTree != null) {
      chromeTree.layout(new Rectangle(0, 0, layoutRectangle.width, layoutRectangle.height));
    } else if (cachedContentControl != null) {
      cachedContentControl.layout(new Rectangle(0, 0, layoutRectangle.width,
          layoutRectangle.height));
    }
  }
}
