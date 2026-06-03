package main

import "base:runtime"
import "core:fmt"
import "core:os"
import "core:strings"

import gio  "../gtk4m/gio"
import glib "../gtk4m/glib"
import gobj "../gtk4m/gobject"
import gtk  "../gtk4m/gtk"


StringSelectedCB :: proc "c" (dropdown :^gtk.DropDown,
                              pspec :^gobj.ParamSpec,
                              cbarg :glib.pointer) {
  context = runtime.default_context()

  // Selected Gtk.StringObject
  selected := gtk.drop_down_get_selected_item(dropdown)
//    if selected := dropdown.get_selected_item():
  fmt.printf("Selected: %v [%T]\n", selected, selected)//selected.get_string())
}

AppActivateCB :: proc "c" (app :^gtk.Application, user_data :glib.pointer) {
  context = runtime.default_context()

  appwgt := gtk.application_window_new(app)
  appwin := cast(^gtk.Window)appwgt
  gtk.window_set_title(appwin, "DropDown Menu Demo")
//  gtk.window_set_default_size(appwin, 500, 150)

//  hbox := gtk.box_new(gtk.Orientation.HORIZONTAL, spacing=6)

  items := [?]cstring{"This", "is", "a", "long", "list", "of"} // words to populate the dropdown".split()
  text := "This is a long list of words to populate the dropdown"
  words := strings.split(text, " ")
  menuItems := make([^]cstring, len(words)+1)
  for word, idx in words {
    menuItems[idx] = strings.clone_to_cstring(word)
  }
  menuItems[len(words)] = nil
//  defer delete(menuItems)
//  defer for item in menuItems do delete(item)
//for str in strings.split_iterator(&text, " ") {
//		fmt.println(str)
//  }
//for &arg, idx in argv {
//  }

  dropdown := gtk.drop_down_new_from_strings(menuItems)
  @static cbArg :cstring = "DropDown-1"
  gobj.signal_connect(dropdown, "notify::selected-item",
                      cast(gobj.Callback)StringSelectedCB,
                      rawptr(cbArg))
  gtk.window_set_child(appwin, dropdown)

  gtk.window_present(appwin)
}


//
// MAIN
//
main :: proc() {

  cbArg :cstring = "CB Arg"
  app := gtk.application_new("com.example.dropdown",
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
