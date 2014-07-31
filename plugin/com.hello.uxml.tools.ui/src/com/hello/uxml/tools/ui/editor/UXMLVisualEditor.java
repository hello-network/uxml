package com.hello.uxml.tools.ui.editor;

import com.hello.uxml.tools.codegen.dom.Model;
import com.hello.uxml.tools.ui.internal.properties.ProjectItemMetadata;
import com.hello.uxml.tools.ui.internal.properties.UXMLProjectMetadata;

import org.eclipse.core.resources.IProject;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.jface.action.IMenuManager;
import org.eclipse.jface.action.Separator;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.jface.viewers.ISelectionChangedListener;
import org.eclipse.jface.viewers.ISelectionProvider;
import org.eclipse.jface.viewers.StructuredSelection;
import org.eclipse.swt.SWT;
import org.eclipse.swt.browser.Browser;
import org.eclipse.swt.layout.FillLayout;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.ui.IWorkbenchActionConstants;


/**
 * Implements ui of hts visual editor
 *
 * @author ferhat
 */
public class UXMLVisualEditor extends Composite implements ISelectionProvider {

  //private final SwtApplication app;

  private StructuredSelection curSelection;

  private Model modelRoot;
  private Browser browser = null;

  /** Is set if model has changed since last syncModel call */
  private boolean modelDirty = false;

  public UXMLVisualEditor(Composite parent) {
    super(parent, SWT.NONE);
    setLayout(new FillLayout());
  }

  public void setupProject(IProject project) {
    if (browser == null) {
      browser = new Browser(this, SWT.NONE);
    }
    ProjectItemMetadata meta = UXMLProjectMetadata.getProjectPreferences(project);
    String serverUrl;
    try {
      serverUrl = meta.get(ProjectItemMetadata.DEVSERVER_URL_KEY);
      if (serverUrl != null) {
        browser.setUrl(serverUrl);
      }
    } catch (CoreException e) {
      e.printStackTrace();
    }
  }

  /**
   * Sync markup model in editor input with current view.
   */
  public void syncModel(Model model) {
    // TODO(ferhat): link designer in browser and
    // data model of doc.
    if (model != modelRoot) {
      modelRoot = model;
    }
    modelDirty = false;
  }

  /**
   * Returns true if model was modified.
   */
  public boolean isDirty() {
    return modelDirty;
  }

  /**
   * Called by markup editor when model is serialized to text.
   */
  public void resetDirty() {
    modelDirty = false;
  }

   /**
   * Populates context Menu
   */
  public void populateContextMenu(IMenuManager menuMgr) {
    menuMgr.add(new Separator("edit"));
    menuMgr.add(new Separator(IWorkbenchActionConstants.MB_ADDITIONS));
  }

  // ISelectionProvider members
  public void addSelectionChangedListener(ISelectionChangedListener listener) {
    // TODO(ferhat): impl.
  }

  public ISelection getSelection() {
    return curSelection;
  }

  public void removeSelectionChangedListener(ISelectionChangedListener listener) {
    // TODO(ferhat): impl.
  }

  public void setSelection(ISelection selection) {
    // TODO(ferhat): impl.
  }
}
