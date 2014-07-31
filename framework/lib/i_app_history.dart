part of uxml;

/**
 * Provides interface for application root level history.
 * This interface is used by Navigator class to interface with
 * browser/client app host.
 *
 * It is modelled after HTML5 IHistory.
 *
 * @author ferhat@ (Ferhat Buyukkokten)
 */
abstract class IAppHistory {

  /** Returns last history value set by user agent. */
  String get state;

  /** Goes back one state in global history. */
  void back();

  /** Goes forward one state in global history. */
  void forward();

  /**
   * Pushes the given state to history with given
   * title and if provided url.
   */
  void pushState(Object data, String title, String url);

  /**
   * Replaces the current state.
   */
  void replaceState(Object data, String title, String url);

  /**
   * Adds a listener to be called when user agent navigates to new state.
   * Typically this is called onPopState event.
   * The callback is called with state and data object.
   */
  void addStateListener(EventHandler callback);

  /**
   * Removes a state change listener.
   */
  void removeStateListener(EventHandler callback);
}
