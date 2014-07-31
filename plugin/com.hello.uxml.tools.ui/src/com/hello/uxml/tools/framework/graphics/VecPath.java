package com.hello.uxml.tools.framework.graphics;

import com.hello.uxml.tools.framework.Point;
import com.hello.uxml.tools.framework.Rectangle;
import com.hello.uxml.tools.framework.UxmlElement;

import java.text.ParseException;
import java.util.ArrayList;
import java.util.List;

/**
 * Represents a path geometry.
 *
 * @author ferhat
 */
public class VecPath extends UxmlElement {

  private List<PathCommand> commands = new ArrayList<PathCommand>();

  /** Cached bounding rectangle */
  private Rectangle cachedBounds;

  /**
   * Adds a command to the path.
   */
  public void add(PathCommand command) {
    commands.add(command);
    cachedBounds = null;
  }

  public List<PathCommand> getCommands() {
    return commands;
  }

  public Rectangle getBounds() {
    if (cachedBounds != null) {
      return cachedBounds;
    }

    Rectangle bounds = new Rectangle();
    Point curPoint = new Point();
    boolean boundsInitialized = false;
    for (PathCommand cmd : commands) {
      Rectangle cmdBounds = cmd.getBounds(curPoint);
      if (!boundsInitialized) {
        boundsInitialized = true;
        bounds = cmdBounds;
      } else {
        bounds.add(cmdBounds);
      }
      curPoint = cmd.getEndPoint(curPoint);
    }
    cachedBounds = bounds;
    return bounds;
  }

  public void replay(IPathReplay replayTarget) {
    for (PathCommand cmd : commands) {
      cmd.replay(replayTarget);
    }
  }

  /**
   * Sets path data using SVG path syntax.
   */
  public void setContent(String pathData){
    try {
      PathParser parser = new PathParser();
      commands = parser.parse(pathData);
    } catch (ParseException e) {
      commands = null;
    }
  }
}
