part of uxml;

/**
 * Defines an event class that can include arbitrary data with the event.
 *
 * @author sanjayc@ (Sanjay Chouksey)
 */
class DataEvent extends EventArgs {

  /** The data associated with this event. */
  Object data;

  DataEvent(Object source, Object eventData) : super(source) {
    data = eventData;
  }
}
