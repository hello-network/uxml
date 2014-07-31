package com.hello.uxml.tools.ui.internal.properties;

import com.google.common.collect.Lists;
import com.hello.uxml.tools.core.internal.builder.CodeUpdater;
import com.hello.uxml.tools.core.internal.model.ProjectNatureAction;
import com.hello.uxml.tools.ui.CodeGenLanguage;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.IResourceVisitor;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IAdaptable;
import org.eclipse.swt.SWT;
import org.eclipse.swt.events.MouseEvent;
import org.eclipse.swt.events.MouseListener;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.widgets.Button;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.Label;
import org.eclipse.swt.widgets.Text;
import org.eclipse.ui.IWorkbenchPropertyPage;
import org.eclipse.ui.dialogs.PropertyPage;

import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Provides a configuration page for project level compile properties.
 *
 * @author ferhat
 */
public class UXMLProjectSettingsPage extends PropertyPage implements IWorkbenchPropertyPage {

  /** Default language for new projects */
  public static final String DEFAULT_CODELANG = "None";
  private static final Logger logger = Logger.getLogger(UXMLProjectSettingsPage.class.getName());

  /** Button to set/reset inheritance of project defaults */
  private Button useProjectDefaultsButton;
  /** Array of checkboxes for each language target */
  private Button[] targetLangRadio;
  /** Input field for target path */
  private Text pathInput;
  /** Input field for library part name */
  private Text partInput;
  /** Show warnings for localization. */
  private Button warnLocalizeCheckBox;
  /** Input field for imports */
  private Text importsPathInput;
  private Button regenAll;

  /**
   * Set by subclass to determine if dialog is for the project or an individual
   * uxml file.
   */
  private boolean isProjectLevel;

  /**
   * Creates property page for Uxml code generation settings.
   */
  public UXMLProjectSettingsPage() {
    super();
    this.isProjectLevel = true;
  }

  /**
   * Initialize UI of property page
   * - For each language create a checkbox
   */
  @Override
  protected Control createContents(Composite parent) {
    Composite myComposite = new Composite(parent, SWT.NONE);

    /* Create main grid layout */
    GridLayout mylayout = new GridLayout();
    mylayout.marginHeight = 1;
    mylayout.marginWidth = 1;
    myComposite.setLayout(mylayout);

    Label libLabel = new Label(myComposite, SWT.NONE);
    libLabel.setLayoutData(new GridData());
    libLabel.setText("Library name (part of)");

    partInput = new Text(myComposite, SWT.NONE | SWT.BORDER);
    partInput.setLayoutData(new GridData(GridData.FILL_HORIZONTAL));

    Label pathLabel = new Label(myComposite, SWT.NONE);
    pathLabel.setLayoutData(new GridData());
    pathLabel.setText("Target Path");

    pathInput = new Text(myComposite, SWT.NONE | SWT.BORDER);
    pathInput.setLayoutData(new GridData(GridData.FILL_HORIZONTAL));

    Label importsPathLabel = new Label(myComposite, SWT.NONE);
    importsPathLabel.setLayoutData(new GridData());
    importsPathLabel.setText("UXML Imports Path");

    importsPathInput = new Text(myComposite, SWT.MULTI | SWT.WRAP | SWT.BORDER);
    importsPathInput.setLayoutData(new GridData(480, 60));

    Label mylabel = new Label(myComposite, SWT.NONE);
    mylabel.setLayoutData(new GridData());
    mylabel.setText("Language Targets");

    if (!isProjectLevel) {
      useProjectDefaultsButton = new Button(myComposite, SWT.RADIO);
      useProjectDefaultsButton.setText("Use Project Defaults");
      useProjectDefaultsButton.setLayoutData(new GridData(GridData.FILL_HORIZONTAL));
    }

    CodeGenLanguage[] languages = CodeGenLanguage.values();
    targetLangRadio = new Button[languages.length];

    for (int i = 0; i  < languages.length; ++i) {
      targetLangRadio[i] = new Button(myComposite, SWT.RADIO);
      String langName = languages[i].toString();
      targetLangRadio[i].setText(langName);
      targetLangRadio[i].setLayoutData(new GridData(GridData.FILL_HORIZONTAL));
    }

    if (isProjectLevel) {
      warnLocalizeCheckBox = new Button(myComposite, SWT.CHECK);
      warnLocalizeCheckBox.setText("show localization warnings");
    }
    regenAll = new Button(myComposite, SWT.PUSH);
    regenAll.setText("Regenerate all");

    regenAll.addMouseListener(new MouseListener() {
        @Override
        public void mouseUp(MouseEvent e) {
          try {
            CodeUpdater codeUpdater = new CodeUpdater();
            List<CodeUpdater.UpdateInfo> updateList = Lists.newArrayList();
            getProject().accept(new UxmlResourceVisitor(codeUpdater, updateList));
            codeUpdater.compileUpdates(updateList);
            codeUpdater.buildAll(getProject());
          } catch (CoreException exp) {
            logger.log(Level.SEVERE, "Code updater failed during regen.", exp);
          }
        }

        @Override
        public void mouseDown(MouseEvent e) {
        }

        @Override
        public void mouseDoubleClick(MouseEvent e) {
        }
      });
    initializeValues();
    return myComposite;
  }

  @Override public boolean performOk() {
    storeValues();
    return super.performOk();
  }

  private IProject getProject() {
    if (!isProjectLevel) {
      return null;
    }
    IAdaptable adaptable = this.getElement();
    return (IProject) adaptable.getAdapter(IProject.class);
  }

  private void initializeValues() {
    initializeLanguage();
    initializePathAndLoca();
  }

  private void initializeLanguage() {
    ProjectItemMetadata prefs = getPreferences();
    if (isProjectLevel) {
      String language = "";
      String importsPath = "";

      try {
        language = prefs.get(ProjectItemMetadata.LANG_KEY);

      } catch (CoreException e) {
        // report error and recover using default language As3
        logger.log(Level.SEVERE, "Project Persistance failed during language key lookup.");
        language = "As3";
      }

      try {
        importsPath = prefs.get(ProjectItemMetadata.IMPORTS_KEY);
      } catch (CoreException e) {
        // report error and recover using default language As3
        logger.log(Level.SEVERE, "Project Persistance failed during imports key lookup.");
        importsPath = "";
      }

      if ((language == null) || (language.length() == 0)) {
          language = DEFAULT_CODELANG;
      }

      if (importsPath == null) {
        importsPath = "";
      }

      // Now that we have languages , setup radio button
      targetLangRadio[CodeGenLanguage.valueOf(language).ordinal()].setSelection(true);
    } else {
      // use when per res impl : IResource resource = (IResource) getElement();
      String language = "";
      try {
        language = prefs.get(ProjectItemMetadata.LANG_KEY);
      } catch (CoreException e) {

        // log error and recover using default language
        logger.log(Level.SEVERE, "Project Persistance failed during language key lookup. "
            + e.toString());
        language = "None";
      }
      if ((language == null) || (language.length() == 0)) {
        useProjectDefaultsButton.setSelection(true);
        for (int buttonIndex = 0; buttonIndex < targetLangRadio.length; ++buttonIndex) {
          targetLangRadio[buttonIndex].setEnabled(false);
        }
      } else {
        useProjectDefaultsButton.setSelection(false);
        for (int buttonIndex = 0; buttonIndex < targetLangRadio.length; ++buttonIndex) {
          targetLangRadio[buttonIndex].setEnabled(true);
        }
      }
    }
  }

  private void initializePathAndLoca() {
    ProjectItemMetadata prefs = getPreferences();
    String targetPath = null;
    String partName = null;
    String importsPath = null;
    boolean warnLoc = true;

    try {
      targetPath = prefs.get(ProjectItemMetadata.TARGETPATH_KEY);
    } catch (CoreException e) {
      // report error and recover using default language As3
      logger.log(Level.SEVERE, "Project Persistance failed during path key lookup.");
    }
    try {
      warnLoc = Boolean.valueOf(prefs.get(ProjectItemMetadata.LOCALIZATION_WARNING_KEY));
    } catch (CoreException e) {
      // report error and recover using default language As3
      logger.log(Level.SEVERE, "Project Persistance failed during localization key lookup.");
    }
    try {
      importsPath = prefs.get(ProjectItemMetadata.IMPORTS_KEY);
    } catch (CoreException e) {
      // report error and recover using default language As3
      logger.log(Level.SEVERE, "Project Persistance failed during imports key lookup.");
    }
    try {
      partName = prefs.get(ProjectItemMetadata.LIBRARY_KEY);
    } catch (CoreException e) {
      // report error and recover using default language As3
      logger.log(Level.SEVERE, "Project Persistance failed during library key lookup.");
    }
    if (targetPath != null) {
      pathInput.setText(targetPath);
    }
    if (partName != null) {
      partInput.setText(partName);
    }
    if (importsPath != null) {
      importsPathInput.setText(importsPath);
    }
    warnLocalizeCheckBox.setSelection(warnLoc);
  }

  /**
   * Store code generation settings for IProject/IFile nodes
   */
  private void storeValues() {
    /* Construct language pref string of form (%langname)*(; %langname)* */
    String language = CodeGenLanguage.None.toString();
    CodeGenLanguage[] languages = CodeGenLanguage.values();
    for (int i = 0; i  < languages.length; ++i) {
      if (targetLangRadio[i].getSelection() == true) {
        language = languages[i].toString();
        break;
      }
    }

    ProjectItemMetadata preferences = getPreferences();
    try {
      preferences.put(ProjectItemMetadata.LANG_KEY, language);
      preferences.put(ProjectItemMetadata.TARGETPATH_KEY, pathInput.getText());
      preferences.put(ProjectItemMetadata.LIBRARY_KEY, partInput.getText());
      preferences.put(ProjectItemMetadata.IMPORTS_KEY, importsPathInput.getText());
      preferences.put(ProjectItemMetadata.LOCALIZATION_WARNING_KEY, String.valueOf(
          warnLocalizeCheckBox.getSelection()));
    } catch (CoreException e) {
      logger.log(Level.SEVERE, "Project preference storage failed." + e.toString());
    }

    // Add nature to project
    ProjectNatureAction.addUxmlNature(getProject());
  }

  private ProjectItemMetadata getPreferences() {
    return isProjectLevel
        ? UXMLProjectMetadata.getProjectPreferences(getProject())
        : UXMLProjectMetadata.getFilePreferences((IResource) getElement());
  }

  class UxmlResourceVisitor implements IResourceVisitor {
    private CodeUpdater codeUpdater;
    private List<CodeUpdater.UpdateInfo> targetList;

    /**
     * Constructor.
     * @param codeUpdater updater to use to create list to compile.
     */
    public UxmlResourceVisitor(CodeUpdater codeUpdater,
        List<CodeUpdater.UpdateInfo> targetList) {
      this.codeUpdater = codeUpdater;
      this.targetList = targetList;
    }

    public boolean visit(IResource resource) {
      if (resource instanceof IFile && (resource.getName().endsWith(".hts") ||
        resource.getName().endsWith(".uxml"))) {
        codeUpdater.createUpdateInfo(resource, targetList);
      }
      return true; // continue visiting children.
    }
  }
}
