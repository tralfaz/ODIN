package main

import "base:runtime"
import "core:fmt"
import "core:os"
import "core:strings"

import gio  "../gtk4m/gio"
import glib "../gtk4m/glib"
import gobj "../gtk4m/gobject"
import gtk  "../gtk4m/gtk"


QuitActivatedCB :: proc "c" (action :^gio.SimpleAction,
                             parameter :^glib.Variant,
                             application :^gio.Application) {
  gio.application_quit(application)
}

AppActivateCB :: proc "c" (app :^gtk.Application, cbArg :glib.pointer) {
  context = runtime.default_context()
  fmt.printf("AppActivateCB: cbArg='%s'\n", cast(cstring)cbArg)

  appwgt := gtk.application_window_new(app)
  appwin := cast(^gtk.Window)appwgt
  gtk.window_set_title(appwin, "menu1")
  gtk.window_set_default_size(appwin, 800, 600)
  gtk.application_window_set_show_menubar(cast(^gtk.ApplicationWindow)appwin, true)
  gtk.window_present(appwin)
}


AppStartupCB  :: proc "c" (app :^gtk.Application, cbArg :glib.pointer) {
  context = runtime.default_context()
  fmt.printf("AppStartupCB: cbArg='%s'\n", cast(cstring)cbArg)

  act_quit := gio.simple_action_new("quit", nil)
  gobj.signal_connect(act_quit, "activate",
                      cast(gobj.Callback)QuitActivatedCB,
                      cast(glib.pointer)app)
  gio.action_map_add_action(cast(^gio.ActionMap)app, cast(^gio.Action)act_quit)
  gobj.object_unref(act_quit)

  menubar := gio.menu_new()
  menu_item_menu := gio.menu_item_new("Menu", nil)
  menu := gio.menu_new()
  menu_item_quit := gio.menu_item_new("Quit", cstring("app.quit"))
  gio.menu_append_item(menu, menu_item_quit)
  gobj.object_unref(menu_item_quit)
  gio.menu_item_set_submenu(menu_item_menu, cast(^gio.MenuModel)menu)
  gobj.object_unref(menu)
  gio.menu_append_item(menubar, menu_item_menu)
  gobj.object_unref(menu_item_menu)

  gtk.application_set_menubar(app, cast(^gio.MenuModel)menubar)
  gobj.object_unref(menubar)
}


//
// MAIN
//
main :: proc () {
  app := gtk.application_new("com.github.ToshioCP.menu1",
                             gio.ApplicationFlags.APPLICATION_DEFAULT_FLAGS)
  @static startupArg :cstring = "Startup Arg"
  gobj.signal_connect(app, "startup",
                      cast(gobj.Callback)AppStartupCB,
                      cast(glib.pointer)startupArg)
  @static activateArg :cstring = "Activate Arg"
  gobj.signal_connect(app, "activate",
                      cast(gobj.Callback)AppActivateCB,
                      cast(glib.pointer)activateArg)


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
