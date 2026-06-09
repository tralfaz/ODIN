package main

import "base:runtime"
import "core:fmt"
import "core:os"
import "core:strings"

import gio  "../gtk4m/gio"
import glib "../gtk4m/glib"
import gobj "../gtk4m/gobject"
import gtk  "../gtk4m/gtk"


AboutCB :: proc "c" (action :^gtk.ShortcutAction, cbArga :glib.pointer) {
  about_dialog := gtk.about_dialog_new()
  gtk.window_set_transient_for(V_appWindow, cast(^gtk.Window)about_dialog)
  gtk.window_set_modal(cast(^gtk.Window)about_dialog, true)
  gtk.window_present(cast(^gtk.Window)about_dialog)
}

QuitCB :: proc "c" (action :^gtk.ShortcutAction, cbArg :glib.pointer) {
  app := cast(^gio.Application)cbArg
  gio.application_quit(app)
}

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

// This would typically be its own file
MENU_XML :cstring = `
<?xml version='1.0' encoding='UTF-8'?>
<interface>
  <menu id='app-menu'>
    <section>
        <item>
            <attribute name='label'>About</attribute>
            <attribute name='action'>app.about</attribute>
        </item>
        <item>
            <attribute name='label'>Quit</attribute>
            <attribute name='action'>app.quit</attribute>
        </item>
    </section>
  </menu>
</interface>
`

AppStartupCB :: proc "c" (app :^gtk.Application, user_data :glib.pointer) {
  context = runtime.default_context()
  // Gtk.Application.do_startup(self)

//   action = Gio.SimpleAction(name="about")
//  action.connect("activate", self.on_about)
//  self.add_action(action)

//  action = Gio.SimpleAction(name="quit")
//  action.connect("activate", self.on_quit)
//  self.add_action(action)
fmt.printf("AppStartupCB:\n")
}

V_appWindow :^gtk.Window = nil

AppActivateCB :: proc "c" (app :^gtk.Application, user_data :glib.pointer) {
  context = runtime.default_context()

  appwgt := gtk.application_window_new(app)
  appwin := cast(^gtk.Window)appwgt
  gtk.window_set_title(appwin, "Menu Popover Demo")
  gtk.window_set_default_size(appwin, 300, 200)

//  hbox := gtk.box_new(gtk.Orientation.HORIZONTAL, spacing=6)
  //gtk.box_set_spacing(cast(^gtk.Box)hbox, 6)
  //box_set_homogeneous :: proc(box: ^Box, homogeneous: glib.boolean)
  //gtk.box_set_baseline_position(box: ^Box, position: BaselinePosition)
  //gtk.box_set_baseline_child(box: ^Box, child: i32)
//  gtk.window_set_child(appwin, hbox)

//  button1 := gtk.button_new_with_label("Hello")
//  gobj.signal_connect(button1, "clicked",
//                     cast(gobj.Callback)Button1ClickedCB, appwin)
//  gtk.box_append(cast(^gtk.Box)hbox, button1)
//  fmt.printf("AppActivateCB: appwin %p [%T]\n", appwin, appwin)

/////////
// We only allow a single window and raise any existing ones
// if V_appWindow == nil {
//    // Windows are associated with the application
//    // when the last one is closed the application shuts down
//       V_appWindow := AppWindow(application=self, title="Main Window")
//  }

  headerbar := gtk.header_bar_new()
  gtk.window_set_titlebar(appwin, headerbar)

  builder := gtk.builder_new_from_string(MENU_XML, -1)
  menu_model := gtk.builder_get_object(builder, "app-menu")

  button := gtk.menu_button_new()
  gtk.menu_button_set_menu_model(cast(^gtk.MenuButton)button,
                                 cast(^gio.MenuModel)menu_model)
  gtk.header_bar_pack_end(cast(^gtk.HeaderBar)headerbar, button)
/////////

  gtk.window_present(appwin)
}


//
// MAIN
//
main :: proc() {

  cbArg :cstring = "CB Arg"
  app := gtk.application_new("com.example.menupopover",
                             gio.ApplicationFlags.APPLICATION_DEFAULT_FLAGS)
  gobj.signal_connect(app, "startup",
                      cast(gobj.Callback)AppStartupCB,
                      cast(glib.pointer)&cbArg)
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


