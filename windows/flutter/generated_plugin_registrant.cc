//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <flutter_timezone/flutter_timezone_plugin_c_api.h>
#include <sqlite3_flutter_libs/sqlite3_flutter_libs_plugin.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  FlutterTimezonePluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FlutterTimezonePluginCApi"));
  Sqlite3FlutterLibsPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("Sqlite3FlutterLibsPlugin"));
}
