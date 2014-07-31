// @author ferhat@ (Ferhat Buyukkokten)
// @author ericarnold@ (Eric Arnold)
library alltests;

import 'dart:html';
import 'dart:math' hide Rectangle;
import '../lib/uxml.dart';

import 'package:unittest/unittest.dart';

part 'app_test_case.dart';
part 'application_test.dart';
part 'brush_test.dart';
part 'brush_tweener_test.dart';
part 'button_test.dart';
part 'canvas_test.dart';
part 'checkbox_test.dart';
part 'chrome_test.dart';
part 'clipboard_data_test.dart';
part 'color_test.dart';
part 'content_container_test.dart';
part 'control_test.dart';
part 'dockbox_test.dart';
part 'dropdown_button_test.dart';
part 'element_collection_test.dart';
part 'element_registry_test.dart';
part 'element_def_test.dart';
part 'ellipse_shape_test.dart';
part 'event_args_test.dart';
part 'event_definition_test.dart';
part 'event_notifier_test.dart';
part 'filter_test.dart';
part 'focus_manager_test.dart';
part 'grid_test.dart';
part 'grid_def_test.dart';
part 'grid_column_test.dart';
part 'grid_row_test.dart';
part 'group_test.dart';
part 'hbox_test.dart';
part 'items_test.dart';
part 'items_container_test.dart';
part 'labeled_control_test.dart';
part 'layout_system_test.dart';
part 'line_shape_test.dart';
part 'list_base_test.dart';
part 'margin_test.dart';
part 'matrix_test.dart';
part 'model_test.dart';
part 'overlay_container_test.dart';
part 'panel_test.dart';
part 'path_test.dart';
part 'path_shape_test.dart';
part 'path_tokenizer_test.dart';
part 'pen_test.dart';
part 'progress_control_test.dart';
part 'property_binding_test.dart';
part 'protocol_buffer_test.dart';
part 'property_definition_test.dart';
part 'popup_test.dart';
part 'radio_button_test.dart';
part 'rect_shape_test.dart';
part 'scrollbar_test.dart';
part 'scrollbox_test.dart';
part 'slider_test.dart';
part 'solid_pen_test.dart';
part 'string_util_test.dart';
part 'textbox_test.dart';
part 'tween_utils_test.dart';
part 'ui_transform_test.dart';
part 'ui_element_container_test.dart';
part 'ui_element_test.dart';
part 'ui_element_hit_test.dart';
part 'ui_surface_test.dart';
part 'uxml_element_test.dart';
part 'vbox_test.dart';
part 'wrapbox_test.dart';


main() {
  Application app = new Application();
  new ElementRegistryTest().testAll();
  new ElementDefTest().testAll();
  new PropertyDefinitionTest().testAll();
  new UxmlElementTest().testAll();
  new BrushTest().testAll();
  new BrushTweenerTest().testAll();
  new TweenUtilsTest().testAll();
  new MatrixTest().testAll();
  new ColorTest().testAll();
  new SolidPenTest().testAll();
  new PathTokenizerTest().testAll();
  new PathTest().testAll();
  new RectShapeTest().testAll();
  new EllipseShapeTest().testAll();
  new PenTest().testAll();
  new TransformTest().testAll();
  new PathTokenizerTest().testAll();
  new LineShapeTest().testAll();
  new MarginTest().testAll();
  new EventArgsTest().testAll();
  new ApplicationTest().testAll();

  new ButtonTest().testAll();
  new CanvasTest().testAll();
  new CheckBoxTest().testAll();
  new ChromeTest().testAll();
  new ClipboardDataTest().testAll();
  // new ContentContainerTest().testAll();
  new ControlTest().testAll();
  // new DockBoxTest().testAll();
  // TODO(ferhat): implement popup hosting. new DropDownButtonTest().testAll();
  new ElementCollectionTest().testAll();
  new EventDefinitionTest().testAll();
  new GridDefTest().testAll();
  new GridRowTest().testAll();
  new GridColumnTest().testAll();
  new GridTest().testAll();
  new GroupTest().testAll();
  new HBoxTest().testAll();
  new VBoxTest().testAll();
  new WrapBoxTest().testAll();
  new SliderTest().testAll();
  new ScrollBarTest().testAll();
  new ScrollBoxTest().testAll();
  new RadioButtonTest().testAll();
  new LabeledControlTest().testAll();
  new ProgressControlTest().testAll();
  new ItemsTest().testAll();
  new ItemsContainerTest().testAll();
  new UIElementContainerTest().testAll();
  new FocusManagerTest().testAll();
  new UIElementTest().testAll();
  new StringUtilTest().testAll();
  new OverlayContainerTest().testAll();
  new TextBoxTest().testAll();
  new FilterTest().testAll();
  new PopupTest().testAll();
  new PanelTest().testAll();
  new PathTest().testAll();
  new PathShapeTest().testAll();
  new ProtocolBufferTest().testAll();
  new ListBaseTest().testAll();
  new ModelTest().testAll();
  new LayoutSystemTest().testAll();
  new EventNotifierTest().testAll();
  new PropertyBindingTest().testAll();
  new HBoxTest().testAll();
  new UISurfaceTest().testAll();
  new UIElementHitTest().testAll();
}