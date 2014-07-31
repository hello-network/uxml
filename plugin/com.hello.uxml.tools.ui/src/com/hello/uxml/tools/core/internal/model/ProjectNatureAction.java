package com.hello.uxml.tools.core.internal.model;

import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IProjectDescription;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IAdaptable;
import org.eclipse.jface.action.IAction;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.ui.IObjectActionDelegate;
import org.eclipse.ui.IWorkbenchPart;

import java.util.Iterator;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Implements action to add project nature.
 *
 * @author ferhat
 */
public class ProjectNatureAction implements IObjectActionDelegate {

  private ISelection selection;

  /*
   * (non-Javadoc)
   *
   * @see org.eclipse.ui.IActionDelegate#run(org.eclipse.jface.action.IAction)
   */
  public void run(IAction action) {
  if (selection instanceof IStructuredSelection) {
    for (@SuppressWarnings("unchecked") Iterator<Object> it =
        ((IStructuredSelection) selection).iterator(); it.hasNext();) {
      Object element = it.next();
      IProject project = null;
      if (element instanceof IProject) {
       project = (IProject) element;
          } else if (element instanceof IAdaptable) {
            project = (IProject) ((IAdaptable) element).getAdapter(IProject.class);
          }
          if (project != null) {
            toggleNature(project);
          }
        }
      }
    }

  /*
   * (non-Javadoc)
   *
   * @see org.eclipse.ui.IActionDelegate#selectionChanged(org.eclipse.jface.action.IAction,
   *      org.eclipse.jface.viewers.ISelection)
   */
  public void selectionChanged(IAction action, ISelection selection) {
    this.selection = selection;
  }

  /*
   * (non-Javadoc)
   *
   * @see org.eclipse.ui.IObjectActionDelegate#setActivePart(org.eclipse.jface.action.IAction,
   *      org.eclipse.ui.IWorkbenchPart)
   */
  public void setActivePart(IAction action, IWorkbenchPart targetPart) {
  }

  /**
   * Toggles sample nature on a project
   *
   * @param project to add or remove nature to.
   */
  private void toggleNature(IProject project) {
    try {
      IProjectDescription description = project.getDescription();
      String[] natures = description.getNatureIds();

      for (int i = 0; i < natures.length; ++i) {
        if (UXMLNature.NATURE_ID.equals(natures[i])) {
          // Remove the nature
          String[] newNatures = new String[natures.length - 1];
          System.arraycopy(natures, 0, newNatures, 0, i);
          System.arraycopy(natures, i + 1, newNatures, i,
              natures.length - i - 1);
          description.setNatureIds(newNatures);
          project.setDescription(description, null);
          return;
        }
      }
      addUxmlNature(project);
    } catch (CoreException e) {
      // TODO(ferhat): log error.
    }
  }

  public static void addUxmlNature(IProject project) {
    // Add the nature
    IProjectDescription description;
    try {
      // Check if already exists
      description = project.getDescription();
      String[] natures = description.getNatureIds();

      for (int i = 0; i < natures.length; ++i) {
        if (UXMLNature.NATURE_ID.equals(natures[i])) {
          return;
        }
      }

      // Add nature
      String[] newNatures = new String[natures.length + 1];
      System.arraycopy(natures, 0, newNatures, 0, natures.length);
      newNatures[natures.length] = UXMLNature.NATURE_ID;
      description.setNatureIds(newNatures);
      project.setDescription(description, null);
    } catch (CoreException e) {
      Logger.getLogger(ProjectNatureAction.class.toString()).log(Level.SEVERE,
          "Could not set project nature. Please make sure .project file is accessible");
    }
  }
}
