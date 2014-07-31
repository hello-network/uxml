part of uxml;

/**
 * Implements functionality for selecting and loading local files.
 *
 * @author michjun@ (Michelle Fang)
 */
class FileUpload extends Control {
  static InputElement _input;
  static EventDef filesLoadedEvent = null;
  static EventDef filesCanceledEvent = null;

  String _acceptTypes;
  bool _multiple;
  Model _files;

  var dataLoadHandler;
  bool loadBytes = false;
  bool loadImage = true;

  StreamSubscription<Event> _fileChangeSub;
  StreamSubscription<Event> _fileCancelSub;
  StreamSubscription<Event> _dataLoadSub;
  StreamSubscription<Event> _imageLoadSub;

  FileUpload() : super() {
    if (filesLoadedEvent == null) {
      filesLoadedEvent = new EventDef("filesLoaded", Route.DIRECT);
    }
    if (filesCanceledEvent == null) {
      filesCanceledEvent = new EventDef("filesCanceled", Route.DIRECT);
    }
    _acceptTypes = "";
    _multiple = false;
    _createFileInput();
  }

  /**
   * Sets/Returns the accept file types.
   */
  set accept(String fileTypes) {
    _acceptTypes = fileTypes;
    _input.accept = _acceptTypes;
  }

  String get accept => _acceptTypes;

  /**
   * Sets/Returns if the file picker allows multiple selection.
   */
  set multiple(bool allowMultiple) {
    _multiple = allowMultiple;
    _input.multiple = _multiple;
  }

  bool get multiple => _multiple;

  /**
   * Returns the files.
   */
  Model get files => _files;

  void _createFileInput() {
    if (_input == null) {
      _input = new Element.tag("input");
      _input.type = "file";
      _input.style.position = "absolute";
      _input.style.top = "-100px";
      _input.accept = _acceptTypes;
      _input.multiple = _multiple;
      document.body.nodes.add(_input);
    }
    _fileChangeSub = _input.onChange.listen((Event event) {
        _handleFiles(_input.files);
      });
    // TODO(michjun): abort never called. Find alternative way. blur? focus?.
    _fileCancelSub = _input.onAbort.listen((Event event) {
        notifyListeners(filesCanceledEvent, new EventArgs(this));
      });
  }

  void close() {
    _fileChangeSub.cancel();
    _fileChangeSub = null;
    _fileCancelSub.cancel();
    _fileCancelSub = null;
  }

  void _handleFiles(List<File> files) {
    // TODO(michjun): check types
    _files = new Model();
    for (int j = 0; j < files.length; j++) {
      File fileItem = files[j];
      Model fileData = new Model();

      fileData.setMember("name", fileItem.name);
      fileData.setMember("size", fileItem.size);
      FileReader reader = new FileReader();
      dataLoadHandler = (Event e) {
        Blob buffer = reader.result;
        fileData.setMember("sourceData", buffer);
        _dataLoadSub.cancel();
        _dataLoadSub = null;
        dataLoadHandler = null;
      };
      if (loadImage) {
        _imageLoadSub = reader.onLoad.listen((Event e) {
            fileData.setMember("source", reader.result);
            _imageLoadSub.cancel();
            _imageLoadSub = null;
            if (loadBytes) {
              reader = new FileReader();
              _dataLoadSub = reader.onLoad.listen(dataLoadHandler);
              reader.readAsArrayBuffer(fileItem);
            }
          });
        reader.readAsDataUrl(fileItem);
      } else if (loadBytes){
        _dataLoadSub = reader.onLoad.listen(dataLoadHandler);
        reader.readAsArrayBuffer(fileItem);
      }
      _files.addChild(fileData);
    }
    notifyListeners(filesLoadedEvent, new EventArgs(this));
  }

  /**
   * Opens the local file selector.
   */
  void openFileDialog() {
    if (Application.isSafari) {
      // Temporary fix for safari first time click simulation not triggering.
      // Don't know why the input element is already successfully inserted but
      // it just wouldn't get the click event immediately.
      // TODO(michjun): remove this hacky fix eventually.
      UIPlatform.setTimeout(() {
        _input.click();
      }, 50);
    } else {
      _input.click();
    }
  }
}
