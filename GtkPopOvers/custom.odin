package main

import "base:runtime"
import "core:fmt"
import "core:os"
import "core:strings"

import gio  "../gtk4m/gio"
import glib "../gtk4m/glib"
import gobj "../gtk4m/gobject"
import gtk  "../gtk4m/gtk"


ButtonClickedCB :: proc "c" (button :^gtk.Button, cbData :glib.pointer) {
  context = runtime.default_context()
  gtk.popover_popup(cast(^gtk.Popover)V_popover2)
  fmt.printf("ButtonClickedCB: \n")
}


V_popover2 :^gtk.Widget = nil

AppActivateCB :: proc "c" (app :^gtk.Application, user_data :glib.pointer) {
  context = runtime.default_context()

  appwgt := gtk.application_window_new(app)
  appwin := cast(^gtk.Window)appwgt
  gtk.window_set_title(appwin, "Custom Popover Demo")
  gtk.window_set_default_size(appwin, 300, 200)

  vbox := gtk.box_new(gtk.Orientation.VERTICAL, spacing=6)
  gtk.widget_set_halign(vbox, gtk.Align.CENTER)
  gtk.widget_set_valign(vbox, gtk.Align.CENTER)
  gtk.window_set_child(appwin, vbox)

  popover := gtk.popover_new()
  gtk.popover_set_child(cast(^gtk.Popover)popover, gtk.label_new("Item"))
  button := gtk.menu_button_new()
  gtk.menu_button_set_label(cast(^gtk.MenuButton)button, "Click Me")
  gtk.menu_button_set_popover(cast(^gtk.MenuButton)button, popover)
  gtk.box_append(cast(^gtk.Box)vbox, button)

  button2 := gtk.button_new_with_label("Click Me 2")
  gobj.signal_connect(button2, "clicked",
                      cast(gobj.Callback)ButtonClickedCB, nil)
  gtk.box_append(cast(^gtk.Box)vbox, button2)

  V_popover2 = gtk.popover_new()
  gtk.popover_set_child(cast(^gtk.Popover)V_popover2,
                        gtk.label_new("Another Popup!"))
  gtk.popover_set_position(cast(^gtk.Popover)V_popover2,
                           gtk.PositionType.POS_LEFT)
  gtk.widget_set_parent(V_popover2, button2)

  gtk.window_present(appwin)
}


//
// MAIN
//
main :: proc() {

  cbArg :cstring = "CB Arg"
  app := gtk.application_new("com.example.custom-pop",
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
