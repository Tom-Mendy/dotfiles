import QtQuick
import Quickshell.Io
import qs.Services.UI

Item {
  id: root

  property var pluginApi: null
  property var launcher: null
  property string name: "rbw"
  property string supportedLayouts: "list"
  property bool handleSearch: false
  property var entries: []
  property var selectedEntry: null
  property bool loading: false
  property string loadError: ""
  property string actionLabel: ""

  Process {
    id: listProcess
    stdout: StdioCollector {}

    onExited: function(exitCode, exitStatus) {
      root.loading = false
      if (exitCode !== 0) {
        root.entries = []
        root.loadError = "Unable to read the rbw vault"
      } else {
        try {
          root.entries = JSON.parse(listProcess.stdout.text)
          root.loadError = ""
        } catch (error) {
          root.entries = []
          root.loadError = "Invalid response from rbw"
        }
      }
      if (root.launcher)
        root.launcher.updateResults()
    }
  }

  Process {
    id: actionProcess

    onExited: function(exitCode, exitStatus) {
      if (exitCode === 0)
        ToastService.showNotice("rbw", root.actionLabel + " copied")
      else
        ToastService.showError("rbw", "Unable to copy " + root.actionLabel.toLowerCase())
    }
  }

  function init() {}

  function onOpened() {
    selectedEntry = null
    loadError = ""
    loading = true
    if (!listProcess.running)
      listProcess.exec(["rbw", "list", "--raw"])
  }

  function handleCommand(searchText) {
    return searchText === ">rbw" || searchText.startsWith(">rbw ")
  }

  function commands() {
    return [{
      name: ">rbw",
      description: "Search Bitwarden",
      icon: "key",
      isTablerIcon: true,
      onActivate: function() {
        launcher.setSearchText(">rbw ")
      }
    }]
  }

  function statusResult(name, description, icon, action) {
    return [{
      name: name,
      description: description,
      icon: icon,
      isTablerIcon: true,
      provider: root,
      onActivate: action || function() {}
    }]
  }

  function getResults(searchText) {
    if (!handleCommand(searchText))
      return []
    if (selectedEntry)
      return actionResults(selectedEntry)
    if (loading)
      return statusResult("Loading…", "Reading rbw vault metadata", "refresh")
    if (loadError !== "")
      return statusResult("rbw error", loadError, "alert-circle", reload)

    var terms = searchText.slice(4).trim().toLowerCase().split(/\s+/).filter(function(term) {
      return term !== ""
    })
    var matches = entries.filter(function(entry) {
      var text = [entry.name, entry.user, entry.folder].filter(Boolean).join(" ").toLowerCase()
      return terms.every(function(term) {
        return text.includes(term)
      })
    }).slice(0, 50)

    if (matches.length === 0)
      return statusResult("No matching entries", "Try another rbw query", "search")

    return matches.map(function(entry) {
      return {
        name: entry.name || "Unnamed entry",
        description: [entry.user, entry.folder].filter(Boolean).join(" • "),
        icon: "key",
        isTablerIcon: true,
        provider: root,
        onActivate: function() {
          root.selectedEntry = entry
          launcher.setSearchText(">rbw ")
          launcher.updateResults()
        }
      }
    })
  }

  function actionResults(entry) {
    var results = [{
      name: "Back",
      description: entry.name || "",
      icon: "arrow-left",
      isTablerIcon: true,
      provider: root,
      onActivate: function() {
        root.selectedEntry = null
        launcher.updateResults()
      }
    }, copyAction("Password", "copy", ["rbw", "get", "--clipboard", entry.id])]

    if (entry.user)
      results.push(copyAction("Username", "user", ["rbw", "get", "--field", "username", "--clipboard", entry.id]))
    if (entry.entry_type === "Login")
      results.push(copyAction("OTP", "shield-lock", ["rbw", "code", "--clipboard", entry.id]))

    return results
  }

  function copyAction(label, icon, command) {
    return {
      name: "Copy " + label.toLowerCase(),
      description: selectedEntry ? selectedEntry.name : "",
      icon: icon,
      isTablerIcon: true,
      provider: root,
      onActivate: function() {
        root.actionLabel = label
        root.selectedEntry = null
        launcher.close()
        actionProcess.exec(command)
      }
    }
  }

  function reload() {
    loadError = ""
    loading = true
    listProcess.exec(["rbw", "list", "--raw"])
    if (launcher)
      launcher.updateResults()
  }
}
