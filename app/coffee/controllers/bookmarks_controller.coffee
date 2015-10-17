BookmarksCtrl = ($scope, ngDialog, Bookmark, Capture, Storage) ->
  self = this

  bookmarks = []
  folders = []

  self.captureBookmark = (bookmark) ->
    Capture.captureVisibleTab(bookmark.url).then (response) ->
      bookmark.customIcon = response
      bookmark.image = response

      Storage.saveCustomData(bookmark)

  self.editBookmark = (bookmark) ->
    modalScope = $scope.$new()
    modalScope.bookmarkModel = bookmark
    modalScope.saveBookmark = () ->
      self.saveBookmark(bookmark)

    ngDialog.open({
      template: '/templates/bookmarks/form.html'
      scope: modalScope
    })

  self.fetchBookmarks = () ->
    Bookmark.getAll(self.folderId).then (response) ->
      bookmarks = response

  self.getBookmarks = () ->
    bookmarks

  self.getFolders = () ->
    folders

  self.newBookmark = () ->
    self.editBookmark({})

  self.openBookmark = (bookmark) ->
    if bookmark.isFolder
      openFolder(bookmark.id)


  self.removeBookmark = (bookmark) ->
    if confirm("Are you sure you want to delete the bookmark \"#{bookmark.title}\"?")
      Bookmark.deleteBookmark(bookmark).then (response) ->
        if response
          Storage.deleteCustomData(bookmark)
          self.bookmarks = _.reject(self.bookmarks, (b) -> b.id == bookmark.id)

  self.saveBookmark = (bookmark) ->
    bookmark.parentId = self.folderId

    Bookmark.saveBookmark(bookmark).then (response) ->
      if response
        savedBookmark = Storage.loadBookmark(bookmark)

        self.bookmarks.push(savedBookmark)
        self.bookmarks = _.uniq(self.bookmarks, (b) -> b.id)

        ngDialog.close()


  #
  # Private
  #

  fetchFolders = () ->
    Bookmark.getFolders().then (response) ->
      folders = response

  openFolder = (folderId) ->
    self.folderId = folderId
    self.fetchBookmarks()


  #
  # Initialise
  #

  fetchFolders()
  openFolder(Bookmark.getStartingFolder())

  return self

BookmarksCtrl.$inject = ['$scope', 'ngDialog', 'Bookmark', 'Capture', 'Storage']


angular.module("simpleSpeedDial")
  .controller('BookmarksCtrl', BookmarksCtrl)
