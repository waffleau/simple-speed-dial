OptionsCtrl = (Bookmark, Storage) ->
  self = this

  folders = []
  model = localStorage

  self.enableSync = () ->
    if optionsModel.enable_sync
      chrome.storage.sync.getBytesInUse(null, (bytes) ->
        if bytes > 0 && confirm('You have previously synchronized data.\nDo you want to overwrite your current local settings with your previously saved remote settings?')
            Storage.restoreFromSync()
      )

  self.fetchFolders = () ->
    Bookmark.getFolders().then (response) ->
      folders = response

  self.getBackgroundColor = () ->
    model.background_color

  self.getFolders = () ->
    folders

  self.getModel = () ->
    model

  self.resetLocalSettings = () ->
    if confirm("Are you sure you want to reset your local settings? All custom configuration will be lost")
      localStorage.clear()
      Storage.createDefaults()
      model = localStorage

  self.resetSyncSettings = () ->
    if confirm("Are you sure you want to reset your sync settings? You will lose all sync data")
      chrome.storage.sync.clear()

  self.fetchFolders()

  return self

OptionsCtrl.$inject = ['Bookmark', 'Storage']


angular.module("simpleSpeedDial")
  .controller('OptionsCtrl', OptionsCtrl)
