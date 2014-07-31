part of uxml;

typedef void MouseEventsCallback(int type, num x, num y);
typedef void AnimationFrameCallback(num time);
typedef void CreateImageCallback(int width, int height);

abstract class Window {
  int get width;
  int get height;
  int get innerWidth;
  int get innerHeight;
  num get screenPixelRatio;
  IosSurface createSurface();
  IosTextSurface createTextSurface();
  IosEditSurface createEditSurface(TextChangedCallback callback);
  void addChildSurface(IosSurface surface);
  void requestAnimationFrame(AnimationFrameCallback cb);
  bool mouseEventsCallback(MouseEventsCallback cb);
  Object loadImage(String url, CreateImageCallback cb, var loadFailureCallback);
}

Window window = null;

class UIPlatform {
  static void initialize() {
  }

  static UISurface createRootSurface(Application owner, Object host) {
    return new RootSurface(owner, host);
  }

  static UISurface createSurface() {
    return new UISurfaceImpl();
  }

  static UIEditSurface createEditSurface() {
    return new UIEditSurfaceImpl();
  }

  static UITextSurface createTextSurface() {
    return new UITextSurfaceImpl();
  }

  static void initializeAppEvents(Application app) {
    app.setHostSize(window.width, window.height);
    window.mouseEventsCallback((int type, num x, num y) {
      EventArgs resEvent = app._routeMouseEvent(x, y,
          MouseEventArgs.LEFT_BUTTON, type);
      bool handled = (resEvent == null) ? false :
        (resEvent._forceDefault ? false : resEvent.handled);
      if (type != MouseEventArgs.MOUSE_MOVE) {
        UpdateQueue.flush();
      }
      return handled;
    });
  }

  static void shutdownAppEvents(Application app) {
    print('platform shutdownAppEvents');
  }

  static void scheduleEnterFrame(Application app) {
    window.requestAnimationFrame(app._enterFrame);
  }

  static void setTimeout(handler, int timeout) {
    print('platform setTimeout');
  }

  static void writeToConsole(String message) {
    print(message);
  }

  /**
   * Performs relayout on root when top level host(browser window) resizes.
   */
  static void relayoutRoot(UISurface rootSurface, bool disableScrollBars) {
  }

  /** Updates all child div locations. */
  static void _updateChildLocations(UISurface surface) {
    print('platform _updateChildLocations');
  }

  /**
   * Loads image and calls callback when image and dimensions are ready.
   * clients typically call drawBitmap api's on UISurface to consume.
   */
  static Object loadImage(String url, LoadImageCallback callback,
                          [loadFailureCallback = null]) {
    Object img;
    img = window.loadImage(url, (int width, int height) {
      callback(img, width, height);
    }, loadFailureCallback);
    return img;
  }

  /**
   * Cancels image loading for object returned from UIPlatform.loadImage.
   */
  static void cancelLoadImage(Object image) {
    print('platform cancelLoadImage');
  }

  /**
   * Loads an image from alternative source (non-url based).
   */
  static Object loadImageFromBytes(Object value, LoadImageCallback callback) {
    print('platform loadImageFromBytes');
    return null;
  }

  static ServiceRequestInterceptor interceptor = null;
  static String rewriteUrl(String url) {
    if (interceptor == null) {
      return url;
    }
    return interceptor(url);
  }

  /**
   * Transforms the element with given css transform and transition.
   */
  static void transformElement(UISurface surface, String transform,
                               String transition) {
    print('platform transformElement: $transform $transition');
  }

  /**
   * Transforms the element with given css transform and transition.
   */
  static void setTransition(UISurface surface, String transition,
                                [Function endCB]) {
    print('platform setTransition');
  }

  /**
   * Allow platform specific animations.
   */
  static AnimateAction animate(UxmlElement target, Object propertyKey,
                      Object targetValue, {int duration,
                      TaskCompleteCallback callback, int delay,
                      String easing:'linear'}) {
    return target.animate(propertyKey, targetValue, duration:duration,
        callback:callback, delay:delay);
  }

  /**
   * Cancel platform specific animation.
   */
  static void cancelAnimation(AnimateAction animation) {
    animation.stop(animation.startElement);
  }

  // Override for platform to decide if mouse event should be routed
  // element or not. In Html we don't want to pass through.
  // In platforms such as flash we need mouseArgs._passthrough();
  static void handleEditMouseEvent(MouseEventArgs mouseArgs) {
    mouseArgs._passthrough();
  }
}

typedef void LoadImageCallback(Object image,num width, num height);
typedef String ServiceRequestInterceptor(String url);

/** Creates a wrapper around document body that represents root surface */
class RootSurface extends UISurfaceImpl {
  Application app;

  RootSurface(Application owner, Window win) : super() {
    app = owner;
  }

  UISurface addChild(UISurface child) {
    super.addChild(child);
    (child as UISurfaceImpl).root = app;
    return child;
  }

  UISurface insertChild(int index, UISurface child) {
    super.insertChild(index, child);
    (child as UISurfaceImpl).root = app;
    return child;
  }

  void _createElementOnDemand() {
  }


  void _hostElementCreated(UISurfaceImpl child) {
    window.addChildSurface(child.hostSurface);
    app.onRootSurfaceCreated();
  }
}
