part of uxml;

/**
 * Provides an action to animate an element property.
 *
 * @author:ferhat@ (Ferhat Buyukkokten)
 */
class AnimateAction extends Action {

  /** Name of target element to animate */
  String target;

  /** Default duration of animation */
  static const int DEFAULT_DURATION = 250; // milliseconds
  /**
   * Actual target element instance the animation was started on. We record
   * this at the time animation is started since element tree might be modified
   * by the time reverse is called.
   */
  UxmlElement targetValue;

  /** Property to animate */
  PropertyDefinition property;

  /** Start value of animation. Current value of property is used if null. */
  Object fromValue;

  /** End value of animation */
  Object toValue;

  /** Duration of animation */
  int duration;

  /** Start delay of animation */
  int delay = 0;

  /** Name of easing function. */
  String easing = "linear";

  /** Sets or returns animation element root */
  UxmlElement startElement;

  /** Sets or returns callback to call when animation completes. */
  TaskCompleteCallback completeCallback;

  AnimateAction() : super() {
    duration = DEFAULT_DURATION;
  }

  /**
   * Starts the action.
   */
  void start(UxmlElement chromeRoot, UxmlElement control) {
    ActionData data = getActionData(control);
    if (data.actionState == ActionData.ACTION_IDLE) {
      data.targetElement = ((target != null) && (chromeRoot is UIElement)) ?
          _resolveTarget(chromeRoot, target) : control;
      if (data.targetElement == null) {
        print("severe: could not resolve target element $target");
        return;
      }
      data.startValue = data.targetElement.getProperty(property);
      if (data.startValue == PropertyDefaults.NO_DEFAULT) {
        data.startValue = null;
      }
      if (data.startValue is num) {
        num dblVal = data.startValue;
        if (dblVal.isNaN) {
          if (property == UIElement.widthProperty) {
            data.isUndefinedValue = true;
            if (data.targetElement is UIElement) {
              UIElement uiElem = data.targetElement;
              data.startValue = uiElem.layoutWidth;
            }
          } else if (property == UIElement.heightProperty) {
            data.isUndefinedValue = true;
            if (data.targetElement is UIElement) {
              UIElement uiElement = data.targetElement;
              data.startValue = uiElement.layoutHeight;
            }
          }
        }
      }
      data.actionState = ActionData.ACTION_ACTIVE;
      if (fromValue != null) {
        Action.applyPropertyValue(this, data.targetElement, property,
            fromValue);
      }
      data.task = Application.current.scheduler.schedule(delay,
          duration, updateAnimation, this, control);
    } else if (data.actionState == ActionData.ACTION_REVERSE) {
      // we are currently reversing. Cancel reverse task and schedule
      // forward.
      double currentTween = 1.0;
      if (data.task != null) {
        currentTween = data.task.currentTween;
        Application.current.scheduler.cancel(data.task);
        data.task = null;
      }
      data.task = Application.current.scheduler.scheduleInRange(0,
          (1 - currentTween) * duration, updateAnimation, this, control,
          currentTween, 1.0);
      // this is a new task so we set newTask.currentTween =
      // oldTask.currentTween
      data.task.currentTween = currentTween;
      data.actionState = ActionData.ACTION_ACTIVE;
    }
    startElement = data.targetElement;
  }

  /** Finds UxmlElement with id path defined in targetName */
  UxmlElement _resolveTarget(UxmlElement chromeRoot, String targetName) {
    if (!(chromeRoot is UIElement)) {
      return null;
    }
    UIElement uiElem = chromeRoot;
    if (targetName.indexOf(".", 0) == -1) {
      return uiElem.getElement(targetName);
    } else {
      List<String> parts = targetName.split(".");
      UxmlElement obj = uiElem.getElement(parts[0]);
      for (int i = 1; i < parts.length; i++) {
        String propName = parts[i];
        Object propVal = obj.getDefinition().findProperty(propName);
        if (propVal is PropertyDefinition) {
          obj = obj.getProperty(propVal);
        } else {
          print("Could not resolve target $targetName");
        }
      }
      return obj;
    }
  }

  /**
   * Stops animation.
   */
  void stop(UxmlElement control) {
    ActionData data = getActionData(control);
    if (data.task != null) {
      Application.current.scheduler.cancel(data.task);
      data.task = null;
    }
    data.actionState = ActionData.ACTION_IDLE;
  }

  /**
  * Reverses the action.
  */
  void reverse(UxmlElement control) {
    if (!reversible) {
      Application.current.error("Can't reverse. reversible set to false");
    }
    ActionData data = getActionData(control);
    if (data.actionState == ActionData.ACTION_ACTIVE) {
      double currentTween = 1.0;
      if (data.task != null) {
        currentTween = data.task.currentTween;
        Application.current.scheduler.cancel(data.task);
      }
      data.task = Application.current.scheduler.scheduleInRange(0,
          duration * currentTween, updateAnimationReverse, this,
          control,
          currentTween, 0.0);
      // this is a new task so we set newTask.currentTween =
      // oldTask.currentTween
      data.task.currentTween = currentTween;
      data.actionState = ActionData.ACTION_REVERSE;
    }
  }

  void updateAnimation(double tweenValue, Object tag) {
    UxmlElement control = tag;

    ActionData data = getActionData(control);
    if (data.actionState == ActionData.ACTION_ACTIVE) {
      Action.applyPropertyValue(this, data.targetElement, property,
          getTweenValue(data, tweenValue));
    }
    if (data.task.completed == true) {
      if (completeCallback != null) {
        completeCallback(this, tag);
      }
      if (reversible == false) {
        data.actionState = ActionData.ACTION_IDLE;
      }
    }
  }

  void updateAnimationReverse(double tweenValue, Object tag){
    UxmlElement control = tag;
    ActionData data = getActionData(control);
    if (tweenValue != 0.0) {
      Action.applyPropertyValue(this, data.targetElement, property,
          getTweenValue(data, tweenValue));
    } else {
      if (data.task != null) {
        Application.current.scheduler.cancel(data.task);
        data.task = null;
      }
      reversePropertyValue(this, data.targetElement, property);
      data.actionState = ActionData.ACTION_IDLE;
    }
  }

  Object getTweenValue(ActionData data, double tween) {
    if (toValue is Brush) {
      if (data.tweener == null) {
        data.tweener = new BrushTweener(data.startValue, toValue);
      }
      BrushTweener tweener = data.tweener;
      tweener.tween = tween;
      return tweener.brush;
    } if (toValue is Color) {
      Color color = Color.fromRGB(0x0);
      Color startColor = data.startValue;
      TweenUtils.tweenColor(startColor, toValue, color, tween);
      return color;
    } else if (toValue is Coord) {
      Coord pt1 = fromValue;
      Coord pt2 = toValue;
      return new Coord(pt1.x + tween * (pt2.x - pt1.x),
          pt1.y + tween * (pt2.y - pt1.y));
    } else if (toValue is num) {
      num startNumber = data.startValue == null ? 0.0 : data.startValue;
      num endNumber = toValue;
      return startNumber + (tween * (endNumber - startNumber));
    } else if (toValue is Margin) {
      Margin startMargin = data.startValue;
      Margin endMargin = toValue;
      return new Margin((startMargin.left * (1 - tween)) +
        (endMargin.left * tween),
        (startMargin.top * (1 - tween)) +
        (endMargin.top * tween),
        (startMargin.right * (1 - tween)) +
        (endMargin.right * tween),
        (startMargin.bottom * (1 - tween)) +
        (endMargin.bottom * tween));
    } else if (toValue is BorderRadius) {
      BorderRadius startValue = toValue;
      BorderRadius endValue = toValue;
      return new BorderRadius((startValue.topLeft * (1 - tween)) +
        (endValue.topLeft * tween),
        (startValue.topRight * (1 - tween)) +
        (endValue.topRight * tween),
        (startValue.bottomRight * (1 - tween)) +
        (endValue.bottomRight * tween),
        (startValue.bottomLeft * (1 - tween)) +
        (endValue.bottomLeft * tween));
    }
    return null;
  }
}
