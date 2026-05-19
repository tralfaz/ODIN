package main

import "core:os"

import glib    "../../glib"
import gmodule "../../gmodule"

main :: proc() {
    module: ^gmodule.Module
    g_print_proc: #type proc "c" (format: cstring, #c_vararg var_args: ..any)

when (ODIN_OS == .Linux) {
    PLUGIN_PATH :: "/usr/lib/libglib-2.0.so"
}
when (ODIN_OS == .Darwin) {
    PLUGIN_PATH :: "/opt/homebrew/lib/libglib-2.0.dylib"
}

    // Initialize the GModule system
    if !gmodule.supported() {
        glib.printerr(
            "Dynamic module loading is not supported on this platform.\n",
        )
        os.exit(1)
    }

    // Load the shared library
    module = gmodule.open(PLUGIN_PATH, .BIND_LAZY)
    if module == nil {
        glib.printerr("Failed to load module: %s\n", gmodule.error())
        os.exit(1)
    }
    defer gmodule.close(module)

    // Look up the "hello_plugin" function
    if !gmodule.symbol(module, "g_print", cast(^glib.pointer)&g_print_proc) {
        glib.printerr(
            "Failed to find symbol 'hello_plugin': %s\n",
            gmodule.error(),
        )
        os.exit(1)
    }

    // Call the function
    g_print_proc("hello from loaded proc: %d\n", 25)
}

