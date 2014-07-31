part of uxml;

/**
 * Implements ListBox control.
 *
 * All functionality is provided in ListBase. This element allows custom
 * chrome'ing for ListBox style controls.
 */
class ListBox extends ListBase {

  static ElementDef listboxElementDef;

  ListBox() : super() {
  }

  /** @see UxmlElement.getDefinition. */
  ElementDef getDefinition() => listboxElementDef;

  /** Registers component. */
  static void registerListBox() {
    listboxElementDef = ElementRegistry.register("ListBox",
        ListBase.listbaseElementDef, null, null);
  }
}
