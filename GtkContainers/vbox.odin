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
  vbox := cast(^gtk.Box)cbData
  fmt.printf("Button2ClickedCB: vbox %p [%T]\n", vbox, vbox)
}


AppActivateCB :: proc "c" (app :^gtk.Application, user_data :glib.pointer) {
  context = runtime.default_context()

  appwgt := gtk.application_window_new(app)
  appwin := cast(^gtk.Window)appwgt
  gtk.window_set_title(appwin, "Horizontal Box Example")
  gtk.window_set_default_size(appwin, 150, 500)

  vbox := gtk.box_new(gtk.Orientation.VERTICAL, spacing=6)
  //gtk.box_set_spacing(cast(^gtk.Box)hbox, 6)
  //box_set_homogeneous :: proc(box: ^Box, homogeneous: glib.boolean)
  //gtk.box_set_baseline_position(box: ^Box, position: BaselinePosition)
  //gtk.box_set_baseline_child(box: ^Box, child: i32)
  gtk.window_set_child(appwin, vbox)

  button1 := gtk.button_new_with_label("Hello")
  gobj.signal_connect(button1, "clicked",
                     cast(gobj.Callback)Button1ClickedCB, appwin)
  gtk.box_append(cast(^gtk.Box)vbox, button1)
  fmt.printf("AppActivateCB: appwin %p [%T]\n", appwin, appwin)

  button2 := gtk.button_new_with_label("Goodbye")
  gtk.widget_set_vexpand(button2, true)
  gobj.signal_connect(button2, "clicked",
                     cast(gobj.Callback)Button2ClickedCB, vbox)
  gtk.box_append(cast(^gtk.Box)vbox, button2)
  fmt.printf("AppActivateCB: vbox %p [%T]\n", vbox, vbox)

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
