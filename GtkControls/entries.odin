package main

import "base:runtime"
import "core:fmt"
import "core:os"
import "core:strings"

import gio  "../gtk4m/gio"
import glib "../gtk4m/glib"
import gobj "../gtk4m/gobject"
import gtk  "../gtk4m/gtk"


EditableToggledCB :: proc "c" (sender :^gtk.Widget, cbData :glib.pointer) {
  context = runtime.default_context()
  appwin := cast(^gtk.Window)cbData
  fmt.printf("EditableToggledCB: appwin %p [%T]\n", appwin, appwin)

  button := cast(^gtk.CheckButton)sender
  value := gtk.check_button_get_active(button)
  gtk.editable_set_editable(cast(^gtk.Editable)V_entry, value)
  fmt.printf("                 : value %v \n", value)
  fmt.printf("                 : entry %v\n", V_entry)
}

EntryChangedCB :: proc "c" (sender :^gtk.Widget, cbData :glib.pointer) {
  context = runtime.default_context()
  appwin := cast(^gtk.Window)cbData
  fmt.printf("EntryChangedCB: appwin %p [%T]\n", appwin, appwin)

  entry := cast(^gtk.Entry)sender
  fmt.printf("              : sender %p V_entry %p\n", sender, V_entry)
  entbuf := cast(^gtk.TextBuffer)gtk.entry_get_buffer(entry)
//  txtitr := gtk,TextIter{}
  enttxt := gtk.editable_get_text(cast(^gtk.Editable)entry)
  fmt.printf("              : text '%s'\n", enttxt)
}

VisibleToggledCB ::  proc "c" (sender :^gtk.Widget, cbData :glib.pointer) {
  button := cast(^gtk.CheckButton)sender
  value := gtk.check_button_get_active(button)
//  self.entry.props.visibility = button.props.active
  gtk.widget_set_visible(cast(^gtk.Widget)V_entry, value)
}

PulseToggledCB ::  proc "c" (sender :^gtk.Widget, cbData :glib.pointer) {
  button := cast(^gtk.CheckButton)sender
  isActive := gtk.check_button_get_active(button)
  if isActive {
    // Call self.do_pulse every 100 ms
      V_timeout_id = glib.timeout_add(100, DoPulseCB, nil)
  } else {
    // Don't call self.do_pulse anymore
    glib.source_remove(V_timeout_id)
    V_timeout_id = 0
  }
}

DoPulseCB :: proc "c" (user_data :glib.pointer) -> glib.boolean {
  gtk.entry_progress_pulse(cast(^gtk.Entry)V_entry)
  return true
}

IconToggledCB ::  proc "c" (sender :^gtk.Widget, cbData :glib.pointer) {
  button := cast(^gtk.CheckButton)sender
  isActive := gtk.check_button_get_active(button)
  iconName :cstring = ""
  if isActive {
    iconName = "system-search-symbolic"
  }
  gtk.entry_set_icon_from_icon_name(cast(^gtk.Entry)V_entry,
                                    gtk.EntryIconPosition.ENTRY_ICON_PRIMARY,
                                    iconName)
}


V_entry :^gtk.Entry = nil
V_entryBuf :^gtk.EntryBuffer = nil
V_timeout_id :glib.uint_ = 0

AppActivateCB :: proc "c" (app :^gtk.Application, user_data :glib.pointer) {
  context = runtime.default_context()

  appwgt := gtk.application_window_new(app)
  appwin := cast(^gtk.Window)appwgt
  gtk.window_set_title(appwin, "Entries Example")
  gtk.window_set_default_size(appwin, 200, 150)

  header := gtk.header_bar_new()
  gtk.window_set_titlebar(appwin, header)

  vbox := gtk.box_new(gtk.Orientation.VERTICAL, spacing=6)
  gtk.widget_set_margin_start(vbox, 24)
  gtk.widget_set_margin_end(vbox, 24)
  gtk.widget_set_margin_top(vbox, 24)
  gtk.widget_set_margin_bottom(vbox, 24)
  gtk.window_set_child(appwin, vbox)

  // Gtk.SearchEntry
  search := gtk.search_entry_new()
  gtk.search_entry_set_key_capture_widget(cast(^gtk.SearchEntry)search, appwgt)
  gtk.search_entry_set_placeholder_text(cast(^gtk.SearchEntry)search,
                                             "Search Entry")
  gtk.header_bar_set_title_widget(cast(^gtk.HeaderBar)header, search)
  gtk.window_set_focus(appwin, search)

  // Gtk.Entry
  V_entry = cast(^gtk.Entry)gtk.entry_new()
  V_entryBuf = gtk.entry_buffer_new("Hello World", 11)
  gtk.entry_set_buffer(V_entry, V_entryBuf)
  gtk.entry_set_progress_pulse_step(V_entry, f64(0.2))
  gtk.box_append(cast(^gtk.Box)vbox, cast(^gtk.Widget)V_entry)
  gobj.signal_connect(V_entry, "changed",
                     cast(gobj.Callback)EntryChangedCB, appwin)

  hbox := gtk.box_new(gtk.Orientation.HORIZONTAL, spacing=6)
  gtk.box_append(cast(^gtk.Box)vbox, hbox)

  check_editable := gtk.check_button_new_with_label("Editable")
  gtk.check_button_set_active(cast(^gtk.CheckButton)check_editable, true)
  gtk.editable_set_editable(cast(^gtk.Editable)V_entry, true)
  gobj.signal_connect(check_editable, "toggled",
                     cast(gobj.Callback)EditableToggledCB, appwin)
  gtk.box_append(cast(^gtk.Box)hbox, check_editable)

  check_visible := gtk.check_button_new_with_label("Visible")
  gtk.check_button_set_active(cast(^gtk.CheckButton)check_visible, true)
  gobj.signal_connect(check_visible, "toggled",
                     cast(gobj.Callback)VisibleToggledCB, appwin)
  gtk.box_append(cast(^gtk.Box)hbox, check_visible)

  pulse := gtk.check_button_new_with_label("Pulse")
  gobj.signal_connect(pulse, "toggled",
                     cast(gobj.Callback)PulseToggledCB, appwin)
  gtk.box_append(cast(^gtk.Box)hbox, pulse)

  icon := gtk.check_button_new_with_label("Icon")
  gobj.signal_connect(icon, "toggled",
                     cast(gobj.Callback)IconToggledCB, appwin)
  gtk.box_append(cast(^gtk.Box)hbox, icon)

/*
    // Gtk.PasswordEntry
        pass_entry = Gtk.PasswordEntry(
            placeholder_text="Password Entry",
            show_peek_icon=True,
            margin_top=24,
        )
        vbox.append(pass_entry)
*/

  fmt.printf("AppActivateCB: appwin %p [%T]\n", appwin, appwin)
  gtk.window_present(appwin)
}


//
// MAIN
//
main :: proc() {

  cbArg :cstring = "CB Arg"
  app := gtk.application_new("com.example.entries",
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
