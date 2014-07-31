package com.hello.uxml.tools.framework.events;

/**
 * Defines data event arguments.
 * @author sanjayc@ (Sanjay Chouksey)
 */
public class DataEvent extends EventArgs {

  private Object data;

  /**
   * Constructor.
   */
  public DataEvent(Object source, Object data) {
    this.source = source;
    this.data = data;
  }

  /**
   * Gets or sets the data of the event.
   */
  public Object getData() {
    return data;
  }

  public void setData(Object data) {
    this.data = data;
  }
}
