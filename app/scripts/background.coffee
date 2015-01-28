'use strict';

# Restore settings from chrome.storage.sync API
@restoreFromSync = () ->
  chrome.storage.sync.get(null, (syncObject) ->
    Object.keys(syncObject).forEach (key) ->
      localStorage.setItem(key, syncObject[key])

    window.location.reload()
  )


# Sync settings to chrome.storage.sync API
syncToStorage = () ->
  settingsObject = {}

  Object.keys(localStorage).forEach (key) ->
    settingsObject[key] = localStorage[key]

  chrome.storage.sync.set(settingsObject)


# Listen for sync events and update from synchronized data
if localStorage.getItem('enable_sync') == 'true'
  chrome.storage.onChanged.addListener () ->
    restoreFromSync()
