(function() {
  var Storage;

  Storage = function() {
    var BOOKMARK_DATA, THUMBNAIL_SERVICE, THUMBNAIL_TOKEN;
    BOOKMARK_DATA = "bookmark";
    THUMBNAIL_SERVICE = 'thumbnailing_service';
    THUMBNAIL_TOKEN = '[URL]';
    return Storage = (function() {
      function Storage() {}

      Storage.createDefaults = function() {
        var defaultValues, name, results, value;
        defaultValues = {
          'background_color': '#cccccc',
          'center_vertically': true,
          'default_folder_id': '1',
          'dial_columns': 6,
          'dial_width': 70,
          'drag_and_drop': true,
          'enable_sync': false,
          'folder_color': '#888888',
          'force_http': true,
          'show_advanced': false,
          'show_folder_list': true,
          'show_new_entry': true,
          'show_options_gear': true,
          'show_subfolder_icons': true,
          'thumbnailing_service': 'http://api.webthumbnail.org/?width=500&height=400&screen=1280&url=[URL]'
        };
        results = [];
        for (name in defaultValues) {
          value = defaultValues[name];
          if ((localStorage.getItem(name) == null) || localStorage.getItem(name) === "undefined") {
            results.push(localStorage.setItem(name, value));
          } else {
            results.push(void 0);
          }
        }
        return results;
      };

      Storage.deleteCustomData = function(bookmark) {
        return localStorage.removeItem(BOOKMARK_DATA + "_" + bookmark.id);
      };

      Storage.getCustomData = function(bookmark) {
        return localStorage.getItem(BOOKMARK_DATA + "_" + bookmark.id);
      };

      Storage.getThumbnailUrl = function(bookmark) {
        return localStorage.getItem(THUMBNAIL_SERVICE).replace(THUMBNAIL_TOKEN, bookmark.url);
      };

      Storage.loadBookmark = function(bookmark) {
        var data;
        data = Storage.getCustomData(bookmark);
        if (data != null) {
          bookmark.customIcon = data;
          bookmark.image = data;
        } else {
          bookmark.image = Storage.getThumbnailUrl(bookmark);
        }
        return bookmark;
      };

      Storage.restoreFromSync = function() {
        return chrome.storage.sync.get(null, function(syncObject) {
          return Object.keys(syncObject).forEach(function(key) {
            return localStorage.setItem(key, syncObject[key]);
          });
        });
      };

      Storage.saveCustomData = function(bookmark) {
        if (bookmark.id != null) {
          return localStorage.setItem(BOOKMARK_DATA + "_" + bookmark.id, bookmark.customIcon);
        }
      };

      Storage.syncToStorage = function() {
        var settingsObject;
        if (localStorage.getItem('enable_sync')) {
          settingsObject = {};
          Object.keys(localStorage).forEach(function(key) {
            return settingsObject[key] = localStorage[key];
          });
          return chrome.storage.sync.set(settingsObject);
        }
      };

      return Storage;

    })();
  };

  angular.module('simpleSpeedDial').factory('Storage', Storage);

}).call(this);
