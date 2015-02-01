angular.module "speeddial"

  .controller("OptionsCtrl", ["$scope", "Bookmark", "Storage", ($scope, Bookmark, Storage) ->
    $scope.fetchFolders = () ->
      Bookmark.getFolders().then (response) ->
        $scope.folders = response

    $scope.enableSync = () ->
      if $scope.optionsModel.enable_sync
        chrome.storage.sync.getBytesInUse(null, (bytes) ->
          if bytes > 0 && confirm('You have previously synchronized data.\nDo you want to overwrite your current local settings with your previously saved remote settings?')
              Storage.restoreFromSync()
        )

    $scope.resetLocalSettings = () ->
      if confirm("Are you sure you want to reset your local settings? All custom configuration will be lost")
        localStorage.clear()
        Storage.createDefaults()
        $scope.optionsModel = localStorage

    $scope.resetSyncSettings = () ->
      if confirm("Are you sure you want to reset your sync settings? You will lose all sync data")
        chrome.storage.sync.clear()

    $scope.fetchFolders()
    $scope.optionsModel = localStorage
  ])
