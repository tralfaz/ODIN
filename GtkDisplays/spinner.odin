package main

import "base:runtime"
import "core:fmt"
import "core:os"
import "core:strings"

import gio  "../gtk4m/gio"
import glib "../gtk4m/glib"
import gobj "../gtk4m/gobject"
import gtk  "../gtk4m/gtk"


ButtonToggledCB :: proc "c" (button :^gtk.ToggleButton, cbData :glib.pointer) {
  spinner := cast(^gtk.Spinner)cbData
if gtk.toggle_button_get_active(button) {
    gtk.spinner_start(spinner)
    gtk.button_set_label(cast(^gtk.Button)button, "Stop Spinning")
  } else {
    gtk.spinner_stop(spinner)
    gtk.button_set_label(cast(^gtk.Button)button, "Start Spinning")
  }
}

AppActivateCB :: proc "c" (app :^gtk.Application, user_data :glib.pointer) {
  context = runtime.default_context()

  appwgt := gtk.application_window_new(app)
  appwin := cast(^gtk.Window)appwgt
  gtk.window_set_title(appwin, "Spinner Example")
  gtk.window_set_default_size(appwin, 500, 150)

  spinner := gtk.spinner_new()

  button := gtk.toggle_button_new_with_label("Start Spinning")
  gtk.toggle_button_set_active(cast(^gtk.ToggleButton)button, false)
  gobj.signal_connect(button, "toggled",
                      cast(gobj.Callback)ButtonToggledCB, spinner)

  vbox := gtk.box_new(gtk.Orientation.VERTICAL, spacing=6)
  gtk.box_set_homogeneous(cast(^gtk.Box)vbox, true)
  gtk.box_append(cast(^gtk.Box)vbox, button)
  gtk.box_append(cast(^gtk.Box)vbox, spinner)
  gtk.window_set_child(appwin, vbox)

  gtk.window_present(appwin)
}


//
// MAIN
//
main :: proc() {

  cbArg :cstring = "CB Arg"
  app := gtk.application_new("com.example.spinner",
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
