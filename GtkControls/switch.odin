package main

import "base:runtime"
import "core:fmt"
import "core:os"
import "core:strings"

import gio  "../gtk4m/gio"
import glib "../gtk4m/glib"
import gobj "../gtk4m/gobject"
import gtk  "../gtk4m/gtk"


SwitchActivatedCB :: proc "c" (sender :^gtk.Switch,
                               pspec :^gobj.ParamSpec,
                               cbarg :glib.pointer) {
  context = runtime.default_context()
  swid := cast(cstring)cbarg
  state := "on" if gtk.switch_get_active(sender) else "off"
  fmt.printf("Switch[%s] was turned %s\n", swid, state)
  fmt.printf("param spec %v\n", pspec)
}

AppActivateCB :: proc "c" (app :^gtk.Application, user_data :glib.pointer) {
  context = runtime.default_context()

  appwgt := gtk.application_window_new(app)
  appwin := cast(^gtk.Window)appwgt
  gtk.window_set_title(appwin, "Switch button demo")
//  gtk.window_set_default_size(appwin, 500, 150)

  hbox := gtk.box_new(gtk.Orientation.HORIZONTAL, spacing=6)
  gtk.box_set_homogeneous(cast(^gtk.Box)hbox, true)
  gtk.widget_set_margin_top(hbox, 24)
  gtk.widget_set_margin_bottom(hbox, 24)  
  gtk.window_set_child(appwin, hbox)

  swbtn := gtk.switch_new()
  gtk.switch_set_active(cast(^gtk.Switch)swbtn, false)
  gtk.widget_set_halign(swbtn, gtk.Align.CENTER)
  @static cbarg1 :cstring = "SW1"
  gobj.signal_connect(swbtn, "notify::active",
                      cast(gobj.Callback)SwitchActivatedCB, rawptr(cbarg1))
  gtk.box_append(cast(^gtk.Box)hbox, swbtn)

  swbtn = gtk.switch_new()
  gtk.switch_set_active(cast(^gtk.Switch)swbtn, true)
  gtk.widget_set_halign(swbtn, gtk.Align.CENTER)
  @static cbarg2 :cstring = "SW2"
  gobj.signal_connect(swbtn, "notify::active",
                      cast(gobj.Callback)SwitchActivatedCB, rawptr(cbarg2))
  gtk.box_append(cast(^gtk.Box)hbox, swbtn)

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


