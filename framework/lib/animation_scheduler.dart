part of uxml;

/**
 * Schedules frame animation tasks.
 *
 * Scheduled tasks are executed on each enterFrame call.
 *
 * @author ferhat@ (Ferhat Buyukkokten)
 */
class AnimationScheduler {

  // List of scheduled tasks.
  List<ScheduledTask> _tasks;

  // Used to sync animations. Calling schedule A,B at frameX stores the
  // same timestamp value in eached ScheduledTask so they will be in
  // sync when tasks are executed.
  int _frameTimeStampValue;

  /**
   * Sets returns speed multiplier used for debugging animations.
   */
  num speedFactor = 1.0;

  /**
   * Constructor.
   *
   * Initializes frameTimeStamp.
   */
  AnimationScheduler() {
    _frameTimeStampValue = Application.getTimer();
    _tasks = <ScheduledTask>[];
  }

  /**
   * Adds a task to be executed after delay(ms) wait and duration provided.
   */
  ScheduledTask schedule(num delay,
                         num duration,
                         TaskCallback callback,
                         Object target,
                         Object tag) {
    return scheduleInRange(delay, duration, callback, target, tag, 0.0, 1.0);
  }

  /**
   * Adds a task to be executed after delay(ms) wait and duration provided.
   */
  ScheduledTask scheduleInRange(num delay,
                           num duration,
                           TaskCallback callback,
                           Object target,
                           Object tag,
                           num tweenStart,
                           num tweenEnd) {
    _frameTimeStampValue = Application.getTimer();
    ScheduledTask task = new ScheduledTask(_frameTimeStampValue,
        delay.toInt(), duration.toInt(), callback, target, tag);
    task.tweenStart = tweenStart;
    task.tweenEnd = tweenEnd;
    _tasks.add(task);
    UpdateQueue.updateAnimations();
    return task;
  }

  /**
   * Cancels scheduled task and marks it completed.
   */
  void cancel(ScheduledTask task) {
    if (!task._taskCompleted) {
      task._setTaskCompleted();
      int index = _tasks.indexOf(task);
      if (index != -1) {
        _tasks.removeAt(index);
      }
    }
  }

  /**
   * Returns true if animation tasks are scheduled.
   */
  bool get hasTasks => !_tasks.isEmpty;

  /**
   * Called from application onEnterFrame.
   */
  void enterFrame() {
    _frameTimeStampValue = Application.getTimer();
    int taskCount = _tasks.length;
    for (int taskIndex = 0; taskIndex < taskCount; taskIndex++) {
      ScheduledTask task = _tasks[taskIndex];
      if (task == null) {
        _tasks.removeAt(taskIndex);
        --taskIndex;
        --taskCount;
        continue;
      }
      int timeDelta = _frameTimeStampValue - task.startTime;
      if (timeDelta >= task.delay) {
        if (timeDelta < (task.delay + (task.duration / speedFactor))) {
          try {
            // Update tween
            task.execute(task.tweenStart + ((task.tweenEnd - task.tweenStart) *
                ((timeDelta - task.delay) / (task.duration / speedFactor))));
          } on Error catch(e) {
            _tasks.removeAt(taskIndex);
            --taskIndex;
            --taskCount;
          }
        } else {
          // Update tween to final value and cancel scheduled task
          task._setTaskCompleted();
          _tasks.removeAt(taskIndex);
          --taskCount;
          --taskIndex;
          task.execute(task.tweenEnd);
          task._shutdown();
        }
      }
    }
  }
}
