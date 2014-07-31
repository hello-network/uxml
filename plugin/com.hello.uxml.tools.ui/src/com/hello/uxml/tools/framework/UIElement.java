package com.hello.uxml.tools.framework;

import com.hello.uxml.tools.framework.effects.Action;
import com.hello.uxml.tools.framework.effects.Effect;
import com.hello.uxml.tools.framework.events.DragEventArgs;
import com.hello.uxml.tools.framework.events.EventArgs;
import com.hello.uxml.tools.framework.events.EventDefinition;
import com.hello.uxml.tools.framework.events.EventHandler;
import com.hello.uxml.tools.framework.events.EventManager;
import com.hello.uxml.tools.framework.events.EventNotifier;
import com.hello.uxml.tools.framework.events.KeyboardEventArgs;
import com.hello.uxml.tools.framework.events.MouseEventArgs;
import com.hello.uxml.tools.framework.graphics.Filters;
import com.hello.uxml.tools.framework.graphics.UISurface;
import com.hello.uxml.tools.framework.graphics.UISurfaceTarget;

import java.util.ArrayList;
import java.util.EnumSet;
import java.util.List;

/**
 * Implements a UI element.
 *
 * UIElement is attached to a UISurface for rendering and input support.
 *
 * @author ferhat
 */
public class UIElement extends UxmlElement implements UISurfaceTarget {

  /** cached width */
  private double cachedWidth;

  /** cached height */
  private double cachedHeight;

  /** cached margins */
  private Margin cachedMargins = Margin.EMPTY;

  /** surface host */
  protected UISurface hostSurface;

  /** Layout flag constants */
  private static final int UPDATEFLAG_SIZE_DIRTY = 0x1;
  private static final int UPDATEFLAG_NEEDS_REDRAW = 0x2;
  private static final int UPDATEFLAG_NEEDS_RELAYOUT = 0x4;
  private static final int UPDATEFLAG_NEEDS_INITLAYOUT = 0x8;
  private static final int UPDATEFLAG_FILTERS = 0x10;
  // Set when MinWidth or MaxWidth are set to reduce getProperty cost.
  private static final int LAYOUTFLAG_WIDTH_CONSTRAINT = 0x20;
  private static final int LAYOUTFLAG_MINWIDTH_CONSTRAINT = 0x40;
  private static final int LAYOUTFLAG_MAXWIDTH_CONSTRAINT = 0x80;

  // Set when MinHeight or MaxHeight properties are set.
  private static final int LAYOUTFLAG_HEIGHT_CONSTRAINT = 0x100;
  private static final int LAYOUTFLAG_MINHEIGHT_CONSTRAINT = 0x200;
  private static final int LAYOUTFLAG_MAXHEIGHT_CONSTRAINT = 0x400;

  /** Last measure call availableSize. */
  private double prevMeasureAvailableWidth = -1;
  private double prevMeasureAvailableHeight;

  /** Last result from measure call.*/
  private double measuredWidth;
  private double measuredHeight;

  /** Target coordinates for element after layout */
  private Rectangle finalRect = new Rectangle();

  /** Target coordinates of last layout call */
  private Rectangle layoutRect = new Rectangle();
  /** Used to prevent relayout from being called before first proper layout is performed topdown */
  private boolean layoutRectValid = false;

  /** Element resources */
  private Resources resources;

  /** Holds layout state */
  private int layoutFlags = UPDATEFLAG_SIZE_DIRTY | UPDATEFLAG_NEEDS_REDRAW |
      UPDATEFLAG_NEEDS_INITLAYOUT;

  /** Element effects. */
  private List<Effect> effects;

  /** Cached boolean element data */
  private static final int VISIBLE_FLAG = 0x1;
  private static final int LAYOUT_VISIBLE_FLAG = 0x2;
  private static final int MOUSE_ENABLED_FLAG = 0x4;
  private static final int CLIP_CHILDREN_FLAG = 0x8;
  private static final int ENABLED_FLAG = 0x10;
  private static final int FOCUS_ENABLED_FLAG = 0x20;
  private int elementFlags = VISIBLE_FLAG | MOUSE_ENABLED_FLAG |
      ENABLED_FLAG;

  /** Visible Property Definition */
  public static PropertyDefinition visiblePropDef = PropertySystem.register("Visible",
      Boolean.class, UIElement.class,
      new PropertyData(true, EnumSet.of(PropertyFlags.Resize), new PropertyChangeListener() {
        @Override
        public void propertyChanged(PropertyChangedEvent e) {
          UIElement element = ((UIElement) e.getSource());
          boolean visible = ((Boolean) e.getNewValue()).booleanValue();
          element.setElementFlag(VISIBLE_FLAG, visible);
          if (element.hostSurface != null) {
            element.hostSurface.setVisible(visible);
          }
        }}));

  /** MouseEnabled Property Definition */
  public static PropertyDefinition mouseEnabledPropDef = PropertySystem.register("MouseEnabled",
      Boolean.class, UIElement.class,
      new PropertyData(true, EnumSet.of(PropertyFlags.None), new PropertyChangeListener() {
        @Override
        public void propertyChanged(PropertyChangedEvent e) {
          ((UIElement) e.getSource()).setElementFlag(
              MOUSE_ENABLED_FLAG, ((Boolean) e.getNewValue()).booleanValue());
        }}));

  /** Enabled Property Definition */
  public static PropertyDefinition enabledPropDef = PropertySystem.register("Enabled",
      Boolean.class, UIElement.class,
      new PropertyData(true, EnumSet.of(PropertyFlags.None), new PropertyChangeListener() {
        @Override
        public void propertyChanged(PropertyChangedEvent e) {
          ((UIElement) e.getSource()).setElementFlag(
              ENABLED_FLAG, ((Boolean) e.getNewValue()).booleanValue());
        }}));

  /** FocusEnabled Property Definition */
  public static PropertyDefinition focusEnabledPropDef = PropertySystem.register("FocusEnabled",
      Boolean.class, UIElement.class,
      new PropertyData(true, EnumSet.of(PropertyFlags.None), new PropertyChangeListener() {
        @Override
        public void propertyChanged(PropertyChangedEvent e) {
          ((UIElement) e.getSource()).setElementFlag(
              FOCUS_ENABLED_FLAG, ((Boolean) e.getNewValue()).booleanValue());
        }}));

  /** LayoutVisible Property Definition */
  public static PropertyDefinition layoutVisiblePropDef = PropertySystem.register("LayoutVisible",
      Boolean.class, UIElement.class,
      new PropertyData(true, EnumSet.of(PropertyFlags.Resize), new PropertyChangeListener() {
        @Override
        public void propertyChanged(PropertyChangedEvent e) {
          ((UIElement) e.getSource()).setElementFlag(
              LAYOUT_VISIBLE_FLAG, ((Boolean) e.getNewValue()).booleanValue());
        }}));

  /** Opacity Property Definition */
  public static PropertyDefinition opacityPropDef = PropertySystem.register("Opacity",
      Double.class, UIElement.class,
      new PropertyData(1.0, new PropertyChangeListener() {
        @Override
        public void propertyChanged(PropertyChangedEvent e) {
          UISurface surface = ((UIElement) e.getSource()).hostSurface;
          if (surface != null) {
            surface.setOpacity(((Double) e.getNewValue()).doubleValue());
          }
        }}));

  /** BlendMode Property Definition */
  public static PropertyDefinition blendModePropDef = PropertySystem.register("BlendMode",
      BlendMode.class, UIElement.class,
      new PropertyData(BlendMode.Normal, new PropertyChangeListener() {
        @Override
        public void propertyChanged(PropertyChangedEvent e) {
          UISurface surface = ((UIElement) e.getSource()).hostSurface;
          if (surface != null) {
            surface.setBlendMode((BlendMode) e.getNewValue());
          }
        }}));

  /** IsFocused property definition */
  public static PropertyDefinition isFocusedPropDef = FocusManager.isFocusedPropDef;

  /** TabIndex Property Definition */
  public static PropertyDefinition tabIndexPropDef = PropertySystem.register("TabIndex",
      Integer.class,
      UIElement.class,
      new PropertyData(0, EnumSet.of(PropertyFlags.None)));

  /** Width Property Definition */
  public static PropertyDefinition widthPropDef = PropertySystem.register("Width", Double.class,
      UIElement.class,
      new PropertyData(Double.NaN, EnumSet.of(PropertyFlags.Resize), new PropertyChangeListener() {
        @Override
        public void propertyChanged(PropertyChangedEvent e) {
          UIElement element = (UIElement) e.getSource();
          if (element.overridesProperty(widthPropDef)) {
            element.layoutFlags |= LAYOUTFLAG_WIDTH_CONSTRAINT;
          } else {
            element.layoutFlags &= ~LAYOUTFLAG_WIDTH_CONSTRAINT;
          }
          element.cachedWidth = ((Double) e.getNewValue()).doubleValue();
        }}));

  /** Height Property Definition */
  public static PropertyDefinition heightPropDef = PropertySystem.register("Height", Double.class,
      UIElement.class,
      new PropertyData(Double.NaN, EnumSet.of(PropertyFlags.Resize), new PropertyChangeListener() {
        @Override
        public void propertyChanged(PropertyChangedEvent e) {
          UIElement element = (UIElement) e.getSource();
          if (element.overridesProperty(heightPropDef)) {
            element.layoutFlags |= LAYOUTFLAG_HEIGHT_CONSTRAINT;
          } else {
            element.layoutFlags &= ~LAYOUTFLAG_HEIGHT_CONSTRAINT;
          }
          element.cachedHeight = ((Double) e.getNewValue()).doubleValue();
        }}));

  /** MinWidth Property Definition */
  public static PropertyDefinition minWidthPropDef = PropertySystem.register("MinWidth",
      Double.class,
      UIElement.class,
      new PropertyData(Double.NaN, EnumSet.of(PropertyFlags.Resize), new PropertyChangeListener() {
        @Override
        public void propertyChanged(PropertyChangedEvent e) {
          ((UIElement) e.getSource()).layoutFlags |= LAYOUTFLAG_MINWIDTH_CONSTRAINT;
        }}));

  /** MaxWidth Property Definition */
  public static PropertyDefinition maxWidthPropDef = PropertySystem.register("MaxWidth",
      Double.class,
      UIElement.class,
      new PropertyData(Double.NaN, EnumSet.of(PropertyFlags.Resize), new PropertyChangeListener() {
        @Override
        public void propertyChanged(PropertyChangedEvent e) {
          ((UIElement) e.getSource()).layoutFlags |= LAYOUTFLAG_MAXWIDTH_CONSTRAINT;
        }}));

  /** MinHeight Property Definition */
  public static PropertyDefinition minHeightPropDef = PropertySystem.register("MinHeight",
      Double.class,
      UIElement.class,
      new PropertyData(Double.NaN, EnumSet.of(PropertyFlags.Resize), new PropertyChangeListener() {
        @Override
        public void propertyChanged(PropertyChangedEvent e) {
          ((UIElement) e.getSource()).layoutFlags |= LAYOUTFLAG_MINHEIGHT_CONSTRAINT;
        }}));

  /** MaxHeight Property Definition */
  public static PropertyDefinition maxHeightPropDef = PropertySystem.register("MaxHeight",
      Double.class,
      UIElement.class,
      new PropertyData(Double.NaN, EnumSet.of(PropertyFlags.Resize), new PropertyChangeListener() {
        @Override
        public void propertyChanged(PropertyChangedEvent e) {
          ((UIElement) e.getSource()).layoutFlags |= LAYOUTFLAG_MAXHEIGHT_CONSTRAINT;
        }}));

  /** Margins Property Definition */
  public static PropertyDefinition marginsPropDef = PropertySystem.register("Margins",
      Margin.class, UIElement.class,
      new PropertyData(Margin.EMPTY, new PropertyChangeListener() {
        @Override
        public void propertyChanged(PropertyChangedEvent e) {
          ((UIElement) e.getSource()).cachedMargins = ((Margin) e.getNewValue());
        }}));

  /** HAlign Property Definition */
  public static PropertyDefinition hAlignPropDef = PropertySystem.register("HAlign", HAlign.class,
      UIElement.class,
      new PropertyData(HAlign.Fill, EnumSet.of(PropertyFlags.ParentRelayout)));

  /** VAlign Property Definition */
  public static PropertyDefinition vAlignPropDef = PropertySystem.register("VAlign", VAlign.class,
      UIElement.class,
      new PropertyData(VAlign.Fill, EnumSet.of(PropertyFlags.ParentRelayout)));

  /** ClipChildren Property Definition */
  public static PropertyDefinition clipChildrenPropDef = PropertySystem.register("ClipChildren",
      Boolean.class, UIElement.class,
      new PropertyData(true, EnumSet.of(PropertyFlags.None), new PropertyChangeListener() {
        @Override
        public void propertyChanged(PropertyChangedEvent e) {
          ((UIElement) e.getSource()).setElementFlag(
              CLIP_CHILDREN_FLAG, ((Boolean) e.getNewValue()).booleanValue());
          }
      }));

  /** Filters Property Definition */
  public static PropertyDefinition filtersPropDef = PropertySystem.register("Filters",
      Filters.class, UIElement.class,
      new PropertyData(null, new PropertyChangeListener() {
        @Override
        public void propertyChanged(PropertyChangedEvent e) {
          ((UIElement) e.getSource()).filtersChangedHandler();
        }}));

  /** Mask Property Definition */
  public static PropertyDefinition maskPropDef = PropertySystem.register("Mask",
      UIElement.class, UIElement.class,
      new PropertyData(null, new PropertyChangeListener() {
        @Override
        public void propertyChanged(PropertyChangedEvent e) {
          ((UIElement) e.getSource()).maskChangedHandler();
        }}));

  /** ToolTip Property Definition */
  public static PropertyDefinition toolTipPropDef = PropertySystem.register("ToolTip",
      UIElement.class, UIElement.class,
      new PropertyData(null, new PropertyChangeListener() {
        @Override
        public void propertyChanged(PropertyChangedEvent e) {
          ((UIElement) e.getSource()).tooltipChangedHandler();
        }}));

  /** Transform Property Definition */
  public static PropertyDefinition transformPropDef = PropertySystem.register("Transform",
      Transform.class, UIElement.class,
      new PropertyData(null, EnumSet.of(PropertyFlags.None)));

  /** LayoutTransform Property Definition */
  public static PropertyDefinition layoutTransformPropDef = PropertySystem.register(
      "LayoutTransform", Transform.class, UIElement.class,
      new PropertyData(null, EnumSet.of(PropertyFlags.None)));

  /** IsMouseOver property definition */
  public static PropertyDefinition isMouseOverPropDef = PropertySystem.register("IsMouseOver",
      Boolean.class, UIElement.class,
      new PropertyData(false, EnumSet.of(PropertyFlags.None), new PropertyChangeListener() {
        @Override
        public void propertyChanged(PropertyChangedEvent e) {
          if (((Boolean) e.getNewValue())) {
            ((UIElement) e.getSource()).onMouseEnter(null);
          } else {
            ((UIElement) e.getSource()).onMouseExit(null);
          }
        }}));

  /** State Property Definition */
  public static PropertyDefinition statePropDef = PropertySystem.register("State", String.class,
      UIElement.class, new PropertyData("", EnumSet.of(PropertyFlags.Attached,
          PropertyFlags.Inherit)));

  /** FocusChrome property definition. Holds chrome to use for indicating focus. */
  public static PropertyDefinition focusChromePropDef = PropertySystem.register("FocusChrome",
      Chrome.class, UIElement.class,
      new PropertyData(null, EnumSet.of(PropertyFlags.None)));

  // EVENT DEFINITIONS
  /** Closed event definition */
  public static EventDefinition closedEvent = EventManager.register("Closed", UIElement.class,
      EventArgs.class, UIElement.class, null);

  /** MouseDown event definition */
  public static EventDefinition mouseDownEvent = EventManager.register(
      "MouseDown", UIElement.class, MouseEventArgs.class, UIElement.class, new EventHandler() {
        @Override
        public void handleEvent(EventNotifier targetObject, EventArgs e) {
          mouseEventHandler(targetObject, (MouseEventArgs) e);
        }
      });

  /** MouseUp event definition */
  public static EventDefinition mouseUpEvent = EventManager.register(
      "MouseUp", UIElement.class, MouseEventArgs.class, UIElement.class, new EventHandler() {
        @Override
        public void handleEvent(EventNotifier targetObject, EventArgs e) {
          mouseEventHandler(targetObject, (MouseEventArgs) e);
        }
      });
  /** MouseMove event definition */
  public static EventDefinition mouseMoveEvent = EventManager.register(
      "MouseMove", UIElement.class, MouseEventArgs.class, UIElement.class, new EventHandler() {
        @Override
        public void handleEvent(EventNotifier targetObject, EventArgs e) {
          mouseEventHandler(targetObject, (MouseEventArgs) e);
        }
      });
  /** MouseEnter event definition */
  public static EventDefinition mouseEnterEvent = EventManager.register(
      "MouseEnter", UIElement.class, MouseEventArgs.class, UIElement.class, new EventHandler() {
        @Override
        public void handleEvent(EventNotifier targetObject, EventArgs e) {
          mouseEventHandler(targetObject, (MouseEventArgs) e);
        }
      });
  /** MouseUp event definition */
  public static EventDefinition mouseExitEvent = EventManager.register(
      "MouseExit", UIElement.class, MouseEventArgs.class, UIElement.class, new EventHandler() {
        @Override
        public void handleEvent(EventNotifier targetObject, EventArgs e) {
          mouseEventHandler(targetObject, (MouseEventArgs) e);
        }
      });

  /** KeyDown event definition */
  public static EventDefinition keyDownEvent = EventManager.register(
      "KeyDown", UIElement.class, KeyboardEventArgs.class, UIElement.class, new EventHandler() {
        @Override
        public void handleEvent(EventNotifier targetObject, EventArgs e) {
          keyEventHandler(targetObject, (KeyboardEventArgs) e);
        }
      });

  /** DragStart event definition */
  public static EventDefinition  dragStartEvent = EventManager.register(
      "DragStart", UIElement.class, DragEventArgs.class, UIElement.class, new EventHandler() {
        @Override
        public void handleEvent(EventNotifier targetObject, EventArgs e) {
          dragEventHandler(targetObject, e);
        }
      });

  /** Drag event definition */
  public static EventDefinition dragEvent = EventManager.register(
      "Drag", UIElement.class, DragEventArgs.class, UIElement.class, new EventHandler() {
        @Override
        public void handleEvent(EventNotifier targetObject, EventArgs e) {
          dragEventHandler(targetObject, e);
        }
      });

  /** DragEnd event definition */
  public static EventDefinition dragEndEvent = EventManager.register(
      "DragEnd", UIElement.class, DragEventArgs.class, UIElement.class, new EventHandler() {
        @Override
        public void handleEvent(EventNotifier targetObject, EventArgs e) {
          dragEventHandler(targetObject, e);
        }
      });

  /** DragEnter event definition */
  public static EventDefinition dragEnterEvent = EventManager.register(
      "DragEnter", UIElement.class, DragEventArgs.class, UIElement.class, new EventHandler() {
        @Override
        public void handleEvent(EventNotifier targetObject, EventArgs e) {
          dragEventHandler(targetObject, e);
        }
      });

  /** DragOver event definition */
  public static EventDefinition dragOverEvent = EventManager.register(
      "DragOver", UIElement.class, DragEventArgs.class, UIElement.class, new EventHandler() {
        @Override
        public void handleEvent(EventNotifier targetObject, EventArgs e) {
          dragEventHandler(targetObject, e);
        }
      });

  /** DragLeave event definition */
  public static EventDefinition dragLeaveEvent = EventManager.register(
      "DragLeave", UIElement.class, DragEventArgs.class, UIElement.class, new EventHandler() {
        @Override
        public void handleEvent(EventNotifier targetObject, EventArgs e) {
          dragEventHandler(targetObject, e);
        }
      });

  /** Drag drop event definition */
  public static EventDefinition dropEvent = EventManager.register(
      "Drop",  UIElement.class, DragEventArgs.class, UIElement.class, new EventHandler() {
        @Override
        public void handleEvent(EventNotifier targetObject, EventArgs e) {
          dragEventHandler(targetObject, e);
        }
      });

  /** StateChanged event definition */
  public static EventDefinition stateChangedEvent = EventManager.register(
      "StateChanged", UIElement.class, EventArgs.class, UIElement.class, null);

  /** KeyUp event definition */
  public static EventDefinition keyUpEvent = EventManager.register(
      "KeyUp", UIElement.class, KeyboardEventArgs.class, UIElement.class, new EventHandler() {
        @Override
        public void handleEvent(EventNotifier targetObject, EventArgs e) {
          keyEventHandler(targetObject, (KeyboardEventArgs) e);
        }
      });

  /** LayoutChanged event definition */
  public static EventDefinition layoutChangedEvent = EventManager.register(
      "LayoutChanged", UIElement.class, EventArgs.class, UIElement.class, null);

  /**
   * Constructor.
   */
  public UIElement() {
  }

  /**
   * Returns parent element.
   */
  @Override
  public UIElement getParent() {
    return (UIElement) parent;
  }

  /**
  * Sets/returns visible property.
  */
  public void setVisible(boolean value) {
    setProperty(visiblePropDef, value);
  }

  public boolean getVisible() {
    return getElementFlag(VISIBLE_FLAG);
  }

  /**
   * Sets/returns if mouse events are handled by element.
   */
   public void setMouseEnabled(boolean value) {
     setProperty(mouseEnabledPropDef, value);
   }

   public boolean getMouseEnabled() {
     return getElementFlag(MOUSE_ENABLED_FLAG);
   }

   /**
    * Sets/returns if element is enabled for input.
    */
   public void setEnabled(boolean value) {
     setProperty(enabledPropDef, value);
   }

   public boolean getEnabled() {
     return getElementFlag(ENABLED_FLAG);
   }

  /**
   * Sets/returns layoutVisible property.
   */
   public void setLayoutVisible(boolean value) {
     setProperty(layoutVisiblePropDef, value);
   }

   public boolean getLayoutVisible() {
     return getElementFlag(LAYOUT_VISIBLE_FLAG);
   }

   /**
    * Sets/returns opacity.
    */
   public void setOpacity(double value) {
     setProperty(opacityPropDef, value);
   }

   public double getOpacity() {
     return ((Double) getProperty(opacityPropDef)).doubleValue();
   }

   /**
    * Sets/returns blend mode .
    */
   public void setBlendMode(BlendMode value) {
     setProperty(blendModePropDef, value);
   }

   public BlendMode getBlendMode() {
     return (BlendMode) getProperty(blendModePropDef);
   }

  /**
   * Sets/returns width property.
   */
  public void setWidth(double value) {
    setProperty(widthPropDef, value);
  }

  public double getWidth() {
    return cachedWidth;
  }

  /**
   * Sets/returns height property.
   */
  public void setHeight(double value) {
    setProperty(heightPropDef, value);
  }

  public double getHeight() {
    return cachedHeight;
  }

  /**
   * Sets/returns minimum width property.
   */
  public void setMinWidth(double value) {
    setProperty(minWidthPropDef, value);
  }

  public double getMinWidth() {
    return ((Double) getProperty(minWidthPropDef)).doubleValue();
  }

  /**
   * Sets/returns maximum width property.
   */
  public void setMaxWidth(double value) {
    setProperty(maxWidthPropDef, value);
  }

  public double getMaxWidth() {
    return ((Double) getProperty(maxWidthPropDef)).doubleValue();
  }

  /**
   * Sets/returns minimum height property.
   */
  public void setMinHeight(double value) {
    setProperty(minHeightPropDef, value);
  }

  public double getMinHeight() {
    return ((Double) getProperty(minHeightPropDef)).doubleValue();
  }

  /**
   * Sets/returns maximum height property.
   */
  public void setMaxHeight(double value) {
    setProperty(maxHeightPropDef, value);
  }

  public double getMaxHeight() {
    return ((Double) getProperty(maxHeightPropDef)).doubleValue();
  }

  /**
   * Sets/returns margins.
   */
  public void setMargins(Margin value) {
    setProperty(marginsPropDef, value);
  }

  public Margin getMargins() {
    return cachedMargins;
  }

  /**
   * Sets/returns horizontal alignment.
   */
  public void setHAlign(HAlign alignment) {
    setProperty(hAlignPropDef, alignment);
  }

  public HAlign getHAlign() {
    return (HAlign) getProperty(hAlignPropDef);
  }

  /**
   * Sets/returns vertical alignment.
   */
  public void setVAlign(VAlign alignment) {
    setProperty(vAlignPropDef, alignment);
  }

  public VAlign getVAlign() {
    return (VAlign) getProperty(vAlignPropDef);
  }

  /**
   * Sets/returns tab index property.
   */
  public void setTabIndex(int value) {
    setProperty(tabIndexPropDef, value);
  }

  public int getTabIndex() {
    return ((Integer) getProperty(tabIndexPropDef)).intValue();
  }

  /**
   * Returns last width result from measure call.
   */
  public double getMeasuredWidth() {
    return measuredWidth;
  }

  /**
   * Returns last width result from measure call.
   */
  public double getMeasuredHeight() {
    return measuredHeight;
  }

  /**
   * Sets or returns mask element.
   */
  public UIElement getMask() {
    return (UIElement) getProperty(maskPropDef);
  }

  public void setMask(UIElement value) {
    setProperty(maskPropDef, value);
  }

  /**
   * Sets or returns tooltip element.
   */
  public UIElement getToolTip() {
    return (UIElement) getProperty(toolTipPropDef);
  }

  public void setToolTip(UIElement value) {
    setProperty(toolTipPropDef, value);
  }

  /**
   * Sets or returns Filters list for element.
   */
  public Filters getFilters() {
    return (Filters) getProperty(filtersPropDef);
  }
  @CollectionNode(isPreAllocated = false)
  public void setFilters(Filters value) {
    setProperty(filtersPropDef, value);
  }

  /**
   * Returns true if mouse is over the element area.
   */
  public boolean getIsMouseOver() {
    return (Boolean) getProperty(isMouseOverPropDef);
  }

  /**
   * Sets or returns whether element clips children.
   */
  public void setClipChildren(boolean clip) {
    setProperty(clipChildrenPropDef, clip);
  }

  public boolean getClipChildren() {
     return getElementFlag(CLIP_CHILDREN_FLAG);
  }

  /**
   * Sets or returns whether element has input focus.
   */
  public void setIsFocused(boolean clip) {
    setProperty(isFocusedPropDef, clip);
  }

  public boolean getIsFocused() {
     return ((Boolean) getProperty(isFocusedPropDef)).booleanValue();
  }

  /**
   * Sets or returns state.
   */
  public void setState(String value) {
    setProperty(statePropDef, value);
  }

  public String getState() {
     return (String) getProperty(statePropDef);
  }

  /**
   * Sets or returns whether element can receive input focus.
   */
  public void setFocusEnabled(boolean enable) {
    setProperty(focusEnabledPropDef, enable);
  }

  public boolean getFocusEnabled() {
     return getElementFlag(FOCUS_ENABLED_FLAG);
  }

  /**
   * Returns a list of effects.
   */
  public List<Effect> getEffects() {
    if (effects == null) {
      effects = new ArrayList<Effect>();
    }
    return effects;
  }

  /**
   * Measures and returns the size of an element.
   * Subclasses should NOT override this method.
   */
  public void measure(double availableWidth, double availableHeight) {
    // Optimization: If size is not dirty and we are querying with prior size
    // just return previous result.
    boolean isDirty = ((layoutFlags & UPDATEFLAG_SIZE_DIRTY) != 0);
    if (!isDirty) {
      return;
    }
    if (isDirty || (availableWidth != prevMeasureAvailableWidth) ||
        (availableHeight != prevMeasureAvailableHeight)) {
      prevMeasureAvailableWidth = availableWidth;
      prevMeasureAvailableHeight = availableHeight;
      if ((getVisible() == false) && (getLayoutVisible() == false)) {
        measuredWidth = 0;
        measuredHeight = 0;
      } else {
        boolean isWidthDefined = (layoutFlags & LAYOUTFLAG_WIDTH_CONSTRAINT) != 0;
        boolean isHeightDefined = (layoutFlags & LAYOUTFLAG_HEIGHT_CONSTRAINT) != 0;

        if (cachedMargins != Margin.EMPTY) {
          measuredWidth += cachedMargins.getLeft() + cachedMargins.getRight();
          measuredHeight += cachedMargins.getTop() + cachedMargins.getBottom();
        }

        if (isWidthDefined) {
          availableWidth = cachedWidth + cachedMargins.getLeft() + cachedMargins.getRight();
        }
        if (isHeightDefined) {
          availableHeight = cachedHeight + cachedMargins.getTop() + cachedMargins.getBottom();
        }

        onMeasure(availableWidth, availableHeight);

        if (isWidthDefined) {
          measuredWidth = cachedWidth;
        }
        if (isHeightDefined) {
          measuredHeight = cachedHeight;
        }

        if (Double.isNaN(measuredWidth) || Double.isNaN(measuredHeight)) {
          throw new Error("Invalid measure value");
        }

        if (cachedMargins != Margin.EMPTY) {
          measuredWidth += cachedMargins.getLeft() + cachedMargins.getRight();
          measuredHeight += cachedMargins.getTop() + cachedMargins.getBottom();
        }

        if ((layoutFlags & LAYOUTFLAG_MINWIDTH_CONSTRAINT) != 0) {
          double widthVal = getMinWidth();
          if (measuredWidth < widthVal) {
            measuredWidth = widthVal;
          }
        }

        if ((layoutFlags & LAYOUTFLAG_MAXWIDTH_CONSTRAINT) != 0) {
          double widthVal = getMaxWidth();
          if (measuredWidth > widthVal) {
            measuredWidth = widthVal;
          }
        }

        if ((layoutFlags & LAYOUTFLAG_MINHEIGHT_CONSTRAINT) != 0) {
          double heightVal = getMinHeight();
          if (measuredHeight < heightVal) {
            measuredHeight = heightVal;
          }
        }
        if ((layoutFlags & LAYOUTFLAG_MAXHEIGHT_CONSTRAINT) != 0) {
          double heightVal = getMaxHeight();
          if (measuredHeight > heightVal) {
            measuredHeight = heightVal;
          }
        }
      }
      layoutFlags &= ~UPDATEFLAG_SIZE_DIRTY;
    }
  }

  /**
   * Provides measure override for subclasses.
   */
  protected void onMeasure(double availWidth, double availableHeight) {
    setMeasuredDimension(0, 0);
  }

  /**
   * Sets measured width,height in an onMeasure override.
   */
  protected void setMeasuredDimension(double width, double height) {
    measuredWidth = width;
    measuredHeight = height;
  }

  void relayout() {
    if (layoutRectValid) {
      layout(layoutRect);
    }
  }
  /** Performs final layout of element into target rectangle */
  // TODO(ferhat): deprecate this version of layout call.
  public void layout(Rectangle targetRect) {
    layout(targetRect.x, targetRect.y, targetRect.width, targetRect.height);
  }

  /** Performs final layout of element into target rectangle */
  public void layout(double targetX, double targetY, double targetWidth, double targetHeight) {
    if (getVisible() == false && getLayoutVisible() == false) {
      return;
    }

    boolean isDirty = (layoutFlags &
        (UPDATEFLAG_NEEDS_RELAYOUT | UPDATEFLAG_NEEDS_INITLAYOUT)) != 0;

    boolean targetRectDirty = (targetWidth != layoutRect.width) ||
        (targetHeight != layoutRect.height) || (targetX != layoutRect.x) ||
        (targetY != layoutRect.y);

    if (isDirty || targetRectDirty) {
      layoutFlags &= ~(UPDATEFLAG_NEEDS_RELAYOUT | UPDATEFLAG_NEEDS_INITLAYOUT);

      // Cache layout size
      layoutRect.x = targetX;
      layoutRect.y = targetY;
      layoutRect.width = targetWidth;
      layoutRect.height = targetHeight;

      layoutRectValid = true;

      if (hostSurface != null) {
        double measuredInnerWidth = measuredWidth;
        double measuredInnerHeight = measuredHeight;
        if (cachedMargins != Margin.EMPTY) {
          finalRect = new Rectangle(targetX + cachedMargins.getLeft(),
              targetY + cachedMargins.getTop(),
              targetWidth - cachedMargins.getLeft() - cachedMargins.getRight(),
              targetHeight - cachedMargins.getTop() - cachedMargins.getBottom());
          measuredInnerWidth -= cachedMargins.getLeft() - cachedMargins.getRight();
          measuredInnerHeight -= cachedMargins.getTop() - cachedMargins.getBottom();
        } else {
          finalRect = new Rectangle(targetX, targetY, targetWidth, targetHeight);
        }
        if (finalRect.width > measuredInnerWidth) {
          HAlign hAlign = this.getHAlign();
          switch (hAlign) {
          case Left:
            finalRect.width = measuredInnerWidth;
            break;
          case Center:
            finalRect.x += (finalRect.width - measuredInnerWidth) / 2;
            finalRect.width = measuredInnerWidth;
            break;
          case Right:
            finalRect.x = finalRect.getRight() - measuredInnerWidth;
            finalRect.width = measuredInnerWidth;
            break;
          case Fill:
            break;
          }
        }
        if (finalRect.height > measuredInnerHeight) {
          VAlign vAlign = this.getVAlign();
          switch (vAlign) {
          case Top:
            finalRect.height = measuredInnerHeight;
            break;
          case Center:
            finalRect.y += (finalRect.height - measuredInnerHeight) / 2;
            finalRect.height = measuredInnerHeight;
            break;
          case Bottom:
            finalRect.y = finalRect.getBottom() - measuredInnerHeight;
            finalRect.height = measuredInnerHeight;
            break;
          case Fill:
            break;
          }
        }
        hostSurface.setLayout(finalRect);
        invalidateDraw();
      }
      onLayout(finalRect);
      if (hasListener(layoutChangedEvent)) {
        EventArgs layoutChangedArgs = new EventArgs();
        layoutChangedArgs.setEvent(layoutChangedEvent);
        layoutChangedArgs.setSource(this);
        notifyListeners(layoutChangedEvent, layoutChangedArgs);
      }
    }
  }

  /**
   * Returns final location after element layout.
   */
  public Rectangle getLayoutRect() {
    return finalRect;
  }

  void redraw() {
    if ((layoutFlags & UPDATEFLAG_NEEDS_REDRAW) != 0) {
      if (hostSurface != null) {
        onRedraw(hostSurface);
        hostSurface.updateView();
        layoutFlags &= ~UPDATEFLAG_NEEDS_REDRAW;
      }
    }
  }

  /**
   * Remeasure element using last call params. This is called by UpdateQueue.
   */
  void remeasure() {
    if (prevMeasureAvailableWidth != -1) {
      measure(prevMeasureAvailableWidth, prevMeasureAvailableHeight);
    }
  }

  /**
   * Returns true if mouse is over the element's bounding box.
   */
  public boolean hitTestBoundingBox(double screenX, double screenY) {

    // Convert from screen to local coordinates.
    // We're not calling screenToLocal since mousemove will call this
    // a lot and we don't want to generate a ton of Point objects as
    // the mouse is moving
    screenX -= finalRect.x;
    screenY -= finalRect.y;
    UIElement element = (UIElement) parent;
    while (element != null) {
      screenX -= element.layoutRect.x;
      screenY -= element.layoutRect.y;
      element = (UIElement) (element.parent);
    }
    return ((screenX >= 0) && (screenX < finalRect.width) && (screenY >= 0) &&
      (screenY < finalRect.height));
  }

  /**
   * Provides an override for subclasses to do custom painting.
   */
  protected void onRedraw(UISurface surface) {
  }

  /**
   * Provides layout override for subclasses.
   */
  protected void onLayout(Rectangle layoutRectangle) {
  }

  /**
   * Sets mouse capture to element.
   */
   protected void captureMouse() {
     Application.getCurrent().setMouseCapture(this);
   }

   /**
   * Releases mouse capture from element.
   */
   protected void releaseMouse() {
     Application.getCurrent().releaseMouseCapture();
   }

   /**
   * Routes an event starting at this element.
   */
   public void routeEvent(EventArgs eventArgs) {
     UIElement parentElement = (UIElement) parent;
     raiseEvent(eventArgs);
     while ((!eventArgs.getHandled()) && (parentElement != null)) {
       parentElement.raiseEvent(eventArgs);
       parentElement = (UIElement) parentElement.parent;
     }
   }

   protected void raiseEvent(EventArgs eventArgs) {
     eventArgs.getEvent().callHandler(this, eventArgs);
     notifyListeners(eventArgs.getEvent(), eventArgs);
   }


  public void initSurface(UISurface parentSurface) {
    hostSurface = parentSurface.createChildSurface();
    hostSurface.setTarget(this);
    if (!getVisible()) {
      hostSurface.setVisible(false);
    }
    int childCount = getRawChildCount();
    for (int i = 0; i < childCount; ++i) {
      getRawChild(i).initSurface(hostSurface);
    }

 // Initialize effects
    if ((effects != null) && (!effects.isEmpty())) {
      for (Effect effect : effects) {
        UIElement targetElement = this;
        if (effect.getSource() == null) {
          targetElement.addListener(effect.getProperty(), new EventHandler() {
            @Override
            public void handleEvent(EventNotifier targetObject, EventArgs e) {
            }
          });
        } else {
          if (!(effect.getSource() instanceof UxmlElement)) {
            effect.setSource(getElement((String) effect.getSource()));
            effect.setTargetElement(targetElement);
          }
          if (effect.getSource() != null) {
            ((UxmlElement) effect.getSource()).addListener(effect.getProperty(),
              new EventHandler() {
                @Override
                public void handleEvent(EventNotifier targetObject, EventArgs e) {
                }
             });
          }
        }
      }
    }

    UpdateQueue.updateDrawing(this);
  }

  // Runs effect actions based on property changes. internal for Chrome.
  static void processEffectPropertyChange(List<Effect> effectsColl, PropertyChangedEvent e) {
    for (Effect effect : effectsColl) {
      if (effect.getProperty().equals(e.getProperty())) {
        if ((effect.getValue().equals(e.getNewValue())) && (effect.getActions() != null)) {
          for (Action action : effect.getActions()) {
            action.start(effect.getTargetElement() == null ?
              (UxmlElement) e.getSource() : effect.getTargetElement(), (UxmlElement) e.getSource());
          }
        } else if (effect.getActions().get(0).getIsActive((UxmlElement) e.getSource())) {
          for (int reverseIndex = 0; reverseIndex < effect.getActions().size();
            ++reverseIndex) {
            Action action = effect.getActions().get(reverseIndex);
            if (action.getReversible()) {
              action.reverse((UIElement) e.getSource());
            }
          }
        }
      }
    }
  }

  /**
   * Disposes active surface for element.
   */
  public void close() {
    if (hostSurface != null) {
      hostSurface.close();
      hostSurface = null;
    }
    parent = null;
  }

  /**
   * Returns hosting surface for element.
   */
  public UISurface getSurface() {
    return hostSurface;
  }

  /**
   * Returns raw child count.
   *
   * <p>Subclasses should override to expose visible children.
   */
  protected int getRawChildCount() {
    return 0;
  }

  /**
   * Returns raw child collection.
   *
   * <p>Subclassess should override to expose visible children.
   */
  protected UIElement getRawChild(int index) {
    throw new IndexOutOfBoundsException();
  }

  /**
   * Adds a visible child.
   */
  protected void addRawChild(UIElement child) {
    child.parent = this;
    if ((child.hostSurface == null) && (this.hostSurface != null)) {
      child.initSurface(hostSurface);
    }
    child.invalidateSize();
    invalidateSize();
    invalidateLayout();
  }

  /**
   * Removes a visible child.
   */
  protected void removeRawChild(UIElement child) {
    child.close();
  }

  /**
   * Finds child element with id.
   */
  public UIElement getElement(String id) {
    UIElement res;
    if (getId().equals(id)) {
      return this;
    }
    int rawChildCount = getRawChildCount();
    for (int i = 0; i < rawChildCount; ++i) {
      res = getRawChild(i);
      res = res.getElement(id);
      if (res != null) {
        return res;
      }
    }
    return null;
  }

  @Override
  protected void onPropertyChanged(PropertyDefinition propDef, Object oldValue, Object newValue) {
    PropertyData propData = propDef.getPropData(this.getClass());
    if (propData != null) {
      EnumSet<PropertyFlags> flags = propData.getFlags();
      if (flags.contains(PropertyFlags.Resize)) {
        invalidateSize();
      }
      if (flags.contains(PropertyFlags.Relayout)) {
        invalidateLayout();
      }
      if (flags.contains(PropertyFlags.Redraw)) {
        invalidateDraw();
      }
      if (parent != null) {
        if (flags.contains(PropertyFlags.ParentRelayout)) {
          ((UIElement) parent).invalidateLayout();
        }
        if (flags.contains(PropertyFlags.ParentResize)) {
          ((UIElement) parent).invalidateSize();
        }
      }
    }
  }

  /**
   * Called from property system when filters need to be updated on attached UISurface.
   */
  private void filtersChangedHandler() {
    layoutFlags |= UPDATEFLAG_FILTERS;
    UpdateQueue.updateDrawing(this);
  }

  private void maskChangedHandler() {
    // TODO(ferhat) forward change to UISurface
  }

  private void tooltipChangedHandler() {
    // TODO(ferhat): start listening to mouseover event to add/remove overlay.
  }

  public void invalidateLayout() {
    layoutFlags |= UPDATEFLAG_SIZE_DIRTY;
    layoutFlags |= UPDATEFLAG_NEEDS_RELAYOUT;
    UpdateQueue.updateLayout(this);
  }

  /**
   * Invalidates size of element and queues for remeasure.
   */
  public void invalidateSize() {
    layoutFlags |= UPDATEFLAG_SIZE_DIRTY;
    UpdateQueue.updateMeasure(this);
  }

  /**
   * Invalidates drawing of element.
   */
  public void invalidateDraw() {
    layoutFlags |= UPDATEFLAG_NEEDS_REDRAW;
  }

  /** Converts stage coordinate to local */
  public Point screenToLocal(Point p) {
    Point localPoint = new Point(p.x, p.y);
    UIElement parentElement = (UIElement) parent;
    while (parentElement != null) {
      localPoint.x -= layoutRect.x;
      localPoint.y -= layoutRect.y;
      parentElement = (UIElement) (parentElement.parent);
    }
    return localPoint;
  }

  /** Converts local coordinate to screen */
  public Point localToScreen(Point p) {
    Point localPoint = new Point(p.x, p.y);
    UIElement parentElement = this;
    while (parentElement != null) {
      localPoint.x += parentElement.layoutRect.x;
      localPoint.y += parentElement.layoutRect.y;
      parentElement = (UIElement) (parentElement.parent);
    }
    return localPoint;
  }

  private static void mouseEventHandler(EventNotifier target, MouseEventArgs args) {
    switch (args.getEventType()) {
      case MouseEventArgs.MOUSE_DOWN:
        ((UIElement) target).onMouseDown(args);
        break;
      case MouseEventArgs.MOUSE_UP:
        ((UIElement) target).onMouseUp(args);
        break;
      case MouseEventArgs.MOUSE_MOVE:
        ((UIElement) target).onMouseMove(args);
        break;
      case MouseEventArgs.MOUSE_ENTER:
        ((UIElement) target).onMouseEnter(args);
        break;
      case MouseEventArgs.MOUSE_EXIT:
        ((UIElement) target).onMouseExit(args);
        break;
    }
  }

  private static void keyEventHandler(EventNotifier target, KeyboardEventArgs args) {
    switch (args.getEventType()) {
      case KeyboardEventArgs.KEY_DOWN:
        ((UIElement) target).onKeyDown(args);
        break;
      case KeyboardEventArgs.KEY_UP:
        ((UIElement) target).onKeyUp(args);
        break;
    }
  }

  protected void onMouseDown(MouseEventArgs e) {
  }

  protected void onMouseMove(MouseEventArgs e) {
  }

  protected void onMouseUp(MouseEventArgs e) {
  }

  protected void onMouseEnter(MouseEventArgs e) {
    setProperty(isMouseOverPropDef , true);
  }

  protected void onMouseExit(MouseEventArgs e) {
    setProperty(isMouseOverPropDef , false);
  }

  protected void onKeyDown(KeyboardEventArgs e) {
  }

  protected void onKeyUp(KeyboardEventArgs e) {
  }

  protected void onDragEnter(DragEventArgs dragDropArgs) {
  }

  protected void onDragLeave(DragEventArgs dragDropArgs) {
  }

  protected void onDragOver(DragEventArgs dragDropArgs) {
  }

  protected void onDrop(DragEventArgs dragDropArgs) {
  }

  /**
   * handles UISurfaceTarget updates.
   */
  @Override
  public void surfaceContentUpdated() {
  }

  /**
   * Returns resources collection.
   */
  public Resources getResources() {
     if (resources == null) {
       resources = new Resources();
     }
     return resources;
  }

  /**
   * Searches for a resource by key using element tree.
   */
  public Object findResource(String key) {
    return findResource(key, null);
  }

  /**
   * Searches for a resource by key using element tree.
   */
  public Object findResource(String key, String interfaceName) {
    Object res;
    if (resources != null) {
      if (interfaceName != null) {
        Resources intf = (Resources) resources.findResource(interfaceName);
        if (intf != null) {
          res = intf.findResource(key);
          if (res != null) {
            return res;
          }
        }
      }
      res = resources.findResource(key);
      if (res != null) {
        return res;
      }
    }
    UIElement parentElement = (UIElement) parent;
    if (parentElement == null) {
      return Application.findResource(key, interfaceName);
    }
    return parentElement.findResource(key, interfaceName);
  }

  /**
   * Searches for a resource by class using element tree.
   */
  public Object findResource(Class<?> key) {
    if (resources != null) {
      Object res = resources.findResource(key);
      if (res != null) {
        return res;
      }
    }
    UIElement parentElement = (UIElement) parent;
    if (parentElement == null) {
      return Application.getCurrent().getResources().findResource(key);
    }
    return parentElement.findResource(key);
  }

  /**
   * Returns closest parent overlay container.
   */
  protected OverlayContainer getOverlayContainer() {
    if (parent != null) {
      return ((UIElement) parent).getOverlayContainer();
    }
    return null;
  }

  /**
   * Adds an overlay to this element.
   */
  public void addOverlay(UIElement overlay) {
    Point globalPos = localToScreen(new Point(0, 0));
    Canvas.setChildLeft(overlay, globalPos.x);
    Canvas.setChildTop(overlay, globalPos.y);
    getOverlayContainer().add(overlay);
  }
  /**
   * Removes overlay from element.
   */
   public void removeOverlay(UIElement overlay) {
     getOverlayContainer().remove(overlay);
   }

  /**
   * Called when transform or layoutTransform changes.
   */
  void onTransformChanged(Transform changedTransform) {
  }

  private void setElementFlag(int flag, boolean value) {
    elementFlags = (elementFlags & (~flag));
    if (value) {
      elementFlags |= flag;
    }
  }

  private boolean getElementFlag(int flag) {
    return (elementFlags & flag) != 0;
  }

  /**
   * Sets or returns chrome to use for focus indicator.
   */
  public void setFocusChrome(Chrome chrome) {
    setProperty(focusChromePropDef, chrome);
  }

  public Chrome getFocusChrome() {
    return (Chrome) getProperty(focusChromePropDef);
  }

  /** Returns whether layout has been initialized. */
  public boolean getIsLayoutInitialized() {
    return (layoutFlags & UPDATEFLAG_NEEDS_INITLAYOUT) == 0;
  }

  protected void setChildDepth(UIElement child, int prevIndex,
      int newIndex) {
    if (hostSurface != null) {
      hostSurface.setChildDepth(child.hostSurface, newIndex);
    }
  }

  private static void dragEventHandler(EventNotifier element, EventArgs args) {
    UIElement target = (UIElement) element;
    if (!target.getEnabled()) {
      return;
    }
    switch (((DragEventArgs) args).getEventType()) {
      case MouseEventArgs.MOUSE_MOVE:
        target.onDragOver((DragEventArgs) args);
      break;
      case MouseEventArgs.MOUSE_ENTER:
        target.onDragEnter((DragEventArgs) args);
        args.setHandled(true); // prevent event from bubbling up.
      break;
      case MouseEventArgs.MOUSE_EXIT:
        target.onDragLeave((DragEventArgs) args);
        args.setHandled(true); // prevent event from bubbling up.
      break;
    }
    if (args.getEvent() == dropEvent) {
      target.onDrop((DragEventArgs) args);
    }
  }
}
