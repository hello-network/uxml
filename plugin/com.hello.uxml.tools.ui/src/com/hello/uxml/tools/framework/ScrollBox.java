package com.hello.uxml.tools.framework;

import com.hello.uxml.tools.framework.events.EventArgs;
import com.hello.uxml.tools.framework.events.EventHandler;
import com.hello.uxml.tools.framework.events.EventNotifier;

import java.util.EnumSet;

/**
 * Implements a container that scrolls content.
 *
 * @author ferhat
 */
public class ScrollBox extends ContentContainer {

  private ScrollBar verticalScroll;
  private ScrollBar horizontalScroll;
  private Canvas contentPart;

  /** ScrollPointX Property Definition */
  public static PropertyDefinition scrollPointXPropDef = PropertySystem.register("ScrollPointX",
      Double.class, ScrollBox.class, new PropertyData(0.0, new PropertyChangeListener(){
        @Override
        public void propertyChanged(PropertyChangedEvent e) {
          ((ScrollBox) e.getSource()).scrollPointChanged();
        }
      }, EnumSet.of(PropertyFlags.None)));

  /** ScrollPointY Property Definition */
  public static PropertyDefinition scrollPointYPropDef = PropertySystem.register("ScrollPointY",
      Double.class, ScrollBox.class, new PropertyData(0.0, new PropertyChangeListener(){
        @Override
        public void propertyChanged(PropertyChangedEvent e) {
          ((ScrollBox) e.getSource()).scrollPointChanged();
        }
      }, EnumSet.of(PropertyFlags.None)));

  /** ScrollPointY Property Definition */
  public static PropertyDefinition panningEnabledPropDef = PropertySystem.register("PanningEnabled",
      Boolean.class, ScrollBox.class, new PropertyData(false, EnumSet.of(PropertyFlags.None)));

  /** VerticalScrollEnabled Property Definition */
  public static PropertyDefinition verticalScrollEnabledPropDef = PropertySystem.register(
      "VerticalScrollEnabled", Boolean.class, ScrollBox.class,
      new PropertyData(true, EnumSet.of(PropertyFlags.None)));

  /** HorizontalScrollEnabled Property Definition */
  public static PropertyDefinition horizontalScrollEnabledPropDef = PropertySystem.register(
      "HorizontalEnabled", Boolean.class, ScrollBox.class,
      new PropertyData(true, EnumSet.of(PropertyFlags.None)));

  /**
   * Sets or returns scroll position.
   */
  public void setScrollPointX(double value) {
    setProperty(scrollPointXPropDef, value);
  }

  public double getScrollPointX() {
    return ((Double) getProperty(scrollPointXPropDef)).doubleValue();
  }

  /**
   * Sets or returns scroll position.
   */
  public void setScrollPointY(double value) {
    setProperty(scrollPointYPropDef, value);
  }

  public double getScrollPointY() {
    return ((Double) getProperty(scrollPointYPropDef)).doubleValue();
  }

  /**
   * Sets or returns if panning is enabled.
   */
  public void setPanningEnabled(boolean enabled) {
    setProperty(panningEnabledPropDef, enabled);
  }

  public boolean getPanningEnabled() {
    return ((Boolean) getProperty(panningEnabledPropDef)).booleanValue();
  }

  /**
   * Sets or returns if vertical scrollbar is enabled.
   */
  public void setVerticalScrollEnabled(boolean enabled) {
    setProperty(verticalScrollEnabledPropDef, enabled);
  }

  public boolean getVerticalScrollEnabled() {
    return ((Boolean) getProperty(verticalScrollEnabledPropDef)).booleanValue();
  }

  /**
   * Sets or returns if vertical scrollbar is enabled.
   */
  public void setHorizontalScrollEnabled(boolean enabled) {
    setProperty(horizontalScrollEnabledPropDef, enabled);
  }

  public boolean getHorizontalScrollEnabled() {
    return ((Boolean) getProperty(horizontalScrollEnabledPropDef)).booleanValue();
  }

  @Override
  protected void onChromeChanged(Chrome chrome) {
    super.onChromeChanged(chrome);
    ScrollBar scroll = (ScrollBar) getElement("verticalScrollBarPart");
    verticalScroll = scroll;
    if (verticalScroll != null) {
      verticalScroll.addListener(ScrollBar.valueChangedEvent, new EventHandler(){
        @Override
        public void handleEvent(EventNotifier targetObject, EventArgs e) {
          setScrollPointY(verticalScroll.getValue());
        }
      });
    }
    scroll = (ScrollBar) getElement("horizontalScrollBarPart");
    horizontalScroll = scroll;
    if (horizontalScroll != null) {
      horizontalScroll.addListener(ScrollBar.valueChangedEvent, new EventHandler(){
        @Override
        public void handleEvent(EventNotifier targetObject, EventArgs e) {
          setScrollPointX(horizontalScroll.getValue());
        }
      });
    }
    contentPart = (Canvas) getElement("contentPart");
    if (contentPart != null) {
      contentPart.setClipChildren(true);
      if (cachedContentControl != null) {
        contentPart.addChild(cachedContentControl);
      }
    }
  }

  private void scrollPointChanged() {
    if (cachedContentControl != null) {
      Canvas.setChildLeft(cachedContentControl, -getScrollPointX());
      Canvas.setChildTop(cachedContentControl, -getScrollPointY());
    }
  }

  @Override
  protected void updateContent(Object newContent) {
    if ((cachedContentControl != null) && (contentPart != null)) {
      contentPart.removeChild(cachedContentControl);
    }
    if (newContent != null) {
      cachedContentControl = createControlFromContent(newContent);
      if (contentPart != null) {
        contentPart.addChild(cachedContentControl);
      }
    } else {
      cachedContentControl = null;
    }
  }

  @Override
  protected void onLayout(Rectangle layoutRectangle) {
    super.onLayout(layoutRectangle);
    boolean horizScrollVisible = false;
    boolean vertScrollVisible = false;
    double viewPortWidth = layoutRectangle.width;
    double viewPortHeight = layoutRectangle.height;
    double contentWidth = 0;
    double contentHeight = 0;
    if (cachedContentControl != null) {
      contentWidth = cachedContentControl.getMeasuredWidth();
      contentHeight = cachedContentControl.getMeasuredHeight();
      if ((contentHeight > layoutRectangle.height) &&
          (verticalScroll != null)) {
          viewPortWidth -= verticalScroll.getMeasuredWidth();
          vertScrollVisible = true;
      }
      if ((contentWidth > layoutRectangle.height) &&
          (horizontalScroll != null)) {
        horizScrollVisible = true;
        viewPortHeight -= horizontalScroll.getMeasuredHeight();
      }
    }

    if (verticalScroll != null) {
      verticalScroll.setVisible(vertScrollVisible);
      if (!vertScrollVisible) {
        setScrollPointY(0.0);
      } else if (getScrollPointY() > (contentHeight - viewPortHeight)) {
        // if scrollbox height expands or contentHeight shrinks and
        // scrollPointY is too large correct scroll position
        setScrollPointY(contentHeight - viewPortHeight);
      }
      verticalScroll.setMaxValue(contentHeight - viewPortHeight);
    }
    if (horizontalScroll != null) {
      if (!horizScrollVisible) {
        setScrollPointX(0.0);
      } else if (getScrollPointX() > (contentWidth - viewPortWidth)) {
        // if scrollbox width expands or contentWidth shrinks and
        // scrollPointX is too large, correct scroll position
        setScrollPointX(contentWidth - viewPortWidth);
      }
      horizontalScroll.setVisible(horizScrollVisible);
      horizontalScroll.setMaxValue(contentWidth - viewPortWidth);
    }
  }
}
