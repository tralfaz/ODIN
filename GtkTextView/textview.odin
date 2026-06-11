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
 text_buffer_create_tag :: proc(buffer: ^TextBuffer, tag_name: cstring, first_property_name: cstring, #c_vararg var_args: ..any) -> ^TextTag
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
                      cast(gobj.Callback)Button1ClickedCB, V_tag_bold)
  gtk.box_append(toolbar, button_bold)

  button_italic := gtk.button_new_from_icon_name("format-text-italic-symbolic")
  gobj.signal_connect(button_italic, "clicked",
                      cast(gobj.Callback)Button1ClickedCB, V_tag_italic)
  gtk.box_append(toolbar, button_italic)

  button_underline := gtk.button_new_from_icon_name("format-text-underline-symbolic")
  gobj.signal_connect(button_underline, "clicked",
                      cast(gobj.Callback)Button1ClickedCB, V_tag_underline)
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
        button_search.connect("clicked", self.on_search_clicked)
  gtk.box_append(toolbar, button_search)
}


CreateButtons :: proc(app :^gtk.Application, vbox :^gtk.Box) {
  grid := gtk.grid_new()
  gtk.box_append(vbox, grid)

        check_editable = Gtk.CheckButton(label="Editable", active=True)
        check_editable.bind_property("active", self.textview, "editable", 0)
        grid.attach(check_editable, 0, 0, 1, 1)

        check_cursor = Gtk.CheckButton(label="Cursor Visible", active=True)
        check_cursor.bind_property("active", self.textview, "cursor_visible", 0)
        grid.attach_next_to(check_cursor, check_editable, Gtk.PositionType.RIGHT, 1, 1)

        radio_wrapnone = Gtk.CheckButton(label="No Wrapping", active=True)
        grid.attach(radio_wrapnone, 0, 1, 1, 1)

        radio_wrapchar = Gtk.CheckButton(
            label="Character Wrapping", group=radio_wrapnone
        )
        grid.attach_next_to(
            radio_wrapchar, radio_wrapnone, Gtk.PositionType.RIGHT, 1, 1
        )

        radio_wrapword = Gtk.CheckButton(label="Word Wrapping", group=radio_wrapnone)
        grid.attach_next_to(
            radio_wrapword, radio_wrapchar, Gtk.PositionType.RIGHT, 1, 1
        )

        radio_wrapnone.connect("toggled", self.on_wrap_toggled, Gtk.WrapMode.NONE)
        radio_wrapchar.connect("toggled", self.on_wrap_toggled, Gtk.WrapMode.CHAR)
        radio_wrapword.connect("toggled", self.on_wrap_toggled, Gtk.WrapMode.WORD)
        }


AppActivateCB :: proc "c" (app :^gtk.Application, user_data :glib.pointer) {
  context = runtime.default_context()

  appwgt := gtk.application_window_new(app)
  appwin := cast(^gtk.Window)appwgt
  gtk.window_set_title(appwin, "TextView Demo")
  gtk.window_set_default_size(appwin, 500, 400)

  vbox := gtk.box_new(gtk.Orientation.VERTICAL, spacing=6)
  //gtk.box_set_spacing(cast(^gtk.Box)hbox, 6)
  //box_set_homogeneous :: proc(box: ^Box, homogeneous: glib.boolean)
  //gtk.box_set_baseline_position(box: ^Box, position: BaselinePosition)
  //gtk.box_set_baseline_child(box: ^Box, child: i32)
  gtk.window_set_child(appwin, vbox)

  button1 := gtk.button_new_with_label("Hello")
  gobj.signal_connect(button1, "clicked",
                     cast(gobj.Callback)Button1ClickedCB, appwin)
  gtk.box_append(cast(^gtk.Box)hbox, button1)
  fmt.printf("AppActivateCB: appwin %p [%T]\n", appwin, appwin)

  CreateTextView(app, vbox)
  CreateToolBar(app, vbox)
  self.create_buttons()

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

class SearchDialog(Gtk.Window):
    def __init__(self, parent):
        super().__init__(title="Search", modal=True, transient_for=parent)

        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=12)
        self.set_child(box)

        label = Gtk.Label(label="Insert text you want to search for:")
        box.append(label)

        self.entry = Gtk.Entry()
        box.append(self.entry)

        self.button = Gtk.Button(label="Find")
        box.append(self.button)


class TextViewWindow(Gtk.ApplicationWindow):

    def on_button_clicked(self, _widget, tag):
        bounds = self.textbuffer.get_selection_bounds()
        if len(bounds) != 0:
            start, end = bounds
            self.textbuffer.apply_tag(tag, start, end)

    def on_clear_clicked(self, _widget):
        start = self.textbuffer.get_start_iter()
        end = self.textbuffer.get_end_iter()
        self.textbuffer.remove_all_tags(start, end)

    def on_wrap_toggled(self, _widget, mode):
        self.textview.props.wrap_mode = mode

    def on_justify_toggled(self, _widget, justification):
        self.textview.props.justification = justification

    def on_search_clicked(self, _widget):
        self.search_dialog = SearchDialog(self)
        self.search_dialog.button.connect("clicked", self.on_find_clicked)
        self.search_dialog.present()

    def on_find_clicked(self, _button):
        cursor_mark = self.textbuffer.get_insert()
        start = self.textbuffer.get_iter_at_mark(cursor_mark)
        if start.get_offset() == self.textbuffer.get_char_count():
            start = self.textbuffer.get_start_iter()

        self.search_and_mark(self.search_dialog.entry.get_text(), start)

    def search_and_mark(self, text, start):
        end = self.textbuffer.get_end_iter()
        match = start.forward_search(text, 0, end)

        if match is not None:
            match_start, match_end = match
            self.textbuffer.apply_tag(self.tag_found, match_start, match_end)
            self.search_and_mark(text, match_end)


def on_activate(app):
    win = TextViewWindow(application=app)
    win.present()


app = Gtk.Application(application_id="com.example.App")
app.connect("activate", on_activate)

app.run(None)