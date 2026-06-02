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
SwitchActivatedCB :: proc "c" (self, switch, _gparam) {
  context = runtime.default_context()
        state = "on" if switch.props.active else "off"
  fmt.printf("Switch was turned %v\n", state)
}

AppActivateCB :: proc "c" (app :^gtk.Application, user_data :glib.pointer) {
  context = runtime.default_context()

  appwgt := gtk.application_window_new(app)
  appwin := cast(^gtk.Window)appwgt
  gtk.window_set_title(appwin, "Horizontal Box Example")
//  gtk.window_set_default_size(appwin, 500, 150)

  hbox := gtk.box_new(gtk.Orientation.HORIZONTAL, spacing=6)
  //homogeneous=True, margin_top=24, margin_bottom=24)
  gtk.window_set_child(appwin, hbox)

  switch := gtk.Switch(active=False, halign=Gtk.Align.CENTER)
  gobj.signal_connect(switch, "notify::active",
                      cast(gobj.Callback)SwitchActivatedCB, appwin)
  gtk.box_append(cast(^gtk.Box)hbox, switch)

  switch = Gtk.Switch(active=True, halign=Gtk.Align.CENTER)
  gobj.signal_connect(switch, "notify::active",
                      cast(gobj.Callback)SwitchActivatedCB, appwin)
  gtk.box_append(cast(^gtk.Box)hbox, switch)

  gtk.window_present(appwin)
}


//
// MAIN
//
main :: proc() {

  cbArg :cstring = "CB Arg"
  app := gtk.application_new("com.example.switch-demo",
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


