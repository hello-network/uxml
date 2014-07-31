package com.hello.uxml.tools.ui.editor;

import org.eclipse.core.commands.AbstractHandler;
import org.eclipse.core.commands.Command;
import org.eclipse.core.commands.ExecutionEvent;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.jface.action.IMenuListener;
import org.eclipse.jface.action.IMenuManager;
import org.eclipse.jface.action.MenuManager;
import org.eclipse.jface.dialogs.ErrorDialog;
import org.eclipse.swt.widgets.Menu;
import org.eclipse.ui.IEditorInput;
import org.eclipse.ui.IEditorPart;
import org.eclipse.ui.IEditorSite;
import org.eclipse.ui.IFileEditorInput;
import org.eclipse.ui.PartInitException;
import org.eclipse.ui.commands.ICommandService;
import org.eclipse.ui.contexts.IContextService;
import org.eclipse.ui.handlers.HandlerUtil;
import org.eclipse.ui.handlers.IHandlerService;
import org.eclipse.ui.part.MultiPageEditorPart;

/**
 * Implements editor for uxml file type.
 *
 * @author ferhat
 */
public class UXMLEditor extends MultiPageEditorPart {

  private static final String EDIT_MARKUP_CONTEXT_ID =
      "com.google.eclipse.uxmleditor.keybindings.contexts.editMarkup";

  /** Text editor for xml markup on Page0 */
  private UXMLTextEditor textEditor;
  /** The index of the page containing the text editor */
  private int textEditorIndex = 0;
  /** Text editor for xml markup on Page0 */
  private UXMLVisualEditor visualEditor;
  /** The index of the page containing the visual editor */
  private int visualEditorIndex = 1;

  private String fileName = "";

  private static final String REMOVE_TRAILING_WHITESPACE_COMMAND =
    "org.eclipse.ui.edit.text.removeTrailingWhitespace";

  private ColorCache colorCache;

  public UXMLEditor() {
    super();
    colorCache = new ColorCache();
  }

  /**
   * Checks that the input is an instance of <code>IFileEditorInput</code>.
   */
  @Override
  public void init(IEditorSite site, IEditorInput editorInput) throws PartInitException {
    if (!(editorInput instanceof IFileEditorInput)) {
      throw new PartInitException(MessageUtil.getString("InvalidInputToEditor"));
    }
    // Set title to file name
    fileName = ((IFileEditorInput) editorInput).getName();
    this.firePropertyChange(PROP_TITLE);

    super.init(site, editorInput);

    // Setup command context
    IContextService contextService = (IContextService) getSite().getService(IContextService.class);
    contextService.activateContext(EDIT_MARKUP_CONTEXT_ID);

    IHandlerService handlerService = (IHandlerService) getSite().getService(IHandlerService.class);

    AbstractHandler removeWhiteSpaceHandler = new AbstractHandler() {
      public Object execute(ExecutionEvent event) {
          final IEditorPart editor = HandlerUtil.getActiveEditor(event);
          if (!(editor instanceof UXMLEditor)) {
            return null;
          }
          return ((UXMLEditor) editor).removeTrailingWhiteSpace();
      }
    };

    ICommandService commandSvc = (ICommandService) site.getService(ICommandService.class);
    Command command = commandSvc.getCommand(REMOVE_TRAILING_WHITESPACE_COMMAND);
    handlerService.activateHandler(command.getId(), removeWhiteSpaceHandler);
  }

  @Override
  public String getTitle() {
    return fileName;
  }

  /**
   * Creates the pages of the multi-page editor.
   */
  @Override
  protected void createPages() {
      createTextEditorPage();
      createVisualDesignerPage();
      createContextMenu();
  }

  /**
   * Creates context menu for editor.
   */
  private void createContextMenu() {
    MenuManager menuMgr = new MenuManager("#PopupMenu");
    menuMgr.setRemoveAllWhenShown(true);
    menuMgr.addMenuListener(new IMenuListener() {
        public void menuAboutToShow(IMenuManager menuMgr) {
          visualEditor.populateContextMenu(menuMgr);
        }
    });
    Menu menu = menuMgr.createContextMenu(visualEditor);
    visualEditor.setMenu(menu);
    getSite().registerContextMenu(menuMgr, visualEditor);
  }

  private void createTextEditorPage() {
    try {
      textEditor = new UXMLTextEditor(colorCache);
      textEditorIndex = addPage(textEditor, getEditorInput());
      setPageText(textEditorIndex, MessageUtil.getString("Source"));
    } catch (PartInitException e) {
      ErrorDialog.openError(
          getSite().getShell(),
          MessageUtil.getString("ErrorCreatingNestedEditor"), null, e.getStatus());
    }
  }

  private void createVisualDesignerPage() {
    visualEditor = new UXMLVisualEditor(this.getContainer());
    visualEditorIndex = addPage(visualEditor);
    setPageText(visualEditorIndex, MessageUtil.getString("Design"));
    getSite().setSelectionProvider(visualEditor);
  }

  /**
   * Saves the editor's document.
   */
  @Override public void doSave(IProgressMonitor monitor) {
    if ((getActivePage() == 1) && visualEditor.isDirty()) {
      updateTextEditorFromVisual();
    }
    getEditor(0).doSave(monitor);
  }

  /* (non-Javadoc)
   * @see IEditorPart.
   */
  @Override public boolean isSaveAsAllowed() {
      return true;
  }

  /**
   * Saves the editor's document as another file.
   * set the title of the editor to new file name
   */
  @Override public void doSaveAs() {
    if ((getActivePage() == 1) && visualEditor.isDirty()) {
      updateTextEditorFromVisual();
    }
    IEditorPart editor = getEditor(0);
    editor.doSaveAs();
    setPageText(0, editor.getTitle());
    setInput(editor.getEditorInput());
  }

  /**
   * When page changed to visual designer, sync the visual design with new markup changes
   */
  @Override protected void pageChange(int newPageIndex) {
    super.pageChange(newPageIndex);
    if (newPageIndex == visualEditorIndex) {
      if (isDirty()) {
        updateVisualEditorFromText();
      }
    } else if (newPageIndex == textEditorIndex) {
      if (visualEditor.isDirty()) {
        updateTextEditorFromVisual();
      }
    }
  }

  private void updateVisualEditorFromText() {
    UXMLDocumentProvider docProvider = (UXMLDocumentProvider) textEditor.getDocumentProvider();
    docProvider.textToModel(this.getEditorInput());
    visualEditor.syncModel(docProvider.getModel());
  }

  private void updateTextEditorFromVisual() {
    UXMLDocumentProvider docProvider = (UXMLDocumentProvider) textEditor.getDocumentProvider();
    docProvider.modelToText(docProvider.getModel());
    visualEditor.resetDirty();
  }

  public boolean removeTrailingWhiteSpace() {
    if (textEditor != null) {
      textEditor.removeTrailingWhiteSpace();
    }
    return true;
  }

  public void dispose() {
    colorCache.dispose();
    super.dispose();
  }
}
