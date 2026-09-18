import QtQuick
import Quickshell.Io

Item {
  id: root

  property var pluginApi: null
  property var launcher: null
  property string name: "capture"
  property string supportedLayouts: "list"
  property bool handleSearch: false

  Process {
    id: captureProcess
  }

  function init() {}

  function onOpened() {}

  function handleCommand(searchText) {
    return searchText.startsWith(">capture")
  }

  function commands() {
    return [{
      name: ">capture",
      description: "Capture an image or record a video",
      icon: "camera",
      isTablerIcon: true,
      onActivate: function() {
        launcher.setSearchText(">capture ")
      }
    }]
  }

  function action(label, icon, mode) {
    return {
      name: label,
      description: "Save to the media folder and copy the result",
      icon: icon,
      isTablerIcon: true,
      provider: root,
      onActivate: function() {
        launcher.close()
        captureProcess.exec(["media-capture", mode])
      }
    }
  }

  function getResults(searchText) {
    if (!handleCommand(searchText))
      return []
    return [
      action("Capture image", "camera", "image"),
      action("Capture video", "video", "video")
    ]
  }
}
