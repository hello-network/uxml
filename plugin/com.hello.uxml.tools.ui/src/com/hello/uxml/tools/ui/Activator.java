package com.hello.uxml.tools.ui;

import com.hello.uxml.tools.core.internal.builder.CodeUpdater;

import org.eclipse.core.resources.IWorkspace;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.ui.plugin.AbstractUIPlugin;
import org.osgi.framework.BundleContext;

/**
 * The activator class controls the plug-in life cycle.
 *
 * @author ferhat
 */
public class Activator extends AbstractUIPlugin {

  // The plug-in ID
  public static final String PLUGIN_ID = "com.hello.uxml.tools.ui"; //$NON-NLS-1$

  // The shared instance
  private static Activator plugin;

  // Workspace of plugin
  private IWorkspace workspace;

  // Shared resource change listener
  private static CodeUpdater codeUpdater;

  /**
   * The constructor
   */
  public Activator() {
  }

  /*
   * (non-Javadoc)
   * @see org.eclipse.ui.plugin.AbstractUIPlugin#start(org.osgi.framework.BundleContext)
   */
  public void start(BundleContext context) throws Exception {
    super.start(context);
    plugin = this;
    codeUpdater = CodeUpdater.getDefault();
    workspace = ResourcesPlugin.getWorkspace();
    workspace.addResourceChangeListener(codeUpdater);
  }

  /*
   * (non-Javadoc)
   * @see org.eclipse.ui.plugin.AbstractUIPlugin#stop(org.osgi.framework.BundleContext)
   */
  public void stop(BundleContext context) throws Exception {
    if (workspace != null) {
      workspace.removeResourceChangeListener(codeUpdater);
      codeUpdater = null;
      workspace = null;
    }
    plugin = null;
    super.stop(context);
  }

  /**
   * Returns the shared instance
   *
   * @return the shared instance
   */
  public static Activator getDefault() {
    return plugin;
  }

}
