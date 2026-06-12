package main

import "base:runtime"
import "core:fmt"
import "core:os"
import "core:strings"

import gio  "../gtk4m/gio"
import glib "../gtk4m/glib"
import gobj "../gtk4m/gobject"
import gtk  "../gtk4m/gtk"


Button1ClickedCB :: proc "c" (button :^gtk.Button, cbData :glib.pointer) {
  context = runtime.default_context()
  appwin := cast(^gtk.Window)cbData
  fmt.printf("Button1ClickedCB: appwin %p [%T]\n", appwin, appwin)
}

Button2ClickedCB :: proc "c" (button :^gtk.Button, cbData :glib.pointer) {
  context = runtime.default_context()
  hbox := cast(^gtk.Box)cbData
  fmt.printf("Button2ClickedCB: hbox %p [%T]\n", hbox, hbox)
}
WrapToggledCB :: proc "c" (button :^gtk.Button, cbData :glib.pointer) {
  context = runtime.default_context()
  wmptr := cast(^gtk.WrapMode)cbData
  mode := wmptr^
  gobj.set_int_property(cast(^gobj.Object)V_textview, "wrap_mode", i32(mode))
}

ButtonClickedCB :: proc "c" (button :^gtk.Widget, cbData :glib.pointer) {
  tag := cast(gtk.TextTag)cbData
  bounds = V_textbuffer.get_selection_bounds()
  if len(bounds) != 0 {
    start, end = bounds
    self.textbuffer.apply_tag(tag, start, end)
  }
}

ClearClickedCB :: proc "c" (sender :^gtk.Widget, cbData :glib.pointer) {
  start := gtk.TextIter{}
  end   := gtk.TextIter{}
  gtk.text_buffer_get_start_iter(V_textbuffer, &start)
  gtk.text_buffer_get_start_iter(V_textbuffer, &end)
  gtk.text_buffer_remove_all_tags(V_textbuffer, &start, &end)
}

JustifyToggledCB :: proc "c" (sender :^gtk.Widget, cbData :glib.pointer) {
  justptr := cast(^gtk.Justifiation)cbData
  justification := justptr^
  V_textview.props.justification = justification
}

FindClicked :: proc "c" (sender :^gtk.Widget, cbData :glib.pointer) {
  cursor_mark = self.textbuffer.get_insert()
  start = self.textbuffer.get_iter_at_mark(cursor_mark)
  if start.get_offset() == self.textbuffer.get_char_count() {
    start = self.textbuffer.get_start_iter()
    }

  SearchAndMark(self.search_dialog.entry.get_text(), start)
}

SearchAndMark :: proc(text, start) {
  end = V_textbuffer.get_end_iter()
  match = start.forward_search(text, 0, end)

  if match != nil {
    match_start, match_end = match
    V_textbuffer.apply_tag(self.tag_found, match_start, match_end)
    SearchAndMark(text, match_end)
  }
}

SearchClickedCB :: proc "c" (sender :^gtk.Widget, cbData :glib.pointer) {
  if V_search_dialog == nil {
    parent := cast(^gtk.Widget)cbData
    V_search_dialog := gtk.window_new()
    gtk.window_set_title(V_search_dialog, "Search")
    gtk.window_set_modal(V_search_dialog, true)
    gtk.window_set_transient_for(V_search_dialog, parent)

    box = gtk.box_new(gtk.Orientation.VERTICAL, spacing=12)
    gtk.window_set_child(V_search_dialog, box)

    label := gtk.label_new("Insert text you want to search for:")
    gtk.box_append(box, label)

    V_entry = gtk.entry_new()
    gtk.box_append(box, V_entry)

    button := gtk.button_new_with_label("Find")
    gtk.box_append(box, button)

//    V_search_dialog.button.connect("clicked", self.on_find_clicked)
  }
  gtl.window_present(V_search_dialog)
}



V_textview      :^gtk.TextView = nil
V_textbuffer    :^gtk.Textbuffer = nil
V_tag_bold      :^gtk.TextTag = nil
V_tag_italic    :^gtk.TextTag = nil
V_tag_underline :^gtk.TextTag = nil
V_tag_found     :^gtk.TextTag = nil

CreateTextView :: proc(app :^gtk.Application, vbox :^gtk.Box) {
  scrolledwindow = gtk.scrolled_window_new()
  gtk.widget_set_hexpand(scrolledwindow, true)
  gtk.widget_set_vexpand(scrolledwindow, true)
  gtk.box.append(vbox, scrolledwindow)

  V_textview = gtk.text_view_new()
  V_textbuffer = gtk.text_view_get_buffer(V_textview)
  gtk.text_buffer.set_text(V_textbuffer,
`This is some text inside of a Gtk.TextView. 
Select text and click one of the buttons "bold", "italic", 
or "underline" to modify the text accordingly.`)
  gtk.window_set_child(scrolledwindow, V_textview)

  V_tag_bold = gtk.text_buffer_create_tag(V_textbuffer, "bold",
                   "weight", pango.Weight.BOLD)
  V_tag_italic = gtk.text_buffer_create_tag(V_textbuffer, "italic",
                   "style", pango.Style.ITALIC)
  V_tag_underline = gtk.text_buffer_create_tag(V_textbuffer, "underline",
                        "underline", pango.Underline.SINGLE)
  V_tag_found = gtk.text_buffer_create_tag(V_textbuffer, "found",
                    "background", cstring("yellow"))
}


CreateToolBar :: proc(app :^gtk.Application, vbox :^gtk.Box) { // , self):
  toolbar := gtk.box_new(gtk.Orientation.HORIZONTAL, spacing=6)
  gtk.widget_set_margin_top(toolbar, 6)
  gtk.widget_set_margin_start(toolbar, 6)
  gtk.widget_set_margin_end(toolbar,  6)
  gtk.box_prepend(vbox, toolbar)

  button_bold := gtk.button_new_from_icon_name("format-text-bold-symbolic")
  gobj.signal_connect(button_bold, "clicked",
                      cast(gobj.Callback)ButtonClickedCB, V_tag_bold)
  gtk.box_append(toolbar, button_bold)

  button_italic := gtk.button_new_from_icon_name("format-text-italic-symbolic")
  gobj.signal_connect(button_italic, "clicked",
                      cast(gobj.Callback)ButtonClickedCB, V_tag_italic)
  gtk.box_append(toolbar, button_italic)

  button_underline := gtk.button_new_from_icon_name("format-text-underline-symbolic")
  gobj.signal_connect(button_underline, "clicked",
                      cast(gobj.Callback)ButtonClickedCB, V_tag_underline)
  gtk.box_append(toolbar, button_underline)

  gtk.box_append(toolbar, gtk.separator_new(gtk.Orientation.VERTICAL))

  justifyleft := gtk.toggle_button_new_from_icon_name("format-justify-left-symbolic")
  gtk.box_append(toolbar, justifyleft)

  justifycenter := gtk.toggle_button_new_from_icon_name("format-justify-center-symbolic")
  gtk.toggle_button_set_group(justifycenter, justifyleft)
  gtk.box_append(toolbar, justifycenter)

  justifyright := gtk.toggle_button_new_from_icon_name("format-justify-right-symbolic")
  gtk.toggle_button_set_group(justifyright, justifyleft)
  gtk.box_append(toolbar, justifyright)

  justifyfill := gtk.toggle_button_new_from_icon_name("format-justify-fill-symbolic")
  gtk.toggle_button_set_group(justifyfill, justifyleft)
  gtk.box_append(toolbar, justifyfill)


  @static justLeft := gtk.Justification.LEFT
  gobj.signal_connect(justifyleft, "toggled",
                      cast(gobj.Callback)JustifyToggledCB, gtk.Justification.LEFT)
  gobj.signal_connect(justifycenter, "toggled",
                      cast(gobj.Callback)JustifyToggledCB, gtk.Justification.CENTER)
  gobj.signal_connect(justifyright, "toggled",
                      cast(gobj.Callback)JustifyToggledCB, gtk.Justification.RIGHT)

  gobj.signal_connect(justifyfill, "toggled",
                      cast(gobj.Callback)JustifyToggledCB, gtk.Justification.FILL)

  gtk.box_append(toolbar, gtk.separator_new())

  button_clear := gtk.button_new_from_icon_name("edit-clear-symbolic")
        button_clear.connect("clicked", self.on_clear_clicked)
  gtk.box_append(toolbar, button_clear)

  gtk.box_append(toolbar, gtk.separator_new())

  button_search := gtk.button_new_from_icon_name("system-search-symbolic")
  gobj.signal_connect(button_search, "clicked",
                      cast(gobj.Callback)SearchClickedCB, nil)
  gtk.box_append(toolbar, button_search)
}


CreateButtons :: proc(app :^gtk.Application, vbox :^gtk.Box) {
  grid := gtk.grid_new()
  gtk.box_append(vbox, grid)

  check_editable := gtk.check_button_new_with_label("Editable")
  gtk.check_button_set_active(cast(^gtk.CheckButton)check_editable, true)
//check_editable.bind_property("active", self.textview, "editable", 0)
  gobj.object_bind_property(check_editable, "active", V_textview, "editable", 0)
  gtk.grid_attach(grid, check_editable, 0, 0, 1, 1)

  check_cursor := gtk.check_button_new_with_label("Cursor Visible")
  gtk.check_button_set_active(cast(^gtk.CheckButton)check_cursor, true)
//  check_cursor.bind_property("active", self.textview, "cursor_visible", 0)
  gobj.object_bind_property(check_cursor, "active", V_textview, "cursor_visible", 0) 
  gtk.grid_attach_next_to(grid, check_cursor, check_editable,
      gtk.PositionType.RIGHT, 1, 1)

  radio_wrapnone := gtk.check_button_new_with_label("No Wrapping")
  gtk.check_button_set_active(cast(^gtk.CheckButton)radio_wrapnone, true)
  gtk.grid_attach(grid, radio_wrapnone, 0, 1, 1, 1)

  radio_wrapchar := gtk.check_button_new_with_label("Character Wrapping")
  gtk.check_button_set_group(cast(^gtk.CheckButton)radio_wrapchar,
                              group=cast(^gtk.CheckButton)radio_wrapnone)
  gtk.grid_attach_next_to(grid, radio_wrapchar, radio_wrapnone,
      gtk.PositionType.RIGHT, 1, 1)

  radio_wrapword := gtk.check_button_new_with_label("Word Wrapping")
  gtk.check_button_set_group(cast(^gtk.CheckButton)radio_wrapword,
                              group=cast(^gtk.CheckButton)radio_wrapnone)
  gtk.grid_attach_next_to(grid, radio_wrapword, radio_wrapchar,
      gtk.PositionType.RIGHT, 1, 1)

  gobj.signal_connect(radio_wrapnone, "toggled",
                     cast(gobj.Callback)WrapToggledCB, Gtk.WrapMode.NONE)
  gobj.signal_connect(radio_wrapchar, "toggled",
                     cast(gobj.Callback)WrapToggledCB, Gtk.WrapMode.CHAR)
  gobj.signal_connect(radio_wrapword, "toggled",
                     cast(gobj.Callback)WrapToggledCB, Gtk.WrapMode.WORD)
}


AppActivateCB :: proc "c" (app :^gtk.Application, user_data :glib.pointer) {
  context = runtime.default_context()

  appwgt := gtk.application_window_new(app)
  appwin := cast(^gtk.Window)appwgt
  gtk.window_set_title(appwin, "TextView Demo")
  gtk.window_set_default_size(appwin, 500, 400)

  vbox := gtk.box_new(gtk.Orientation.VERTICAL, spacing=6)
  gtk.window_set_child(appwin, vbox)

  button1 := gtk.button_new_with_label("Hello")
  gobj.signal_connect(button1, "clicked",
                     cast(gobj.Callback)Button1ClickedCB, appwin)
  gtk.box_append(cast(^gtk.Box)hbox, button1)
  fmt.printf("AppActivateCB: appwin %p [%T]\n", appwin, appwin)

  CreateTextView(app, vbox)
  CreateToolBar(app, vbox)
  CreateButtons(app, vbox)

  gtk.window_present(appwin)
}


//
// MAIN
//
main :: proc() {

  cbArg :cstring = "CB Arg"
  app := gtk.application_new("com.example.textview",
                             gio.ApplicationFlags.APPLICATION_DEFAULT_FLAGS)
  gobj.signal_connect(app, "activate",
                      cast(gobj.Callback)AppActivateCB,
                      cast(glib.pointer)&cbArg)

  argv := make([]cstring, len(os.args))
  for &arg, idx in argv {
    arg = strings.clone_to_cstring(os.args[idx])
  }
  defer delete(argv)
  defer for arg in argv do delete(arg)
  argc := i32(len(argv))

  sts := gio.application_run(
             gobj.type_cast(gio.Application, app, gio.TYPE_APPLICATION()),
             argc, raw_data(argv))      
  gobj.object_unref(app)

  if sts != 0 {
    os.exit(int(sts))
  }
}      
