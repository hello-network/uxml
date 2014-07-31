package com.hello.uxml.tools.framework;

/**
 * Implements control for creating progress indicators.
 *
 * For easy layout, percentComplete, percentRemaining properties are exposed
 * for control chrome elements to bind to.
 *
 * For unbounded progress indicators such as a wait spinner, this class
 * provides a cycle property when set to true will cycle the value from min to maxValue.
 *
 * @author ferhat
 */
public class ProgressControl extends ValueRangeControl {

  // Default amount of time it takes for value to cycle from min to max.
  private static final int DEFAULT_CYCLE_TIME = 1000;

  // Default amount of time before value cycling begins.
  private static final int DEFAULT_CYCLE_DELAY = 0;

  private static final int DEFAULT_STEP_COUNT = 0;

  private static final double EPSILON = 0.00000001;

  /** PercentComplete property definition. */
  public static PropertyDefinition percentCompletePropDef = PropertySystem.register(
      "PercentComplete",
      Double.class, ProgressControl.class,
      new PropertyData(0.0));

  /** Percent remaining property definition. */
  public static PropertyDefinition percentRemainingPropDef = PropertySystem.register(
      "PercentRemaining",
      Double.class, ProgressControl.class,
      new PropertyData(100.0));

  /** Percent text format definition. */
  public static PropertyDefinition percentFormatPropDef = PropertySystem.register(
      "PercentFormat",
      String.class, ProgressControl.class,
      new PropertyData("%{0}"));

  /** Percent text format definition. */
  public static PropertyDefinition percentTextPropDef = PropertySystem.register(
      "PercentText",
      String.class, ProgressControl.class,
      new PropertyData(""));

  /** Cycle property definition. */
  public static PropertyDefinition cyclePropDef = PropertySystem.register("Cycle",
      Boolean.class, ProgressControl.class,
      new PropertyData(false));
  // TODO(ferhat): Port timer start/stop logic from As3 framework.

  /** Cycle time property definition. */
  public static PropertyDefinition cycleTimePropDef = PropertySystem.register("CycleTime",
      Integer.class, ProgressControl.class,
      new PropertyData(DEFAULT_CYCLE_TIME));

  /** Cycle delay property definition. */
  public static PropertyDefinition cycleDelayPropDef = PropertySystem.register("CycleDelay",
      Integer.class, ProgressControl.class,
      new PropertyData(DEFAULT_CYCLE_DELAY));

  /** Steps property definition. */
  public static PropertyDefinition stepsPropDef = PropertySystem.register("Steps",
      Integer.class, ProgressControl.class,
      new PropertyData(DEFAULT_STEP_COUNT));

  /** IsAnimating property definition. */
  public static PropertyDefinition isAnimatingPropDef = PropertySystem.register("IsAnimating",
      Boolean.class, ProgressControl.class,
      new PropertyData(false));

  /**
   * Returns percent complete value.
   */
  public double getPercentComplete() {
    return ((Double) getProperty(percentCompletePropDef)).doubleValue();
  }

  /**
   * Returns percent remaining value.
   */
  public double getPercentRemaining() {
    return ((Double) getProperty(percentRemainingPropDef)).doubleValue();
  }

  /**
   * Sets or returns whether value should be cycled.
   */
  public void setCycle(boolean value) {
    setProperty(cyclePropDef, value);
  }

  public boolean getCycle() {
    return ((Boolean) getProperty(cyclePropDef)).booleanValue();
  }

  /**
   * Sets or returns cycle time.
   */
  public void setCycleTime(int value) {
    setProperty(cycleTimePropDef, value);
  }

  public int getCycleTime() {
    return ((Integer) getProperty(cycleTimePropDef)).intValue();
  }

  /**
   * Sets or returns cycle delay.
   */
  public void setCycleDelay(int value) {
    setProperty(cycleDelayPropDef, value);
  }

  public int getCycleDelay() {
    return ((Integer) getProperty(cycleDelayPropDef)).intValue();
  }

  /**
   * Returns true if progress control cycle delay is elapsed and is updating values.
   */
  public boolean getIsAnimating() {
    return ((Boolean) getProperty(isAnimatingPropDef)).booleanValue();
  }

  /**
   * Sets or returns percent text format.
   */
  public void setPercentFormat(String value) {
    setProperty(percentFormatPropDef, value);
  }

  public String getPercentFormat() {
    return (String) getProperty(percentFormatPropDef);
  }

  /**
   * Returns percent text.
   */
  public String getPercentText() {
    return (String) getProperty(percentTextPropDef);
  }

  /**
   * Sets or returns number of value steps. 0 specifies no steps.
   */
  public void setSteps(int value) {
    setProperty(stepsPropDef, value);
  }

  public int getSteps() {
    return ((Integer) getProperty(stepsPropDef)).intValue();
  }

  @Override
  protected void onValueChanged(double newValue) {
    super.onValueChanged(newValue);
    double complete = 0.0;
    double range = getMaxValue() - getMinValue();
    if (range > EPSILON) {
      complete = (getValue() - getMinValue()) / range;
    }
    setProperty(percentCompletePropDef, complete);
    setProperty(percentRemainingPropDef, 1.0 - complete);
    int percentInt = (int) ((complete * 100) + 0.5);
    String text = getPercentFormat().replaceFirst("\\{0\\}", String.valueOf(percentInt));
    setProperty(percentTextPropDef, text);
  }
}
