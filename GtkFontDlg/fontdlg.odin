package main

import "base:runtime"
import "core:fmt"
import "core:os"
import "core:strings"

import glib  "../gtk4m/glib"
import gio   "../gtk4m/gio"
import gobj  "../gtk4m/gobject"
import gtk   "../gtk4m/gtk"
import pango "../gtk4m/pango"



// Callback triggered when the font dialog finishes
on_font_dialog_done :: proc "c" (source_object :^gobj.Object,
                                 res :^gio.AsyncResult,
                                 user_data :glib.pointer) {
    dialog := cast(^gtk.FontDialog)source_object
    button := cast(^gtk.Button)user_data
    error :^glib.Error = nil
    
    // Retrieve the selected PangoFontDescription
    /*PangoFontDescription * */
    font_desc := gtk.font_dialog_choose_font_finish(dialog, res, &error)

    if font_desc != nil {
        // Convert font description to string for display/usage
        font_str := pango.font_description_to_string(font_desc)
        
        glib.print("Selected font: %s\n", font_str)
        gtk.button_set_label(button, font_str)

        // Clean up
        pango.font_description_free(font_desc)

    } else {
//        if (glib.error_matches(error, gio.IOErrorEnum, gio.IOErrorEnum.CANCELLED)) {
        if error.code == i32(gio.IOErrorEnum.CANCELLED) {
            glib.print("Dialog cancelled by user.\n")
        } else {
            //glib.warning("Error choosing font: %s\n", error.message);
            glib.print("Error choosing font: %s\n", error.message)
        }
        glib.error_free(error)
    }
}


// Callback triggered when the button is clicked
ButtonClickedCB :: proc "c" (button :^gtk.Button, user_data :glib.pointer) {
    parent_window := cast(^gtk.Window)user_data
    dialog := gtk.font_dialog_new()
    gtk.font_dialog_set_title(dialog, "Select a Font")

    // Open the dialog asynchronously
    gtk.font_dialog_choose_font(dialog, parent_window,
                                nil, nil,
                                cast(gio.AsyncReadyCallback)on_font_dialog_done, button)
    gobj.object_unref(dialog)
}

AppActivateCB :: proc "c" (app :^gtk.Application, user_data :glib.pointer) {
  context = runtime.default_context()
    appwgt := gtk.application_window_new(app)
    appwin := cast(^gtk.Window)appwgt
    gtk.window_set_title(appwin, "GtkFontDialog Example")
    gtk.window_set_default_size(appwin, 300, 150)

    button := gtk.button_new_with_label("Choose Font")
//  fontdesc := "Futura weight=810 Condensed 50"
  fontdesc := "Futura Bold 14"
  markup := fmt.aprintf("<span font_desc='%s'>%s</span>", fontdesc, "Choose Font")
  fmt.printf("markup: %s\n", markup)
  btnlbl := gtk.button_get_label(cast(^gtk.Button)button)
  fmt.printf("btnlbl: %v [%T]\n", btnlbl, btnlbl)
  btnkid := gtk.button_get_child(cast(^gtk.Button)button)
  fmt.printf("btnkid: %v [%T]\n", btnkid, btnkid)
  gtk.label_set_use_markup(cast(^gtk.Label)btnkid, true)
  cmarkup := strings.clone_to_cstring(markup)
  defer delete(cmarkup)
  gtk.button_set_label(cast(^gtk.Button)button, cmarkup)

    gtk.window_set_child(appwin, button)

    gobj.signal_connect(button, "clicked",
                       cast(gobj.Callback)ButtonClickedCB, appwin)
    gtk.window_present(appwin)
}


//
// MAIN
//
main :: proc() {
  app := gtk.application_new("com.example.FontDialog",
                             gio.ApplicationFlags.APPLICATION_DEFAULT_FLAGS)
  actcbData :cstring = "app"
  gobj.signal_connect(app, "activate",
                      cast(gobj.Callback)AppActivateCB, glib.pointer(actcbData))

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
