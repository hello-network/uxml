part of uxml;

/**
 * Provides data for drag & drop and clipboard functionality.
 *
 * @author ferhat@ (Ferhat Buyukkokten)
 */
class ClipboardData extends UxmlElement {

  static ElementDef clipboardElementDef;

  /**
   * LoadData event definition used to handle data requests on demand.
   *
   * When handler receives event it should call setData with the requested
   * format.
   */
  static EventDef loadDataEvent;

  /** Data format constant for unformatted text. */
  static const String DATA_FORMAT_TEXT = "Text";

  /** Data format constant for a url. */
  static const String DATA_FORMAT_URL = "Url";

  // Maps a data format to data.
  Map<String, Object> dataMap;

  ClipboardData() : super() {
    dataMap = new Map<String,Object>();
  }

  /**
   * Sets clipboard data to be transferred in specified format.
   */
  void setData(String dataFormat, Object data) {
    dataMap[dataFormat] = data;
  }

  /**
   * Returns data request or null if dataFormat is not supported.
   */
  Object getData(String dataFormat) {
    if (dataMap[dataFormat] != null) {
      return dataMap[dataFormat];
    }
    if (hasListener(loadDataEvent)) {
      notifyListeners(loadDataEvent, new ClipboardLoadDataEventArgs(this,
          dataFormat));
    }
    return dataMap[dataFormat];
  }

  /** @see UxmlElement.getDefinition. */
  ElementDef getDefinition() => clipboardElementDef;

  /** Registers component. */
  static void registerClipboardData() {
    loadDataEvent = new EventDef("loaddata", Route.DIRECT);
    clipboardElementDef = ElementRegistry.register("ClipboardData", null,
        null, [loadDataEvent]);
  }

}

/**
 * Implements event argument for ClipboardData loadData event.
 *
 * @author ferhat@ (Ferhat Buyukkokten)
 */
class ClipboardLoadDataEventArgs extends EventArgs {
  String _dataFormatValue;

  ClipboardLoadDataEventArgs(Object source, String format) : super(source) {
    _dataFormatValue = format;
  }

  /**
   * Returns request data format.
   */
  String get dataFormat => _dataFormatValue;
}
