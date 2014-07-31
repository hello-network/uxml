part of uxml;

/**
 * Implements an observable collection of items used by ItemsContainer(s).
 *
 * Items are either UIElements or Strings.
 *
 * @author ferhat@ (Ferhat Buyukkokten)
 */
class Items extends ElementCollection {

  static EventDef itemsChangedEvent;

  Items() : super() {
  }

  /** Registers component. */
  static void registerItems() {
    itemsChangedEvent = ElementCollection.changedEvent;
  }
}
