library hellouxml;

import 'dart:html';
import 'package:uxml/uxml.dart';

part '../genfiles/main_page.g.dart';

void main() {
  Element element = querySelector("#mainDiv");
  Application app = new MainPage();
  app.initialize(window);
}
