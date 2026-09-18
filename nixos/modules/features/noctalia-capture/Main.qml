import QtQuick
import Quickshell.Io

Item {
  property var pluginApi: null

  IpcHandler {
    target: "plugin:capture"

    function open() {
      if (!pluginApi)
        return
      pluginApi.withCurrentScreen(function(screen) {
        pluginApi.openLauncher(screen)
      })
    }
  }
}
