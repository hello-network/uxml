package com.hello.uxml.tools.core.internal.dartf;

import com.google.common.collect.Lists;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NamedNodeMap;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.StringReader;
import java.io.UnsupportedEncodingException;
import java.net.ConnectException;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLEncoder;
import java.util.List;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;

/**
 * Compiles dart code to actionscript using frog compiler/FrogDevServer.
 *
 * @author ferhat
 */
public class DartToXCompiler {
  // Language ids.
  public static final String LANG_AS = "as";
  public static final String LANG_JS = "js";
  public static final String LANG_OBJC = "objc";

  // Holds workspace handle returned from DevServer.
  private String workspaceId = "";

  // Startup file for dart project.
  private String dartStartup = "";
  private String serverUrl = "";

  // Currently active dart startup, used to create a workspace.
  @SuppressWarnings("unused")
  private String activeStartup = "";
  private List<String> targets;
  private List<CompilerMessage> messages;
  private static final int SERVER_ERROR_IO = -1;
  private static final int SERVER_ERROR_MALFORMED_RESULT = -2;
  private static final int SERVER_SUCCESS = 0;
  private static final int SERVER_ERROR_WORKSPACE_ID = 1000;
  private int responseCode = SERVER_SUCCESS;

  List<String> targetLang = Lists.newArrayList();
  List<Boolean> targetLangEnabled = Lists.newArrayList();
  List<String> targetLangPath = Lists.newArrayList();

  public DartToXCompiler() {
  }

  /**
   * Sets compile server url.
   * @param url specifies url of server.
   */
  public void setServerUrl(String url) {
    serverUrl = url;
  }

  /**
   * Clears all targets.
   */
  public void clearTargets() {
    targetLang.clear();
    targetLangEnabled.clear();
    targetLangPath.clear();
  }

  /**
   * Sets output directory path.
   * @param path target path.
   */
  public void addTarget(String language, boolean enabled, String path) {
    targetLang.add(language);
    targetLangEnabled.add(enabled);
    targetLangPath.add(path);
  }

  /**
   * Sets startup dart script filename.
   * @param dartFileName name of script file.
   */
  public void setDartStartup(String dartFileName) {
    if ((dartStartup.length() != 0) && (dartStartup.equals(dartFileName) == false)) {
      dartStartup = dartFileName;
      closeWorkspace();
    }
    dartStartup = dartFileName;
  }

  /**
   * Rebuilds all targets.
   */
  public void buildAll() {
    if (serverUrl == null) {
      return;
    }
    getOrCreateWorkspace();
    addTargets();
    if (responseCode == SERVER_ERROR_WORKSPACE_ID) {
      // workspace disconnected, reconnect.
      activeStartup = "";
      getOrCreateWorkspace();
      addTargets();
    }
    Document doc = callDevServer("build", new String[] {"space", workspaceId});
    if (doc != null) {
      readBuildResults(doc);
    }
  }

  private void addTargets() {
    callDevServer("workspace/clean", new String[] {"space", workspaceId});
    for (int t = 0; t < targetLang.size(); t++) {
      callDevServer("workspace/addtarget", new String[] {"space", workspaceId, "lang",
          targetLang.get(t), "enabled", targetLangEnabled.get(t) ? "true" : "false",
          "path", targetLangPath.get(t)});
    }
  }

  /**
   * Incrementally cross-compiles a single dart source file.
   * @param source file to convert.
   */
  public void compileIncremental(File source) {
    buildAll();
    return;
    // TODO(ferhat): Implement incremental compile.
//    if (serverUrl == null) {
//    return;
//  }
//    getOrCreateWorkspace();
//    addTargets();
//    Document doc = callDevServer("ibuild", new String[] {"space", workspaceId,
//        "source", source.getAbsolutePath()});
//    if (responseCode == SERVER_ERROR_WORKSPACE_ID) {
//      // workspace disconnected, reconnect.
//      activeStartup = "";
//      getOrCreateWorkspace();
//      addTargets();
//      doc = callDevServer("ibuild", new String[] {"space", workspaceId,
//          "source", source.getAbsolutePath()});
//    }
//    readBuildResults(doc);
  }

  /**
   * Returns compiler messages.
   * @return list of compile results.
   */
  public List<CompilerMessage> getMessages() {
    return messages;
  }

  private boolean getOrCreateWorkspace() {
    // TODO(Ferhat): if ((dartStartup != activeStartup)
    Document doc = callDevServer("workspace/create", new String[] {"startup", dartStartup});
    if (doc == null) {
      return false;
    }
    Element element = doc.getDocumentElement();
    if (element == null) {
      return false;
    }
    activeStartup = dartStartup;
    if (element.getNodeName().equals("result")) {
      workspaceId = element.getTextContent();
    }
    return doc != null;
  }

  private Document callDevServer(String action, String[] parameters) {
    URL devServer;
    HttpURLConnection dc = null;
    BufferedReader in = null;
    StringBuilder sb = new StringBuilder();
    responseCode = SERVER_SUCCESS;
    try {
      String baseUrl = serverUrl;
      if (!baseUrl.endsWith("/")) {
        baseUrl += "/";
      }
      if ((parameters != null) && (parameters.length != 0)) {
        int p = 0;
        action += "?";
        while (p < parameters.length) {
          if (parameters[p + 1].length() != 0) {
            if (p != 0) {
              action += "&";
            }
            action += parameters[p] + "=" + URLEncoder.encode(parameters[p + 1], "UTF-8");
          }
          p += 2;
        }
      }
      devServer = new URL(baseUrl + action);
      dc = (HttpURLConnection) devServer.openConnection();
      dc.setRequestMethod("GET");
      dc.setReadTimeout(5000);
      in = new BufferedReader(
          new InputStreamReader(dc.getInputStream()));
      String inputLine;
      while ((inputLine = in.readLine()) != null) {
        sb.append(inputLine);
      }
    } catch (ConnectException e) {
      responseCode = SERVER_ERROR_IO;
      return null;
    } catch (MalformedURLException e) {
      responseCode = SERVER_ERROR_IO;
      e.printStackTrace();
      return null;
    } catch (UnsupportedEncodingException e) {
      responseCode = SERVER_ERROR_IO;
      e.printStackTrace();
      return null;
    } catch (IOException e) {
      responseCode = SERVER_ERROR_IO;
      e.printStackTrace();
      return null;
    } finally {
      if (in != null) {
        try {
          in.close();
        } catch (IOException e) {
          e.printStackTrace();
          responseCode = SERVER_ERROR_IO;
        }
      }
    }
    String xmlResult = sb.toString();
    if (xmlResult.length() == 0) {
      responseCode = SERVER_ERROR_IO;
      return null;
    }

    DocumentBuilderFactory df = DocumentBuilderFactory.newInstance();
    DocumentBuilder db;
    try {
      db = df.newDocumentBuilder();
    } catch (ParserConfigurationException e) {
      responseCode = SERVER_ERROR_MALFORMED_RESULT;
      return null;
    }
    Document doc;
    try {
      doc = db.parse(new InputSource(new StringReader(sb.toString())));
    } catch (SAXException e) {
      responseCode = SERVER_ERROR_MALFORMED_RESULT;
      return null;
    } catch (IOException e) {
      responseCode = SERVER_ERROR_MALFORMED_RESULT;
      return null;
    }
    NodeList errors = doc.getElementsByTagName("error");
    if (errors.getLength() != 0) {
      String errorId = errors.item(0).getAttributes().getNamedItem(
          "id").getTextContent();
      if (errorId != null && (errorId.length() > 0)) {
        responseCode = Integer.parseInt(errorId);
      } else {
        responseCode = SERVER_ERROR_MALFORMED_RESULT;
      }
    }
    return doc;
  }

  private void closeWorkspace() {
    workspaceId = "";
  }

  private void readBuildResults(Document doc) {
    readTargets(doc);
    readMessages(doc);
  }

  private void readTargets(Document doc) {
    targets = Lists.newArrayList();
    if (doc != null) {
      NodeList nodeList = doc.getElementsByTagName("target");
      for (int i = 0; i < nodeList.getLength(); i++) {
        Node node = nodeList.item(i);
        targets.add(node.getTextContent());
      }
    }
  }

  private void readMessages(Document doc) {
    messages = Lists.newArrayList();
    if (doc != null) {
      NodeList nodeList = doc.getElementsByTagName("message");
      for (int i = 0; i < nodeList.getLength(); i++) {
        Node node = nodeList.item(i);
        NamedNodeMap attribs = node.getAttributes();
        String type = readStringAttrib(attribs, "type", "");
        String filename = readStringAttrib(attribs, "source", "");
        String lineStr = readStringAttrib(attribs, "line", "0");
        String colStr = readStringAttrib(attribs, "col", "0");
        String message = node.getTextContent();
        int line;
        int col;
        try {
          line = Integer.parseInt(lineStr);
          col = Integer.parseInt(colStr);
        } catch (NumberFormatException e) {
          line = 0;
          col = 0;
        }
        messages.add(new CompilerMessage(type, message, filename, line, col));
      }
    }
  }

  private String readStringAttrib(NamedNodeMap attribs, String name, String defaultVal) {
    Node attribNode = attribs.getNamedItem(name);
    if (attribNode == null) {
      return defaultVal;
    }
    return attribNode.getTextContent();
  }

  /**
   * Returns build targets generated by build/incBuild steps.
   */
  public List<String> getBuildTargets() {
    return targets;
  }

  /**
   * Provides error message details and source location
   * returned from compiler. Used to build eclipse markers.
   */
  public static class CompilerMessage {
    private String type;
    private String message;
    private SourceLocation loc;

    public CompilerMessage(String type, String message,
        String fileName, int line, int col) {
      this.type = type;
      this.message = message;
      this.loc = new SourceLocation(fileName, line, col);
    }

    /**
     * Returns message type.
     * @return message type.
     */
    public String getType() {
      return type;
    }

    /**
     * Returns compiler message.
     * @return message content.
     */
    public String getMessage() {
      return message;
    }

    /**
     * Returns source code location.
     * @return source location.
     */
    public SourceLocation getLocation() {
      return loc;
    }
  }

  /**
   * Provides source code location info.
   */
  public static class SourceLocation {
    private String filename;
    private int line;
    private int col;

    public SourceLocation(String filename, int line , int col) {
      this.filename = filename;
      this.line = line;
      this.col = col;
    }

    /** Returns source file name. */
    public String getFileName() {
      return filename;
    }

    /** Returns line number. */
    public int getLine() {
      return line;
    }

    /** Returns column in source line. */
    public int getCol() {
      return col;
    }
  }
}
