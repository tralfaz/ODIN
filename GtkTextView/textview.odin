package main

import "base:runtime"
import "core:fmt"
import "core:os"
import "core:strings"

import gio   "../gtk4m/gio"
import glib  "../gtk4m/glib"
import gobj  "../gtk4m/gobject"
import gtk   "../gtk4m/gtk"
import pango "../gtk4m/pango"


WrapToggledCB :: proc "c" (button :^gtk.Button, cbData :glib.pointer) {
  context = runtime.default_context()
  uiData := uintptr(cbData)
  wmptr := cast(gtk.WrapMode)uiData
  mode := wmptr
  gobj.set_int_property(cast(^gobj.Object)V_textview, "wrap_mode", i32(mode))
}

ButtonClickedCB :: proc "c" (button :^gtk.Widget, cbData :glib.pointer) {
  tag := cast(^gtk.TextTag)cbData
  start := gtk.TextIter{}
  end   := gtk.TextIter{}
  bounds := gtk.text_buffer_get_selection_bounds(V_textbuffer, &start, &end)

  if bounds {
    gtk.text_buffer_apply_tag(V_textbuffer, tag, &start, &end)
  }
}

ClearClickedCB :: proc "c" (sender :^gtk.Widget, cbData :glib.pointer) {
  start := gtk.TextIter{}
  gtk.text_buffer_get_start_iter(V_textbuffer, &start)
  end   := gtk.TextIter{}
  gtk.text_buffer_get_end_iter(V_textbuffer, &end)
  gtk.text_buffer_remove_all_tags(V_textbuffer, &start, &end)
}

JustifyToggledCB :: proc "c" (sender :^gtk.Widget, cbData :glib.pointer) {
  context = runtime.default_context()
  cbuint := uintptr(cbData)
//  justification := gtk.Justification(i32(cbuint))
  justification := i32(cbuint)
  gobj.set_int_property(cast(^gobj.Object)V_textview,
                        "justification", justification)
}

FindClickedCB :: proc "c" (sender :^gtk.Widget, cbData :glib.pointer) {
  context = runtime.default_context()

  cursor_mark := gtk.text_buffer_get_insert(V_textbuffer)
//text_buffer_get_insert(buffer: ^TextBuffer) -> ^TextMark ---
  start := gtk.TextIter{}
  gtk.text_buffer_get_iter_at_mark(V_textbuffer, &start, cursor_mark)
  if gtk.text_iter_get_offset(&start) ==
     gtk.text_buffer_get_char_count(V_textbuffer) {
    gtk.text_buffer_get_start_iter(V_textbuffer, &start)
  }

//  entbuf := cast(^gtk.TextBuffer)gtk.entry_get_buffer(V_searchEntry)
  enttxt := gtk.editable_get_text(cast(^gtk.Editable)V_searchEntry) 
  SearchAndMark(enttxt, &start)
}

SearchAndMark :: proc(text :cstring, start: ^gtk.TextIter) {
  fmt.printf("SearchAndMark: text='%s' START=%v\n", text, start)
  fmt.printf("            : start offset=%d\n", gtk.text_iter_get_offset(start))
  end   := gtk.TextIter{}
  gtk.text_buffer_get_end_iter(V_textbuffer, &end)
  fmt.printf("             : end %v\n", end)
  miter := gtk.TextIter{}
//  flags :gtk.TextSearchFlags = gtk.TextSearchFlags(0)
  flags := gtk.TextSearchFlags.TEXT_SEARCH_CASE_INSENSITIVE
//  TextSearchFlags :: enum u32 {TEXT_SEARCH_VISIBLE_ONLY = 1, TEXT_SEARCH_TEXT_ONLY = 2, TEXT_SEARCH_CASE_INSENSITIVE = 4 }
  mstart := gtk.TextIter{}
  mend   := gtk.TextIter{}
  found := gtk.text_iter_forward_search(start, text, flags, &mstart, &mend, nil)
//text_iter_forward_search(iter: ^TextIter, str: cstring, flags: TextSearchFlags, match_start: ^TextIter, match_end: ^TextIter, limit: ^TextIter) -> glib.boolean

  fmt.printf("             : found=%v MSTART=%v MEND=%v\n", found, mstart, mend)
  if found {
    gtk.text_buffer_apply_tag(V_textbuffer, V_tag_found, &mstart, &mend)
//    SearchAndMark(text, &end)
  }
}

SearchClickedCB :: proc "c" (sender :^gtk.Widget, cbData :glib.pointer) {
  context = runtime.default_context()
  fmt.printf("SearchClickedCB: V_searchDialog=%p\n", V_searchDialog)
  if V_searchDialog == nil {
    parent := cast(^gtk.Window)cbData
    fmt.printf("SearchClickedCB: parent=%p\n", parent)
    searchDlg := gtk.window_new()
    gobj.signal_connect(searchDlg, "close-request",
                      cast(gobj.Callback)SearchClosedCB, searchDlg)
    V_searchDialog = cast(^gtk.Window)searchDlg
//    gobj.signal_connect(V_searchDialog, "delete-event",
//                      cast(gobj.Callback)SearchWindowDeleteCB, searchDlg)
    gtk.window_set_title(V_searchDialog, "Search")
    gtk.window_set_modal(V_searchDialog, true)
    gtk.window_set_transient_for(V_searchDialog, parent)

    box := gtk.box_new(gtk.Orientation.VERTICAL, spacing=12)
    gtk.window_set_child(V_searchDialog, box)

    label := gtk.label_new("Insert text you want to search for:")
    gtk.box_append(cast(^gtk.Box)box, label)

    V_searchEntry = gtk.entry_new()
    gtk.box_append(cast(^gtk.Box)box, V_searchEntry)

    button := gtk.button_new_with_label("Find")
    gtk.box_append(cast(^gtk.Box)box, button)

    gobj.signal_connect(button, "clicked",
                      cast(gobj.Callback)FindClickedCB, nil)
  }
  gtk.window_present(V_searchDialog)
}

SearchClosedCB :: proc "c" (sender :^gtk.Widget, cbData :glib.pointer)  -> glib.boolean {
  context = runtime.default_context()
  fmt.printf("SearchClosedCB: sdlg=%p\n", cbData)
  V_searchDialog = nil
  return false // allow close
}

// 1. Callback to hide the window instead of destroying it
SearchWindowDeleteCB  :: proc "c" (sender :^gtk.Widget, event :^gtk.Event,  data :glib.pointer) -> glib.boolean {
  context = runtime.default_context()
  fmt.printf("SearchWindowDeleteCB: data=%p\n", data)

    gtk.widget_hide(sender)
    return true // Returns TRUE to tell GTK the event is handled and not to destroy the window
}
/*
// 2. Connect the signal during initialization
g_signal_connect(G_OBJECT(window), "delete-event", G_CALLBACK(on_window_
*/




V_textview      :^gtk.Widget = nil
V_textbuffer    :^gtk.TextBuffer = nil
V_tag_bold      :^gtk.TextTag = nil
V_tag_italic    :^gtk.TextTag = nil
V_tag_underline :^gtk.TextTag = nil
V_tag_found     :^gtk.TextTag = nil
V_searchEntry   :^gtk.Widget  = nil
V_searchDialog  :^gtk.Window = nil


CreateTextView :: proc(app :^gtk.Application, vbox :^gtk.Box) {
  context = runtime.default_context()

//  fmt.printf("CreateTextView-1\n")
  scrolledwindow := gtk.scrolled_window_new()
  gtk.widget_set_hexpand(scrolledwindow, true)
  gtk.widget_set_vexpand(scrolledwindow, true)
  gtk.box_append(vbox, scrolledwindow)

//  fmt.printf("CreateTextView-2\n")
  V_textview = gtk.text_view_new()
  V_textbuffer = gtk.text_view_get_buffer(cast(^gtk.TextView)V_textview)
  ctext :cstring = `This is some text inside of a Gtk.TextView. 
Select text and click one of the buttons "bold", "italic", 
or "underline" to modify the text accordingly.`
  ctlen := len(string(ctext))
  gtk.text_buffer_set_text(V_textbuffer, ctext, i32(ctlen))
  gtk.scrolled_window_set_child(cast(^gtk.ScrolledWindow)scrolledwindow, V_textview)

  V_tag_bold = gtk.text_buffer_create_tag(V_textbuffer, "bold",
                                          "weight", pango.Weight.BOLD)
  V_tag_italic = gtk.text_buffer_create_tag(V_textbuffer, "italic",
                   "style", pango.Style.ITALIC)
  V_tag_underline = gtk.text_buffer_create_tag(V_textbuffer, "underline",
                        "underline", pango.Underline.SINGLE)
  V_tag_found = gtk.text_buffer_create_tag(V_textbuffer, "found",
                    "background", cstring("yellow"))
}


CreateToolBar :: proc(app :^gtk.Application, vbox :^gtk.Box, appwin: ^gtk.Window) { // , self):
  toolbar := gtk.box_new(gtk.Orientation.HORIZONTAL, spacing=6)
  gtk.widget_set_margin_top(toolbar, 6)
  gtk.widget_set_margin_start(toolbar, 6)
  gtk.widget_set_margin_end(toolbar,  6)
  gtk.box_prepend(vbox, toolbar)

  button_bold := gtk.button_new_with_label("B")
//  gtk.button_set_icon_name(cast(^gtk.Button)button_bold, "format-text-bold-symbolic")
  btnlbl := gtk.button_get_child(cast(^gtk.Button)button_bold) 
  gtk.label_set_markup(cast(^gtk.Label)btnlbl, "<b>B</b>")
  gobj.signal_connect(button_bold, "clicked",
                      cast(gobj.Callback)ButtonClickedCB, V_tag_bold)
  gtk.box_append(cast(^gtk.Box)toolbar, button_bold)

  button_italic := gtk.button_new_with_label("I")
  //_from_icon_name("format-text-italic-symbolic")
  btnlbl = gtk.button_get_child(cast(^gtk.Button)button_italic) 
  gtk.label_set_markup(cast(^gtk.Label)btnlbl, "<i>I</i>")
  gobj.signal_connect(button_italic, "clicked",
                      cast(gobj.Callback)ButtonClickedCB, V_tag_italic)
  gtk.box_append(cast(^gtk.Box)toolbar, button_italic)

  button_underline := gtk.button_new_with_label("U")
  //from_icon_name("format-text-underline-symbolic")
  btnlbl = gtk.button_get_child(cast(^gtk.Button)button_underline) 
  gtk.label_set_markup(cast(^gtk.Label)btnlbl, "<u>U</u>")
  gobj.signal_connect(button_underline, "clicked",
                      cast(gobj.Callback)ButtonClickedCB, V_tag_underline)
  gtk.box_append(cast(^gtk.Box)toolbar, button_underline)

  sep1 := gtk.separator_new(gtk.Orientation.HORIZONTAL)
  gtk.box_append(cast(^gtk.Box)toolbar, sep1)

  justifyleft := gtk.toggle_button_new_with_label("X")
  lbl := gtk.button_get_child(cast(^gtk.Button)justifyleft)
  gtk.label_set_markup(cast(^gtk.Label)lbl, "<b>&lt;</b>")
//  gtk.button_set_icon_name(cast(^gtk.Button)justifyleft,
//                           "format-justify-left-symbolic")
  gtk.box_append(cast(^gtk.Box)toolbar, justifyleft)

  justifycenter := gtk.toggle_button_new_with_label("X")
  lbl = gtk.button_get_child(cast(^gtk.Button)justifycenter)
  gtk.label_set_markup(cast(^gtk.Label)lbl, "<b>Jc</b>")
//  gtk.button_set_icon_name(cast(^gtk.Button)justifycenter,
//                           "format-justify-center-symbolic")
  gtk.toggle_button_set_group(cast(^gtk.ToggleButton)justifycenter,
                              cast(^gtk.ToggleButton)justifyleft)
  gtk.box_append(cast(^gtk.Box)toolbar, justifycenter)

  justifyright := gtk.toggle_button_new_with_label("X")
  lbl = gtk.button_get_child(cast(^gtk.Button)justifyright)
  gtk.label_set_markup(cast(^gtk.Label)lbl, "<b>Jr</b>")
//  gtk.button_set_icon_name(cast(^gtk.Button)justifyright,
//                           "format-justify-right-symbolic")
  gtk.toggle_button_set_group(cast(^gtk.ToggleButton)justifyright,
                              cast(^gtk.ToggleButton)justifyleft)
  gtk.box_append(cast(^gtk.Box)toolbar, justifyright)

  justifyfill := gtk.toggle_button_new_with_label("X")
  lbl = gtk.button_get_child(cast(^gtk.Button)justifyfill)
  gtk.label_set_markup(cast(^gtk.Label)lbl, "<b>Jf</b>")
//  gtk.button_set_icon_name(cast(^gtk.Button)justifyfill,
//                           "format-justify-fill-symbolic")
  gtk.toggle_button_set_group(cast(^gtk.ToggleButton)justifyfill,
                              cast(^gtk.ToggleButton)justifyleft)
  gtk.box_append(cast(^gtk.Box)toolbar, justifyfill)


  gobj.signal_connect(justifyleft, "toggled",
                      cast(gobj.Callback)JustifyToggledCB,
                      rawptr(uintptr(gtk.Justification.JUSTIFY_LEFT)))
  gobj.signal_connect(justifycenter, "toggled",
                      cast(gobj.Callback)JustifyToggledCB,
                      rawptr(uintptr(gtk.Justification.JUSTIFY_CENTER)))
  gobj.signal_connect(justifyright, "toggled",
                      cast(gobj.Callback)JustifyToggledCB,
                      rawptr(uintptr(gtk.Justification.JUSTIFY_RIGHT)))
  gobj.signal_connect(justifyfill, "toggled",
                      cast(gobj.Callback)JustifyToggledCB,
                      rawptr(uintptr(gtk.Justification.JUSTIFY_FILL)))

  sep2 := gtk.separator_new(gtk.Orientation.HORIZONTAL)
  gtk.box_append(cast(^gtk.Box)toolbar, sep2)

  button_clear := gtk.button_new_from_icon_name("edit-clear-symbolic")
  gobj.signal_connect(button_clear, "clicked",
                      cast(gobj.Callback)ClearClickedCB, nil)
  gtk.box_append(cast(^gtk.Box)toolbar, button_clear)

  sep3 := gtk.separator_new(gtk.Orientation.HORIZONTAL)
  gtk.box_append(cast(^gtk.Box)toolbar, sep3)

  button_search := gtk.button_new_from_icon_name("system-search-symbolic")
  gobj.signal_connect(button_search, "clicked",
                      cast(gobj.Callback)SearchClickedCB, appwin)
  gtk.box_append(cast(^gtk.Box)toolbar, button_search)
}


CreateButtons :: proc(app :^gtk.Application, vbox :^gtk.Box) {
  grid := gtk.grid_new()
  gtk.box_append(vbox, grid)

  check_editable := gtk.check_button_new_with_label("Editable")
  gtk.check_button_set_active(cast(^gtk.CheckButton)check_editable, true)
  gobj.object_bind_property(check_editable, "active", V_textview, "editable", gobj.BindingFlags.DEFAULT)
  gtk.grid_attach(cast(^gtk.Grid)grid, check_editable, 0, 0, 1, 1)

  check_cursor := gtk.check_button_new_with_label("Cursor Visible")
  gtk.check_button_set_active(cast(^gtk.CheckButton)check_cursor, true)
  gobj.object_bind_property(check_cursor, "active", V_textview, "cursor_visible", gobj.BindingFlags.DEFAULT) 
  gtk.grid_attach_next_to(cast(^gtk.Grid)grid, check_cursor, check_editable,
                          gtk.PositionType.POS_RIGHT, 1, 1)

  radio_wrapnone := gtk.check_button_new_with_label("No Wrapping")
  gtk.check_button_set_active(cast(^gtk.CheckButton)radio_wrapnone, true)
  gtk.grid_attach(cast(^gtk.Grid)grid, radio_wrapnone, 0, 1, 1, 1)

  radio_wrapchar := gtk.check_button_new_with_label("Character Wrapping")
  gtk.check_button_set_group(cast(^gtk.CheckButton)radio_wrapchar,
                              group=cast(^gtk.CheckButton)radio_wrapnone)
  gtk.grid_attach_next_to(cast(^gtk.Grid)grid, radio_wrapchar, radio_wrapnone,
                          gtk.PositionType.POS_RIGHT, 1, 1)

  radio_wrapword := gtk.check_button_new_with_label("Word Wrapping")
  gtk.check_button_set_group(cast(^gtk.CheckButton)radio_wrapword,
                              group=cast(^gtk.CheckButton)radio_wrapnone)
  gtk.grid_attach_next_to(cast(^gtk.Grid)grid, radio_wrapword, radio_wrapchar,
                          gtk.PositionType.POS_RIGHT, 1, 1)

  gobj.signal_connect(radio_wrapnone, "toggled",
                     cast(gobj.Callback)WrapToggledCB,
                     rawptr(uintptr(gtk.WrapMode.WRAP_NONE)))
  gobj.signal_connect(radio_wrapchar, "toggled",
                     cast(gobj.Callback)WrapToggledCB,
                     rawptr(uintptr(gtk.WrapMode.WRAP_CHAR)))
  gobj.signal_connect(radio_wrapword, "toggled",
                     cast(gobj.Callback)WrapToggledCB,
                     rawptr(uintptr(gtk.WrapMode.WRAP_WORD)))
}


AppActivateCB :: proc "c" (app :^gtk.Application, user_data :glib.pointer) {
  context = runtime.default_context()

  appwgt := gtk.application_window_new(app)
  appwin := cast(^gtk.Window)appwgt
  gtk.window_set_title(appwin, "TextView Demo")
  gtk.window_set_default_size(appwin, 500, 400)

  vbox := gtk.box_new(gtk.Orientation.VERTICAL, spacing=6)
  gtk.window_set_child(appwin, vbox)

  fmt.printf("AppActivateCB: appwin %p [%T]\n", appwin, appwin)

  CreateTextView(app, cast(^gtk.Box)vbox)
  CreateToolBar(app, cast(^gtk.Box)vbox, appwin)
  CreateButtons(app, cast(^gtk.Box)vbox)

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
