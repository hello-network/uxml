package com.hello.uxml.tools.framework.utils;

import com.hello.uxml.tools.framework.UIElement;
import com.hello.uxml.tools.framework.events.EventArgs;
import com.hello.uxml.tools.framework.events.EventDefinition;
import com.hello.uxml.tools.framework.events.EventManager;
import com.hello.uxml.tools.framework.events.EventNotifier;

import java.util.HashMap;

/**
 * Provides data for drag & drop and clipboard functionality.
 *
 * @author ferhat
 */
public class ClipboardData extends EventNotifier {
  /**
   * LoadData event definition used to handle data requests on demand.
   *
   * When handler receives event it should call setData with the requested
   * format.
   */
  public static EventDefinition loadDataEvent = EventManager.register(
      "LoadData", UIElement.class, EventArgs.class);

  /** Data format constant for unformatted text. */
  public static final String DATA_FORMAT_TEXT = "Text";

  /** Data format constant for a url. */
  public static final String DATA_FORMAT_URL = "Url";

  // Maps a data format to data.
  private HashMap<String, Object> dataMap = new HashMap<String, Object>();

  /**
   * Sets clipboard data to be transferred in specified format.
   */
  public void setData(String dataFormat, Object data) {
    dataMap.put(dataFormat, data);
  }

  /**
   * Returns data request or null if dataFormat is not supported.
   */
  public Object getData(String dataFormat) {
    if (dataMap.containsKey(dataFormat)) {
      return dataMap.get(dataFormat);
    }
    if (hasListener(loadDataEvent)) {
      notifyListeners(loadDataEvent, new ClipboardLoadDataEventArgs(this,
          dataFormat));
    }
    return dataMap.get(dataFormat);
  }

  /**
   * Implements event argument for ClipboardData loadData event.
   *
   * @author ferhat
   */
  public static class ClipboardLoadDataEventArgs extends EventArgs {

    private String dataFormat;

    public ClipboardLoadDataEventArgs(Object source, String dataFormat) {
      super(source, loadDataEvent);
      this.dataFormat = dataFormat;
    }

    /**
     * Returns requested data format.
     */
    public String getDataFormat() {
      return dataFormat;
    }
  }
}
