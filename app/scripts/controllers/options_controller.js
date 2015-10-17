(function() {
  var OptionsCtrl;

  OptionsCtrl = function(Bookmark, Storage) {
    var folders, model, self;
    self = this;
    folders = [];
    model = localStorage;
    self.enableSync = function() {
      if (optionsModel.enable_sync) {
        return chrome.storage.sync.getBytesInUse(null, function(bytes) {
          if (bytes > 0 && confirm('You have previously synchronized data.\nDo you want to overwrite your current local settings with your previously saved remote settings?')) {
            return Storage.restoreFromSync();
          }
        });
      }
    };
    self.fetchFolders = function() {
      return Bookmark.getFolders().then(function(response) {
        return folders = response;
      });
    };
    self.getBackgroundColor = function() {
      return model.background_color;
    };
    self.getFolders = function() {
      return folders;
    };
    self.getModel = function() {
      return model;
    };
    self.resetLocalSettings = function() {
      if (confirm("Are you sure you want to reset your local settings? All custom configuration will be lost")) {
        localStorage.clear();
        Storage.createDefaults();
        return model = localStorage;
      }
    };
    self.resetSyncSettings = function() {
      if (confirm("Are you sure you want to reset your sync settings? You will lose all sync data")) {
        return chrome.storage.sync.clear();
      }
    };
    self.fetchFolders();
    return self;
  };

  OptionsCtrl.$inject = ['Bookmark', 'Storage'];

  angular.module("simpleSpeedDial").controller('OptionsCtrl', OptionsCtrl);

}).call(this);
