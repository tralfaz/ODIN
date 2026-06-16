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

V_clipboard :^gtk.Clipboard = nil
V_entry     :^gtk.Widget = nil

AppActivateCB :: proc "c" (app :^gtk.Application, user_data :glib.pointer) {
  context = runtime.default_context()

  appwgt := gtk.application_window_new(app)
  appwin := cast(^gtk.Window)appwgt
  gtk.window_set_title(appwin, "Clipboard Example")
  gtk.window_set_default_size(appwin, 500, 150)

  vbox := gtk.box_new(gtk.Orientation.VERTICAL, spacing=12)
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
///////////////////
  dfltdsp := gtk.gdk_display_get_default()
  V_clipboard = gtk.gdk_display_get_clipboard(dfltdsp) -> ^Clipboard

  text_box := gtk.box_new(gtk.Orientation.HORIZONTAL, spacing=6)
  gtk.box_set_homogeneous(cast(^gtk.Box)text_box, true)
  gtk.box_append(cast(^gtk.Box)vbox, text_box)

  V_entry = gtk.entry_new()
    //text="Some text you can copy")
        button_copy_text = Gtk.Button(label="Copy Text")
        button_copy_text.connect("clicked", self.copy_text)
        button_paste_text = Gtk.Button(label="Paste Text")
        button_paste_text.connect("clicked", self.paste_text)

        text_box.append(self.entry)
        text_box.append(button_copy_text)
        text_box.append(button_paste_text)

        image_box = Gtk.Box(spacing=6)
        box.append(image_box)

        self.picture = Gtk.Picture.new_for_filename("../images/application.png")
        self.picture.props.hexpand = True
        button_copy_image = Gtk.Button(label="Copy Image", valign=Gtk.Align.CENTER)
        button_copy_image.connect("clicked", self.copy_image)
        button_paste_image = Gtk.Button(label="Paste Image", valign=Gtk.Align.CENTER)
        button_paste_image.connect("clicked", self.paste_image)

        image_box.append(self.picture)
        image_box.append(button_copy_image)
        image_box.append(button_paste_image)

    def copy_text(self, _button):
        self.clipboard.set(self.entry.get_text())

    def paste_text(self, _button):
        self.clipboard.read_text_async(None, self.on_paste_text)

    def on_paste_text(self, _clipboard, result):
        text = self.clipboard.read_text_finish(result)
        if text is not None:
            self.entry.set_text(text)

    def copy_image(self, _button):
        texture = self.picture.get_paintable()
        gbytes = texture.save_to_png_bytes()
        content = Gdk.ContentProvider.new_for_bytes("image/png", gbytes)
        self.clipboard.set_content(content)

    def paste_image(self, _button):
        self.clipboard.read_texture_async(None, self.on_paste_image)

    def on_paste_image(self, _clipboard, result):
        texture = self.clipboard.read_texture_finish(result)
        if texture is not None:
            self.picture.set_paintable(texture)

  gtk.window_present(appwin)
}


//
// MAIN
//
main :: proc() {

  cbArg :cstring = "CB Arg"
  app := gtk.application_new("com.example.FontDialog",
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

class ClipboardWindow(Gtk.ApplicationWindow):
    def __init__(self, *args, **kargs):



def on_activate(app):
    win = ClipboardWindow(application=app)
    win.present()

