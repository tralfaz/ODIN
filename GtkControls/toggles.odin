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
  context = runtime.default_context()
  cbstr := cast(cstring)cbData
  state := gtk.toggle_button_get_active(button)  
  sstate :cstring = "on"
  if !state {
    sstate = "off"
  }
  fmt.printf("Button[%s] was %s\n", cbstr, sstate)
}

AppActivateCB :: proc "c" (app :^gtk.Application, user_data :glib.pointer) {
  context = runtime.default_context()

  appwgt := gtk.application_window_new(app)
  appwin := cast(^gtk.Window)appwgt
  gtk.window_set_title(appwin, "ToggleButton Demo")
  gtk.window_set_default_size(appwin, 500, 150)

  hbox := gtk.box_new(gtk.Orientation.HORIZONTAL, spacing=6)
  gtk.window_set_child(appwin, hbox)

  button := gtk.toggle_button_new_with_label("Button 1")
  btn1Arg :cstring = "BTN-1"
  gobj.signal_connect(button, "toggled",
                      cast(gobj.Callback)ButtonToggledCB, rawptr(btn1Arg))
  gtk.box_append(cast(^gtk.Box)hbox, button)

  button = gtk.toggle_button_new_with_label("B_utton 2")
  gobj.set_boolean_property(cast(^gobj.Object)button, "use-underline", true)
  gtk.toggle_button_set_active(cast(^gtk.ToggleButton)button, true)
  btn2Arg :cstring = "BTN-2"
  gobj.signal_connect(button, "toggled",
                      cast(gobj.Callback)ButtonToggledCB, rawptr(btn2Arg))
  gtk.box_append(cast(^gtk.Box)hbox, button)

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
