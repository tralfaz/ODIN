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


AppActivateCB :: proc "c" (app :^gtk.Application, user_data :glib.pointer) {
  context = runtime.default_context()

  appwgt := gtk.application_window_new(app)
  appwin := cast(^gtk.Window)appwgt
  gtk.window_set_title(appwin, "Stack Example")
  gtk.window_set_default_size(appwin, 300, 250)

  header := gtk.header_bar_new()
  gtk.window_set_titlebar(appwin, header)

  stack := gtk.stack_new()
  gtk.stack_set_transition_type(cast(^gtk.Stack)stack,
                                gtk.StackTransitionType.SLIDE_LEFT_RIGHT)
  gtk.stack_set_transition_duration(cast(^gtk.Stack)stack, 1000)
  gtk.window_set_child(appwin, stack)

  checkbutton := gtk.check_button_new_with_label("Click me!")
  gtk.widget_set_hexpand(checkbutton, true)
  gtk.widget_set_halign(checkbutton, gtk.Align.CENTER)

  page1 := gtk.stack_add_titled(cast(^gtk.Stack)stack, checkbutton,
                               "check", "Check Button")
//^StackPage

//  checkbutton.bind_property(
//            "active", page1, "needs-attention", GObject.BindingFlags.DEFAULT)
  gobj.object_bind_property(source=checkbutton, source_property="active",
                            target=page1, target_property="needs-attention",
                            flags=gobj.BindingFlags.DEFAULT)
  label := gtk.label_new("")
  gtk.label_set_markup(cast(^gtk.Label)label,"<big>A fancy label</big>")
// label_set_use_markup :: proc(self: ^Label, setting: glib.boolean) ---
  gtk.stack_add_titled(cast(^gtk.Stack)stack, label, "label", "A label")

  stack_switcher := gtk.stack_switcher_new()
  gtk.stack_switcher_set_stack(cast(^gtk.StackSwitcher)stack_switcher,
                               cast(^gtk.Stack)stack)
  gtk.header_bar_set_title_widget(cast(^gtk.HeaderBar)header, stack_switcher)

  // Let's start in the second page
  gtk.stack_set_visible_child_name(cast(^gtk.Stack)stack, "label")

  fmt.printf("AppActivateCB: \n")

  gtk.window_present(appwin)
}


//
// MAIN
//
main :: proc() {

  cbArg :cstring = "CB Arg"
  app := gtk.application_new("com.example.stack",
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
