
package com.hello.uxml.tools.ui.internal.properties;

import com.hello.uxml.tools.core.internal.model.ProjectNatureAction;

import org.eclipse.core.resources.IProject;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IAdaptable;
import org.eclipse.swt.SWT;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.widgets.Button;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.Label;
import org.eclipse.swt.widgets.Text;
import org.eclipse.ui.IWorkbenchPropertyPage;
import org.eclipse.ui.dialogs.PropertyPage;

import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Provides a configuration page for uxml dart compilation.
 *
 * @author ferhat
 */
public class UXMLDartSettingsPage extends PropertyPage implements IWorkbenchPropertyPage {
  private static final Logger logger = Logger.getLogger(UXMLDartSettingsPage.class.getName());

  /** Server url of frog compiler */
  private Text devServerUrl;
  /** Input field for dart file to compile */
  private Text dartScriptPath;
  /** Input field for target paths*/
  private Text dartAsTargetPath;
  private Text dartJsTargetPath;
  private Text dartObjCTargetPath;
  private Button dartAsTargetEnabled;
  private Button dartJsTargetEnabled;
  private Button dartObjCTargetEnabled;
  private Button debugModeEnabled;

  /**
   * Creates property page for UXML dart code generation settings.
   */
  public UXMLDartSettingsPage() {
    super();
  }

  /**
   * Initialize UI of property page
   */
  @Override
  protected Control createContents(Composite parent) {
    Composite myComposite = new Composite(parent, SWT.NONE);

    /* Create main grid layout */
    GridLayout mylayout = new GridLayout();
    mylayout.marginHeight = 1;
    mylayout.marginWidth = 1;
    myComposite.setLayout(mylayout);

    Label serverLabel = new Label(myComposite, SWT.NONE);
    serverLabel.setLayoutData(new GridData());
    serverLabel.setText("Dev server url");

    devServerUrl = new Text(myComposite, SWT.NONE | SWT.BORDER);
    devServerUrl.setLayoutData(new GridData(GridData.FILL_HORIZONTAL));

    Label rootPathLabel = new Label(myComposite, SWT.NONE);
    rootPathLabel.setLayoutData(new GridData());
    rootPathLabel.setText("Dart startup script");

    dartScriptPath = new Text(myComposite, SWT.NONE | SWT.BORDER);
    dartScriptPath.setLayoutData(new GridData(GridData.FILL_HORIZONTAL));

    Label s = new Label(myComposite, SWT.SEPARATOR | SWT.HORIZONTAL);
    s.setLayoutData(new GridData(GridData.FILL_HORIZONTAL));

    // Javascript
    dartJsTargetEnabled = new Button(myComposite, SWT.CHECK);
    dartJsTargetEnabled.setText("Frog/Javascript enabled");

    Label outputJsLabel = new Label(myComposite, SWT.NONE);
    outputJsLabel.setLayoutData(new GridData());
    outputJsLabel.setText("Javascript output path");

    dartJsTargetPath = new Text(myComposite, SWT.NONE | SWT.BORDER);
    dartJsTargetPath.setLayoutData(new GridData(GridData.FILL_HORIZONTAL));

    s = new Label(myComposite, SWT.SEPARATOR | SWT.HORIZONTAL);
    s.setLayoutData(new GridData(GridData.FILL_HORIZONTAL));

    // Actionscript
    dartAsTargetEnabled = new Button(myComposite, SWT.CHECK);
    dartAsTargetEnabled.setText("Actionscript enabled");

    Label outputAsLabel = new Label(myComposite, SWT.NONE);
    outputAsLabel.setLayoutData(new GridData());
    outputAsLabel.setText("Actionscript output path");

    dartAsTargetPath = new Text(myComposite, SWT.NONE | SWT.BORDER);
    dartAsTargetPath.setLayoutData(new GridData(GridData.FILL_HORIZONTAL));

    s = new Label(myComposite, SWT.SEPARATOR | SWT.HORIZONTAL);
    s.setLayoutData(new GridData(GridData.FILL_HORIZONTAL));

    // Objective C
    dartObjCTargetEnabled = new Button(myComposite, SWT.CHECK);
    dartObjCTargetEnabled.setText("Objective C enabled");

    Label outputObjCLabel = new Label(myComposite, SWT.NONE);
    outputObjCLabel.setLayoutData(new GridData());
    outputObjCLabel.setText("Objective C output path");

    dartObjCTargetPath = new Text(myComposite, SWT.NONE | SWT.BORDER);
    dartObjCTargetPath.setLayoutData(new GridData(GridData.FILL_HORIZONTAL));

    debugModeEnabled = new Button(myComposite, SWT.CHECK);
    debugModeEnabled.setText("Debug enabled (asserts)");

    initializeValues();
    return myComposite;
  }

  @Override public boolean performOk() {
    storeValues();
    return super.performOk();
  }

  private IProject getProject() {
    IAdaptable adaptable = this.getElement();
    return (IProject) adaptable.getAdapter(IProject.class);
  }

  private void initializeValues() {
    ProjectItemMetadata prefs = getPreferences();
    String serverUrl = "";
    String dartFile = "";
    String asTargetPath = "";
    String jsTargetPath = "";
    String objCTargetPath = "";
    String asEnabled = "false";
    String jsEnabled = "false";
    String objCEnabled = "false";
    String debugEnabled = "true";

    try {
      serverUrl = prefs.get(ProjectItemMetadata.DEVSERVER_URL_KEY);
    } catch (CoreException e) {
      logger.log(Level.SEVERE, "Project Persistance failed for dev server url.");
    }
    try {
      dartFile = prefs.get(ProjectItemMetadata.DART_SCRIPT_KEY);
    } catch (CoreException e) {
      logger.log(Level.SEVERE, "Project Persistance failed for dart root.");
    }
    try {
      asTargetPath = prefs.get(ProjectItemMetadata.DART_AS_COMPILE_TARGETPATH_KEY);
    } catch (CoreException e) {
      logger.log(Level.SEVERE, "Project Persistance failed for dart compile output path.");
    }
    try {
      jsTargetPath = prefs.get(ProjectItemMetadata.DART_JS_COMPILE_TARGETPATH_KEY);
    } catch (CoreException e) {
      logger.log(Level.SEVERE, "Project Persistance failed for dart compile output path.");
    }

    try {
      objCTargetPath = prefs.get(ProjectItemMetadata.DART_OBJC_COMPILE_TARGETPATH_KEY);
    } catch (CoreException e) {
      logger.log(Level.SEVERE, "Project Persistance failed for dart compile output path.");
    }

    try {
      asEnabled = prefs.get(ProjectItemMetadata.DART_AS_COMPILE_ENABLED_KEY);
    } catch (CoreException e) {
      logger.log(Level.SEVERE, "Project Persistance failed for dart compile option.");
    }

    try {
      jsEnabled = prefs.get(ProjectItemMetadata.DART_JS_COMPILE_ENABLED_KEY);
    } catch (CoreException e) {
      logger.log(Level.SEVERE, "Project Persistance failed for dart compile option.");
    }

    try {
      objCEnabled = prefs.get(ProjectItemMetadata.DART_OBJC_COMPILE_ENABLED_KEY);
    } catch (CoreException e) {
      logger.log(Level.SEVERE, "Project Persistance failed for dart compile output path.");
    }

    try {
      debugEnabled = prefs.get(ProjectItemMetadata.DEBUG_ENABLED_KEY);
    } catch (CoreException e) {
      logger.log(Level.SEVERE, "Project Persistance failed for debug enabled.");
    }

    if (serverUrl == null) {
      serverUrl = "http://localhost:8421";
    }
    devServerUrl.setText(serverUrl);
    if (dartFile != null) {
      dartScriptPath.setText(dartFile);
    }
    if (asTargetPath != null) {
      dartAsTargetPath.setText(asTargetPath);
    }
    if (jsTargetPath != null) {
      dartJsTargetPath.setText(jsTargetPath);
    }
    if (objCTargetPath != null) {
      dartObjCTargetPath.setText(objCTargetPath);
    }
    dartAsTargetEnabled.setSelection(asEnabled != null && asEnabled.equals("true"));
    dartJsTargetEnabled.setSelection(jsEnabled != null && jsEnabled.equals("true"));
    dartObjCTargetEnabled.setSelection(objCEnabled != null && objCEnabled.equals("true"));
    debugModeEnabled.setSelection(debugEnabled != null && debugEnabled.equals("true"));
  }

  /**
   * Store code generation settings for IProject/IFile nodes
   */
  private void storeValues() {
    ProjectItemMetadata preferences = getPreferences();
    try {
      preferences.put(ProjectItemMetadata.DEVSERVER_URL_KEY, devServerUrl.getText());
      preferences.put(ProjectItemMetadata.DART_SCRIPT_KEY, dartScriptPath.getText());
      preferences.put(ProjectItemMetadata.DART_AS_COMPILE_TARGETPATH_KEY,
          dartAsTargetPath.getText());
      preferences.put(ProjectItemMetadata.DART_JS_COMPILE_TARGETPATH_KEY,
          dartJsTargetPath.getText());
      preferences.put(ProjectItemMetadata.DART_OBJC_COMPILE_TARGETPATH_KEY,
          dartObjCTargetPath.getText());
      preferences.put(ProjectItemMetadata.DART_AS_COMPILE_ENABLED_KEY,
          dartAsTargetEnabled.getSelection() ? "true" : "false");
      preferences.put(ProjectItemMetadata.DART_JS_COMPILE_ENABLED_KEY,
          dartJsTargetEnabled.getSelection() ? "true" : "false");
      preferences.put(ProjectItemMetadata.DART_OBJC_COMPILE_ENABLED_KEY,
          dartObjCTargetEnabled.getSelection() ? "true" : "false");
      preferences.put(ProjectItemMetadata.DEBUG_ENABLED_KEY,
          debugModeEnabled.getSelection() ? "true" : "false");
    } catch (CoreException e) {
      logger.log(Level.SEVERE, "Project Dart codegen preference storage failed." + e.toString());
    }

    // Add nature to project
    ProjectNatureAction.addUxmlNature(getProject());
  }

  private ProjectItemMetadata getPreferences() {
    return UXMLProjectMetadata.getProjectPreferences(getProject());
  }
}
