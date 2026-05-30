package main

import "base:runtime"
import "core:fmt"
import "core:os"
import "core:strings"

import cairo "../gtk4m/cairo"
import gio   "../gtk4m/gio"
import glib  "../gtk4m/glib"
import gobj  "../gtk4m/gobject"
import gtk   "../gtk4m/gtk"


DrawButtonColor :: proc "c" (area :^gtk.DrawingArea,
                             cr   :^cairo.context_t,
                             width: glib.int_,
                             height: glib.int_,
                             cbData :glib.pointer) {
  rgba := cast(^gtk.RGBA)cbData
  cairo.set_source_rgba(cr, f64(rgba.red), f64(rgba.green), f64(rgba.blue),
                            f64(rgba.alpha))
  cairo.rectangle(cr, 0, 0, f64(width), f64(height))
  cairo.fill(cr)
}


NewColorSwatch :: proc(str_color :cstring) -> ^gtk.Widget {
  rgba := gtk.RGBA{}
  gtk.gdk_rgba_parse(&rgba, str_color)

  button := gtk.button_new()
  gtk.widget_set_tooltip_text(button, str_color)

  area := gtk.drawing_area_new()
  gtk.widget_set_size_request(area, 24, 24)
  gtk.drawing_area_set_draw_func(cast(^gtk.DrawingArea)area,
                                 DrawButtonColor, &rgba, nil)

  gtk.button_set_child(cast(^gtk.Button)button, area)

  return button
}


CreateFlowBox :: proc(flowbox :^gtk.FlowBox) {
    colors := [?]cstring {
            "AliceBlue",
            "AntiqueWhite",
            "AntiqueWhite1",
            "AntiqueWhite2",
            "AntiqueWhite3",
            "AntiqueWhite4",
            "aqua",
            "aquamarine",
            "aquamarine1",
            "aquamarine2",
            "aquamarine3",
            "aquamarine4",
            "azure",
            "azure1",
            "azure2",
            "azure3",
            "azure4",
            "beige",
            "bisque",
            "bisque1",
            "bisque2",
            "bisque3",
            "bisque4",
            "black",
            "BlanchedAlmond",
            "blue",
            "blue1",
            "blue2",
            "blue3",
            "blue4",
            "BlueViolet",
            "brown",
            "brown1",
            "brown2",
            "brown3",
            "brown4",
            "burlywood",
            "burlywood1",
            "burlywood2",
            "burlywood3",
            "burlywood4",
            "CadetBlue",
            "CadetBlue1",
            "CadetBlue2",
            "CadetBlue3",
            "CadetBlue4",
            "chartreuse",
            "chartreuse1",
            "chartreuse2",
            "chartreuse3",
            "chartreuse4",
            "chocolate",
            "chocolate1",
            "chocolate2",
            "chocolate3",
            "chocolate4",
            "coral",
            "coral1",
            "coral2",
            "coral3",
            "coral4",
    }

  for color in colors {
    button := NewColorSwatch(color)
    gtk.flow_box_append(flowbox, button)
  }
}
    
AppActivateCB :: proc "c" (app :^gtk.Application, user_data :glib.pointer) {
  context = runtime.default_context()

  appwgt := gtk.application_window_new(app)
  appwin := cast(^gtk.Window)appwgt
  gtk.window_set_title(appwin, "HeaderBar Example")
  gtk.window_set_default_size(appwin, 300, 250)

  header := gtk.header_bar_new()
  gtk.window_set_titlebar(appwin, header)

  scrolled := gtk.scrolled_window_new()
  gtk.scrolled_window_set_policy(cast(^gtk.ScrolledWindow)scrolled,
                                 gtk.PolicyType.POLICY_NEVER,
                                 gtk.PolicyType.POLICY_AUTOMATIC)
  gtk.window_set_child(appwin, scrolled)

    flowbox := gtk.flow_box_new()
  gtk.widget_set_valign(flowbox, align=gtk.Align.START)
  gtk.flow_box_set_min_children_per_line(cast(^gtk.FlowBox)flowbox, 30)
  gtk.flow_box_set_selection_mode(cast(^gtk.FlowBox)flowbox,
                                  mode=gtk.SelectionMode.SELECTION_NONE)
  gtk.scrolled_window_set_child(cast(^gtk.ScrolledWindow)scrolled, flowbox)

  CreateFlowBox(cast(^gtk.FlowBox)flowbox)

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
