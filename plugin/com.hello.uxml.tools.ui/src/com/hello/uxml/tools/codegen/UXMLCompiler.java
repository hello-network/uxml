package com.hello.uxml.tools.codegen;

import com.google.common.collect.Lists;
//import com.google.common.hash.Hashing;
import com.google.common.io.Closeables;
import com.hello.uxml.tools.framework.Application;
import com.hello.uxml.tools.framework.Border;
import com.hello.uxml.tools.framework.BorderRadius;
import com.hello.uxml.tools.framework.Button;
import com.hello.uxml.tools.framework.Canvas;
import com.hello.uxml.tools.framework.CheckBox;
import com.hello.uxml.tools.framework.Chrome;
import com.hello.uxml.tools.framework.ComboBox;
import com.hello.uxml.tools.framework.Command;
import com.hello.uxml.tools.framework.ContentContainer;
import com.hello.uxml.tools.framework.Control;
import com.hello.uxml.tools.framework.DisclosureBox;
import com.hello.uxml.tools.framework.DockBox;
import com.hello.uxml.tools.framework.DropDownButton;
import com.hello.uxml.tools.framework.EllipseShape;
import com.hello.uxml.tools.framework.Grid;
import com.hello.uxml.tools.framework.GridColumn;
import com.hello.uxml.tools.framework.GridColumns;
import com.hello.uxml.tools.framework.GridRow;
import com.hello.uxml.tools.framework.GridRows;
import com.hello.uxml.tools.framework.Group;
import com.hello.uxml.tools.framework.HBox;
import com.hello.uxml.tools.framework.Image;
import com.hello.uxml.tools.framework.Item;
import com.hello.uxml.tools.framework.ItemsContainer;
import com.hello.uxml.tools.framework.Label;
import com.hello.uxml.tools.framework.LabeledControl;
import com.hello.uxml.tools.framework.LineShape;
import com.hello.uxml.tools.framework.ListBox;
import com.hello.uxml.tools.framework.Margin;
import com.hello.uxml.tools.framework.OverlayContainer;
import com.hello.uxml.tools.framework.PageControl;
import com.hello.uxml.tools.framework.Panel;
import com.hello.uxml.tools.framework.PathShape;
import com.hello.uxml.tools.framework.Popup;
import com.hello.uxml.tools.framework.ProgressControl;
import com.hello.uxml.tools.framework.RadioButton;
import com.hello.uxml.tools.framework.RectShape;
import com.hello.uxml.tools.framework.Resources;
import com.hello.uxml.tools.framework.ScrollBar;
import com.hello.uxml.tools.framework.ScrollBox;
import com.hello.uxml.tools.framework.Shape;
import com.hello.uxml.tools.framework.SlideBox;
import com.hello.uxml.tools.framework.Slider;
import com.hello.uxml.tools.framework.TabControl;
import com.hello.uxml.tools.framework.TextBox;
import com.hello.uxml.tools.framework.TextEdit;
import com.hello.uxml.tools.framework.ToolTip;
import com.hello.uxml.tools.framework.Transform;
import com.hello.uxml.tools.framework.UIElement;
import com.hello.uxml.tools.framework.UIElementContainer;
import com.hello.uxml.tools.framework.VBox;
import com.hello.uxml.tools.framework.ValueRangeControl;
import com.hello.uxml.tools.framework.WaitIndicator;
import com.hello.uxml.tools.framework.WrapBox;
import com.hello.uxml.tools.framework.effects.AnimateAction;
import com.hello.uxml.tools.framework.effects.Effect;
import com.hello.uxml.tools.framework.effects.PropertyAction;
import com.hello.uxml.tools.framework.graphics.BevelFilter;
import com.hello.uxml.tools.framework.graphics.BlurFilter;
import com.hello.uxml.tools.framework.graphics.Brush;
import com.hello.uxml.tools.framework.graphics.Color;
import com.hello.uxml.tools.framework.graphics.DropShadowFilter;
import com.hello.uxml.tools.framework.graphics.Filters;
import com.hello.uxml.tools.framework.graphics.GlowFilter;
import com.hello.uxml.tools.framework.graphics.GradientStop;
import com.hello.uxml.tools.framework.graphics.LinearBrush;
import com.hello.uxml.tools.framework.graphics.VecPath;
import com.hello.uxml.tools.framework.graphics.RadialBrush;
import com.hello.uxml.tools.framework.graphics.SolidBrush;
import com.hello.uxml.tools.framework.graphics.SolidPen;
import com.hello.uxml.tools.codegen.dom.Model;
import com.hello.uxml.tools.codegen.dom.ModelParser;
import com.hello.uxml.tools.codegen.dom.ModelReflector;
import com.hello.uxml.tools.codegen.emit.BuilderFactory;
import com.hello.uxml.tools.codegen.emit.BuilderFactoryRegistry;
import com.hello.uxml.tools.codegen.emit.ClassBuilder;
import com.hello.uxml.tools.codegen.emit.PackageBuilder;
import com.hello.uxml.tools.codegen.emit.SourceWriter;

import org.xml.sax.InputSource;
import org.xml.sax.SAXException;

import java.io.File;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.IOException;
import java.io.OutputStream;
import java.nio.charset.Charset;
import java.util.List;

import javax.xml.parsers.ParserConfigurationException;
import javax.xml.parsers.SAXParser;
import javax.xml.parsers.SAXParserFactory;

/**
 * Compiler for UXML markup files.
 * 
 * <ol>
 * <li>Reads configuration</li>
 * <li>Prepares {@code BuilderFactory}</li>
 * <li>For each hts file, uses PackageBuilder to generate code</li>
 * </ol>
 * 
 * @author ferhat@(Ferhat Buyukkokten)
 */
public class UXMLCompiler {
  private static final String[] MARKUP_EXTENSIONS = new String[] { ".hts",
      ".uxml" };
  private static final String INTERFACE_ID = "Interface";
  private static final String ELEMENT_NAME_ID = "name";
  private static final String COMPONENT_NODE_NAME = "Component";

  /**
   * Compiler configuration (source files, target language,... )
   */
  private final Configuration targetConfig;

  /**
   * Language registry used to create builder factories.
   */
  private final BuilderFactoryRegistry registry;

  /**
   * Compiler error collection
   */
  private final List<CompilerError> errors = Lists.newArrayList();

  /**
   * List of files generated by compiler.
   */
  private final List<File> outputs = Lists.newArrayList();

  /**
   * MD5 checksum of files generated by compiler.
   */
  private final List<String> outputMd5 = Lists.newArrayList();

  /**
   * ModelReflector used for introspection by ModelParser and ModelCompiler.
   */
  private static ModelReflector modelReflector;

  /**
   * Creates hts compiler for given configuration and language registry.
   */
  public UXMLCompiler(Configuration config, BuilderFactoryRegistry registry) {
    targetConfig = config;
    this.registry = registry;
  }

  /**
   * Compiles a set of hts files specified in Configuration.
   * 
   * @return boolean indicating success/failure of code generator
   */
  public boolean compile() {
    boolean success = true;

    // Get BuilderFactory for the target language
    String targetLang = targetConfig.getOutputLanguage();
    File outDir = targetConfig.getTargetDir();
    if ((targetLang == null || targetLang.isEmpty())
        && (outDir == null || outDir.getPath().isEmpty())) {
      return true;
    }
    BuilderFactory factory = registry.getFactory(targetLang);
    if (factory == null) {
      errors.add(new CompilerError(String.format(
          "Unrecognized target language '%s'", targetLang)));
      return false;
    }

    // Compile each hts source file
    for (File htsFile : targetConfig.getSourceFiles()) {
      // continue compilation even on failure so we can collect warnings
      // and errors for all files
      success &= compileHts(targetConfig, htsFile, factory);
    }
    return success;
  }

  /**
   * Compiles a single Hts markup file.
   * 
   * @param htsFile
   *            Markup file
   * @param factory
   *            Target language {@link PackageBuilder} factory
   * @return success/fail of compilations
   */
  private boolean compileHts(Configuration targetConfig, File htsFile,
      BuilderFactory factory) {
    if (!htsFile.canRead()) {
      errors.add(new CompilerError(String.format("\"%s\": no such file",
          htsFile.getName())));
      return false;
    }

    // Create Parser
    try {
      // SAXParser parser =
      // SecureXMLParsing.getSAXParserFactory().newSAXParser();
      SAXParser parser = SAXParserFactory.newInstance().newSAXParser();
      return compileHts(targetConfig, htsFile, factory, parser);
    } catch (ParserConfigurationException e) {
      errors.add(new CompilerError("No XML parser found.", e));
      return false;
    } catch (SAXException e) {
      errors.add(new CompilerError("No XML parser found.", e));
      return false;
    }
  }

  /**
   * Compiles a single Hts markup file by creating a documentBuilder and
   * writing to a target file.
   */
  private boolean compileHts(Configuration targetConfig, File htsFile,
      BuilderFactory factory, SAXParser saxParser) {
    ModelCompiler.initEnv();
    Model markupModel = markupModelFromFile(saxParser, htsFile, errors);
    if (markupModel == null) {
      return false;
    }

    if (!markupModel.hasProperty(ELEMENT_NAME_ID)) {
      errors.add(new CompilerError(
          "Document element is missing name attribute."));
      return false;
    }

    if (markupModel.getTypeName().equals(INTERFACE_ID)) {
      ModelInterface i = new ModelInterface(markupModel);
      return i.verify(errors);
    }

    SourceWriter writer = new SourceWriter();
    PackageBuilder packageBuilder = factory.createPackageBuilder();
    packageBuilder.setPartName(targetConfig.getLibraryName());
    if (!compileHts(targetConfig, markupModel, packageBuilder, writer,
        new ModelImporter(targetConfig, htsFile), htsFile.getName())) {
      return false;
    }
    File targetFile = createTargetFile(htsFile, packageBuilder);
    try {
      if (!(targetFile.getParentFile().exists() && targetFile
          .getParentFile().isDirectory())) {
        if (!targetFile.getParentFile().mkdirs()) {
          errors.add(new CompilerError(String.format(
              "Could not create output directory %s",
              targetFile.getParentFile())));
        }
      }
      if (targetFile.exists()) {
        if (!targetFile.delete()) {
          errors.add(new CompilerError(
              "Could not delete old target file"));
        }
      }
      String content = writer.toString();

      // change from Files.write to internal method to support
      // Java1.5/MacOSX build of plugin
      // Files.write(content, targetFile, Charset.defaultCharset());
      OutputStream outStream = new FileOutputStream(targetFile);
      try {
        outStream.write(content.getBytes(Charset.defaultCharset()
            .name()));
      } finally {
        outStream.close();
      }
      outputs.add(targetFile);
      outputMd5.add(calcMd5(content));
    } catch (IOException e) {
      errors.add(new CompilerError(e));
    }
    return true;
  }

  /**
   * Creates DOM from htsFile
   */
  private static Model markupModelFromFile(SAXParser saxParser, File htsFile,
      List<CompilerError> errors) {
    Model markupModel = null;
    FileReader reader = null;
    try {
      ModelParser modelParser = createModelParser(errors);
      reader = new FileReader(htsFile);
      saxParser.parse(new InputSource(reader), modelParser);
      markupModel = modelParser.getModel();
    } catch (IOException e) {
      CompilerError expError = new CompilerError(e);
      expError.setSource(htsFile.getName());
      errors.add(expError);
      return null;
    } catch (SAXException e) {
      // Add error if ModelParser has not already reported it.
      if (errors.size() == 0) {
        CompilerError parseError = new CompilerError("SAX parse error:"
            + e.toString());
        parseError.setSource(htsFile.getName());
        errors.add(parseError);
      }
      return null;
    } finally {
      Closeables.closeQuietly(reader);
    }
    return markupModel;
  }

  private String calcMd5(String data) {
    return String.valueOf(data.hashCode());
    // return Hashing.md5().hashString(data, Charsets.UTF_8).toString();
  }

  /**
   * Compiles an hts model using a packageBuilder and writes output to
   * sourcewriter.
   */
  private boolean compileHts(Configuration targetConfig, Model htsModel,
      PackageBuilder packageBuilder, SourceWriter writer,
      IUXMLImporter importer, String sourceName) {
    if (!buildPackage(targetConfig, htsModel, packageBuilder, importer,
        sourceName)) {
      return false;
    }
    return packageBuilder.write(writer);
  }

  /**
   * Iterates through xml tree to build package and main class.
   * 
   * @param htsModel
   *            root xml element
   * @param packageBuilder
   *            builder for code generation
   * @param sourceName
   *            name of source file used for compiler error descriptions.
   * @return whether code was successfully generated
   */
  private boolean buildPackage(Configuration targetConfig, Model htsModel,
      PackageBuilder packageBuilder, IUXMLImporter importer,
      String sourceName) {

    String elementName = htsModel.getStringProperty(ELEMENT_NAME_ID);
    String packageName = getPackageName(elementName);
    if (packageName.length() != 0) {
      packageBuilder.setName(packageName);
    }
    String className = getClassName(elementName);
    ClassBuilder classBuilder = packageBuilder.createClass(className);
    classBuilder.setComments("Auto-generated UXML class.");
    ModelCompiler modelComp = new ModelCompiler(htsModel, classBuilder,
        getReflector(), errors, importer, targetConfig);
    modelComp.setSourceName(sourceName);
    return modelComp.compile();
  }

  /**
   * Returns class name from a qualified name (packageName.classname).
   */
  private String getClassName(String qualifiedName) {
    int lastPeriodPos = qualifiedName.lastIndexOf('.');
    return qualifiedName.substring(lastPeriodPos + 1);
  }

  /**
   * Returns package name from a qualified name (packageName.classname).
   */
  private String getPackageName(String qualifiedName) {
    int lastPeriodPos = qualifiedName.lastIndexOf('.');
    return (lastPeriodPos == -1) ? "" : qualifiedName.substring(0,
        lastPeriodPos);
  }

  /**
   * Creates target file given a source markup file.
   */
  private File createTargetFile(File htsFile, PackageBuilder packageBuilder) {
    String targetDir = getTargetDirectory(htsFile);
    if (targetConfig.getTargetDir() != null) {
      String packageName = packageBuilder.getName();
      if ((packageName != null) && (!packageName.equals(""))) {
        targetDir = packageBuilder.getFileTargetDir(targetDir, htsFile,
            packageName, targetConfig.getSourceRoot());
      }
    }
    String targetName = createTargetFileName(htsFile, packageBuilder);
    return new File(targetDir, targetName);
  }

  /**
   * Returns target directory for a given source file. If configuration
   * doesn't specify output path it uses the input file path.
   */
  private String getTargetDirectory(File htsFile) {
    String targetDir = htsFile.getParent();
    return (targetConfig.getTargetDir() != null) ? targetConfig
        .getTargetDir().getAbsolutePath() : targetDir;
  }

  /**
   * Creates a target file name by replacing file extension of a source markup
   * file
   */
  private String createTargetFileName(File htsFile,
      PackageBuilder packageBuilder) {
    String name = htsFile.getName();
    if (targetConfig.getSourceRoot() != null) {
      // compute relative name.
      String relPath = htsFile.getPath();
      String sourceRoot = targetConfig.getSourceRoot().getPath();
      if (relPath.startsWith(sourceRoot)) {
        relPath = relPath.substring(sourceRoot.length() + 1);
      }
      name = relPath;
    }
    for (String extension : MARKUP_EXTENSIONS) {
      if (name.endsWith(extension)) {
        name = name.substring(0, name.length() - extension.length());
      }
    }
    return name + "." + packageBuilder.getDefaultFileExtension();
  }

  /**
   * Creates a model parser and reflector and populates it with framework
   * classes.
   */
  private static ModelParser createModelParser(List<CompilerError> errors) {
    ModelParser modelParser = new ModelParser(getReflector(), errors);
    return modelParser;
  }

  /**
   * Returns a model reflector for UXML.
   * 
   * @return model reflector.
   */
  public static ModelReflector getReflector() {
    if (modelReflector == null) {
      modelReflector = new ModelReflector();
      modelReflector.register(Application.class);
      modelReflector.register(Resources.class);
      modelReflector.register(Color.class);
      modelReflector.register(SolidBrush.class);
      modelReflector.register(LinearBrush.class);
      modelReflector.register(RadialBrush.class);
      modelReflector.register(SolidPen.class);
      modelReflector.register(Shape.class);
      modelReflector.register(VecPath.class);
      modelReflector.register(Group.class);
      modelReflector.register(GradientStop.class);
      modelReflector.register(Margin.class);
      modelReflector.register(BorderRadius.class);
      modelReflector.register(PathShape.class);
      modelReflector.register(WrapBox.class);
      modelReflector.register(LineShape.class);
      modelReflector.register(RectShape.class);
      modelReflector.register(EllipseShape.class);
      modelReflector.register(BlurFilter.class);
      modelReflector.register(DropShadowFilter.class);
      modelReflector.register(HBox.class);
      modelReflector.register(VBox.class);
      modelReflector.register(Canvas.class);
      modelReflector.register(Label.class);
      modelReflector.register(TextBox.class);
      modelReflector.register(TextEdit.class);
      modelReflector.register(Image.class);
      modelReflector.register(Border.class);
      modelReflector.register(Button.class);
      modelReflector.register(Chrome.class);
      modelReflector.register(ContentContainer.class);
      modelReflector.register(Effect.class);
      modelReflector.register(PropertyAction.class);
      modelReflector.register(AnimateAction.class);
      modelReflector.register(Filters.class);
      modelReflector.register(GlowFilter.class);
      modelReflector.register(CheckBox.class);
      modelReflector.register(RadioButton.class);
      modelReflector.register(ListBox.class);
      modelReflector.register(ItemsContainer.class);
      modelReflector.register(DockBox.class);
      modelReflector.register(Panel.class);
      modelReflector.register(OverlayContainer.class);
      modelReflector.register(Transform.class);
      modelReflector.register(LabeledControl.class);
      modelReflector.register(DropDownButton.class);
      modelReflector.register(Popup.class);
      modelReflector.register(ScrollBar.class);
      modelReflector.register(ScrollBox.class);
      modelReflector.register(Item.class);
      modelReflector.register(ComboBox.class);
      modelReflector.register(Control.class);
      modelReflector.register(BevelFilter.class);
      modelReflector.register(Grid.class);
      modelReflector.register(GridColumn.class);
      modelReflector.register(GridColumns.class);
      modelReflector.register(GridRow.class);
      modelReflector.register(GridRows.class);
      modelReflector.register(ToolTip.class);
      modelReflector.register(ValueRangeControl.class);
      modelReflector.register(ProgressControl.class);
      modelReflector.register(Slider.class);
      modelReflector.register(WaitIndicator.class);
      modelReflector.register(PageControl.class);
      modelReflector.register(TabControl.class);
      modelReflector.register(Brush.class);
      modelReflector.register(DisclosureBox.class);
      modelReflector.register(SlideBox.class);
      modelReflector.register(UIElement.class);
      modelReflector.register(Command.class);
      modelReflector.register(UIElementContainer.class,
          COMPONENT_NODE_NAME);
    }
    return modelReflector;
  }

  /**
   * Returns non-empty error collection if compilation fails.
   */
  public List<CompilerError> getErrors() {
    return errors;
  }

  /**
   * Returns list of output files.
   */
  public List<File> getOutputs() {
    return outputs;
  }

  /**
   * Returns list of md5 checksums for output files.
   */
  public List<String> getOutputMd5s() {
    return outputMd5;
  }

  /**
   * Provides hts import service to model compiler.
   * 
   * @author ferhat@
   */
  static class ModelImporter implements IUXMLImporter {

    private final Configuration config;
    private final File baseFile;

    /**
     * Constructor.
     */
    public ModelImporter(Configuration compileConfig, File baseFile) {
      this.baseFile = baseFile;
      config = compileConfig;
    }

    /**
     * @see IUXMLImporter
     */
    @Override
    public Model importModel(String path, List<CompilerError> errors) {
      try {
        // SAXParser parser =
        // SecureXMLParsing.getSAXParserFactory().newSAXParser();
        SAXParser parser = SAXParserFactory.newInstance()
            .newSAXParser();
        File file = new File(baseFile.getParentFile(), path);
        if (!file.exists()) {
          String[] importPaths = config.getImportPaths();
          for (String importPath : importPaths) {
            String importPathTrimmed = importPath.trim();
            file = new File(importPathTrimmed, path);
            if (file.exists()) {
              break;
            }
          }
        }
        if (!file.exists()) {
          return null;
        }
        return UXMLCompiler.markupModelFromFile(parser, file, errors);
      } catch (ParserConfigurationException e) {
        errors.add(new CompilerError("No XML parser found.", e));
        return null;
      } catch (SAXException e) {
        errors.add(new CompilerError("No XML parser found.", e));
        return null;
      }
    }
  }
}
