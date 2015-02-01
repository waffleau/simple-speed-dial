angular.module "speeddial"

  .controller("BookmarksCtrl", ["$scope", "ngDialog", "Bookmark", "Capture", "Storage", ($scope, ngDialog, Bookmark, Capture, Storage) ->
    $scope.captureBookmark = (bookmark) ->
      Capture.captureVisibleTab(bookmark.url).then (response) ->
        bookmark.customIcon = response
        bookmark.image = response
        Storage.saveCustomData(bookmark)

    $scope.editBookmark = (bookmark) ->
      $scope.bookmarkModel = bookmark

      ngDialog.open({
        template: '/views/partials/form.html'
        scope: $scope
      })

    $scope.fetchBookmarks = () ->
      Bookmark.getAll($scope.folderId).then (response) ->
        $scope.bookmarks = response

    $scope.fetchFolders = () ->
      Bookmark.getFolders().then (response) ->
        $scope.folders = response

    $scope.newBookmark = () ->
      $scope.bookmarkModel = {}

      ngDialog.open({
        template: '/views/partials/form.html'
        scope: $scope
      })

    $scope.openBookmark = (bookmark) ->
      if bookmark.isFolder
        $scope.openFolder(bookmark.id)

    $scope.openFolder = (folderId) ->
      $scope.folderId = folderId
      $scope.fetchBookmarks()

    $scope.removeBookmark = (bookmark) ->
      if confirm("Are you sure you want to delete the bookmark \"#{bookmark.title}\"?")
        Bookmark.deleteBookmark(bookmark).then (response) ->
          if response
            Storage.deleteCustomData(bookmark)
            $scope.bookmarks = _.reject($scope.bookmarks, (b) -> b.id == bookmark.id)

    $scope.saveBookmark = () ->
      $scope.bookmarkModel.parentId = $scope.folderId

      Bookmark.saveBookmark($scope.bookmarkModel).then (response) ->
        if response
          bookmark = Storage.loadBookmark($scope.bookmarkModel)
          $scope.bookmarks.push(bookmark)

          $scope.bookmarks = _.uniq($scope.bookmarks, (b) -> b.id)
          $scope.bookmarkModel = null

          ngDialog.close()

    $scope.fetchFolders()
    $scope.openFolder(Bookmark.getStartingFolder())
  ])
