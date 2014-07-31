package com.hello.uxml.tools.framework;

import com.hello.uxml.tools.framework.events.EventArgs;
import com.hello.uxml.tools.framework.events.EventHandler;
import com.hello.uxml.tools.framework.events.EventNotifier;
import com.hello.uxml.tools.framework.events.MouseEventArgs;

import java.util.EnumSet;

/**
 * Handles movement and sizing of a thumb inside a track.
 *
 * @author ferhat
 */
public class Slider extends ValueRangeControl {

  /** cached thumb control */
  protected UIElement cachedThumb;
  protected UIElement cachedTrack;
  private EventHandler thumbMouseDownHandler;
  private double moveStartValue;
  private double thumbStartPos;

  /** Thumb Property Definition */
  public static PropertyDefinition thumbPropDef = PropertySystem.register("Thumb",
      UIElement.class, Slider.class,
      new PropertyData(null, EnumSet.of(PropertyFlags.Resize), new PropertyChangeListener() {
        @Override
        public void propertyChanged(PropertyChangedEvent e) {
          Slider slider = (Slider) e.getSource();
          slider.thumbChanged((UIElement) e.getOldValue(), (UIElement) e.getNewValue());
        }
      }));

  /** Orientation Property Definition */
  public static PropertyDefinition orientationPropDef = PropertySystem.register("Orientation",
      Orientation.class, Slider.class,
      new PropertyData(Orientation.Horizontal, EnumSet.of(PropertyFlags.Resize)));

  /** Ticks Property Definition */
  public static PropertyDefinition ticksPropDef = PropertySystem.register("Ticks",
      Integer.class, Slider.class,
      new PropertyData(0));

  /** ThumbPressed property definition */
  public static PropertyDefinition thumbPressedPropDef = PropertySystem.register("ThumbPressed",
      Boolean.class, Slider.class,
      new PropertyData(false, EnumSet.of(PropertyFlags.None)));

  // Name of optional track part.
  private static final String TRACK_PART_ID = "trackPart";

  /**
   * Sets or returns thumb element of slider.
   */
  public void setThumb(UIElement content) {
    setProperty(thumbPropDef, content);
  }

  public UIElement getThumb() {
    return cachedThumb;
  }

  /**
   * Sets or returns tick mark count.
   */
  public void setTicks(int value) {
    setProperty(ticksPropDef, value);
  }

  public int getTicks() {
    return ((Integer) getProperty(ticksPropDef)).intValue();
  }

  /**
   * Returns whether thumb is in pressed down state.
   */
  public boolean getThumbPressed() {
    return (Boolean) getProperty(thumbPressedPropDef);
  }

  private void setThumbPressed(boolean val) {
    setProperty(thumbPressedPropDef, val);
  }


  /**
   * Sets or returns orientation.
   */
  public void setOrientation(Orientation orientation) {
    setProperty(orientationPropDef, orientation);
  }

  public Orientation getOrientation() {
    return (Orientation) getProperty(orientationPropDef);
  }

  @Override
  protected void onMeasure(double availableWidth, double availableHeight) {
    double maxWidth = 0;
    double maxHeight = 0;
    if (chromeTree != null) {
      chromeTree.measure(availableWidth, availableHeight);
      maxWidth = chromeTree.getMeasuredWidth();
      maxHeight = chromeTree.getMeasuredHeight();
    }
    UIElement thumbElement = getThumb();
    if (thumbElement != null) {
      thumbElement.measure(availableWidth, availableHeight);
      if (thumbElement.getMeasuredWidth() > maxWidth) {
        maxWidth = thumbElement.getMeasuredWidth();
      }
      if (thumbElement.getMeasuredHeight() > maxHeight) {
        maxHeight = thumbElement.getMeasuredHeight();
      }
    }
    setMeasuredDimension(maxWidth, maxHeight);
  }

  /**
   * Returns scale factor for value to coordinate translation.
   */
  private double getValueScaleFactor() {
    if (getOrientation() == Orientation.Vertical) {
      return (getLayoutRect().height - getThumb().getMeasuredHeight()) /
      (getMaxValue() - getMinValue());
    } else {
      return (getLayoutRect().width - getThumb().getMeasuredWidth()) /
      (getMaxValue() - getMinValue());
    }
  }

  @Override
  protected void onLayout(Rectangle targetRect) {
    if (chromeTree != null) {
      chromeTree.layout(targetRect);
    }
    UIElement thumbElement = getThumb();
    if (thumbElement == null) {
      return;
    }
    if (getOrientation() == Orientation.Vertical) {
      thumbElement.layout(0, getValue() * getValueScaleFactor(),
          Math.max(thumbElement.getMeasuredWidth(), targetRect.width),
          thumbElement.getMeasuredHeight());
    } else {
      thumbElement.layout(getValue() * getValueScaleFactor(), 0, thumbElement.getMeasuredWidth(),
          Math.max(thumbElement.getMeasuredHeight(), targetRect.height));
    }
  }

  private void thumbChanged(UIElement prevThumb, UIElement newThumb) {
    if (cachedThumb != null) {
      cachedThumb.removeListener(UIElement.mouseDownEvent, thumbMouseDownHandler);
      removeRawChild(cachedThumb);
    }
    if (newThumb != null) {
      cachedThumb = newThumb;
      addRawChild(cachedThumb);
      if (thumbMouseDownHandler == null) {
        thumbMouseDownHandler = new EventHandler(){
          @Override
          public void handleEvent(EventNotifier targetObject, EventArgs e) {
            handleThumbMouseDown((MouseEventArgs) e);
          }};
      }
      cachedThumb.addListener(UIElement.mouseDownEvent, thumbMouseDownHandler);
    } else {
      cachedThumb = null;
    }
  }

  @Override
  protected int getRawChildCount() {
    return ((chromeTree != null) ? 1 : 0) + ((cachedThumb != null) ? 1 : 0);
  }

  @Override
  protected UIElement getRawChild(int index) {
    return ((index == 0)  && (chromeTree != null)) ? chromeTree : cachedThumb;
  }

  private void handleThumbMouseDown(MouseEventArgs e) {
    captureMouse();
    moveStartValue = getValue();
    thumbStartPos = (getOrientation() == Orientation.Vertical)
        ? e.getMousePosition(this).y
        : e.getMousePosition(this).x;
    setThumbPressed(true);
    e.setHandled(true);
  }

  @Override
  protected void onMouseMove(MouseEventArgs e) {
    if (!getThumbPressed()) {
      return;
    }
    double newPos =  (getOrientation() == Orientation.Vertical)
        ? e.getMousePosition(this).y
        : e.getMousePosition(this).x;
    double newValue = moveStartValue + ((newPos - thumbStartPos)) / getValueScaleFactor();
    setValue(normalizeTrackPos(newValue));
    e.setHandled(true);
  }

  private double normalizeTrackPos(double trackPos) {
    int ticks = getTicks();
    double minValue = getMinValue();
    double maxValue = getMaxValue();
    if (ticks != 0) {
      trackPos = (trackPos - minValue) / (maxValue - minValue); // 0..1
      trackPos = (((int) ((trackPos + (0.5 / ticks)) * ticks) / ticks) *
        (maxValue - minValue)) + minValue;
    }
    trackPos = Math.min(Math.max(trackPos, minValue), maxValue);
    return trackPos;
  }

  // Handles slider position change when user clicks directly on
  // slider track instead of dragging thumb.
  @Override
  protected void onMouseDown(MouseEventArgs args) {
    UIElement trackElement = getElement(TRACK_PART_ID);
    if (trackElement != null) {
      double trackPos = 0;
      double minValue = getMinValue();
      double maxValue = getMaxValue();
      if (getOrientation() == Orientation.Vertical) {
        double trackHeight = trackElement.getLayoutRect().height;
        if (trackHeight == 0) {
          return;
        }
        trackPos = args.getMousePosition(trackElement).y / trackHeight;
        trackPos = (trackPos * (maxValue - minValue)) + minValue;
      } else {
        // horizontal slider
        double trackWidth = trackElement.getLayoutRect().width;
        if (trackWidth == 0) {
          return;
        }
        trackPos = args.getMousePosition(trackElement).x / trackWidth;
        trackPos = (trackPos * (maxValue - minValue)) + minValue;
      }
      trackPos = normalizeTrackPos(trackPos);
      setValue(trackPos);
    }
    args.setHandled(true);
  }

  @Override
  protected void onMouseUp(MouseEventArgs e) {
    if (getTicks() != 0) {
      double prevValue = getValue();
      double newValue = normalizeTrackPos(prevValue);
      if (newValue != prevValue) {
        setValue(newValue);
      }
    }
    releaseMouse();
    setThumbPressed(false);
    e.setHandled(true);
  }
}
