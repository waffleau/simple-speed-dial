'use strict';

// Restore settings from chrome.storage.sync API
function restoreFromSync() {
  chrome.storage.sync.get(null, function (syncObject) {
    Object.keys(syncObject).forEach(function(key) {
      localStorage.setItem(key, syncObject[key]);
    });
    window.location.reload();
  });
}

// Sync settings to chrome.storage.sync API
function syncToStorage() {
  var settingsObject = {};

  Object.keys(localStorage).forEach(function(key) {
    settingsObject[key] = localStorage[key];
  });

  chrome.storage.sync.set(settingsObject);
}

// Listen for sync events and update from synchronized data
if (localStorage.getItem('enable_sync') === 'true') {
  chrome.storage.onChanged.addListener(function() {
    restoreFromSync();
  });
}
