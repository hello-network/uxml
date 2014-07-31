part of uxml;

/**
 * Holds task information for frame based AnimationScheduler.
 *
 * @author ferhat@ (Ferhat Buyukkokten)
 */
class ScheduledTask {
  int _startTime;
  int _delay;
  int _duration;
  TaskCallback _callback;
  ScheduledTaskCompleteCallback completionCallback = null;
  Object _target;
  Object _tag;
  num _currentTween = 0.0;

  /**
   * Start value of tween.
   */
  num tweenStart = 0.0;

  /**
   * End value of tween.
   */
  num tweenEnd = 1.0;

  bool _taskCompleted = false;

  /**
   * Constructor.
   */
  ScheduledTask(int startTime, int delay, int duration,
    TaskCallback callback, Object target, Object tag) {
    _startTime = startTime;
    _delay = delay;
    _duration = duration;
    _target = target;
    _callback = callback;
    _tag = tag;
  }

  /**
   * Returns start time.
   */
  int get startTime {
    return _startTime;
  }

  /**
   * Returns duration of task.
   */
  int get duration {
    return _duration;
  }

  /**
   * Returns delay before task starts.
   */
  int get delay {
    return _delay;
  }

  /**
   * Sets/Returns current tween value.
   */
  num get currentTween {
    return _currentTween;
  }

  set currentTween(num value) {
    _currentTween = value;
  }

  /**
   * Returns current tween value.
   */

  void execute(num tween) {
    _currentTween = tween;
    _callback(tween, _tag);
  }

  /**
   * Returns true if task has completed.
   */
  bool get completed {
    return _taskCompleted;
  }

  void _setTaskCompleted() {
    _taskCompleted = true;
  }

  /**
   * Called by AnimationScheduler to shutdown task.
   */
  void _shutdown() {
    if (completionCallback != null) {
      completionCallback(this);
      completionCallback = null;
    }
  }
}

typedef void TaskCallback(num tween, Object tag);
typedef void ScheduledTaskCompleteCallback(ScheduledTask task);
