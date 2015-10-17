(function() {
  var BookmarksCtrl;

  BookmarksCtrl = function($scope, ngDialog, Bookmark, Capture, Storage) {
    var bookmarks, fetchFolders, folders, openFolder, self;
    self = this;
    bookmarks = [];
    folders = [];
    self.captureBookmark = function(bookmark) {
      return Capture.captureVisibleTab(bookmark.url).then(function(response) {
        bookmark.customIcon = response;
        bookmark.image = response;
        return Storage.saveCustomData(bookmark);
      });
    };
    self.editBookmark = function(bookmark) {
      var modalScope;
      modalScope = $scope.$new();
      modalScope.bookmarkModel = bookmark;
      modalScope.saveBookmark = function() {
        return self.saveBookmark(bookmark);
      };
      return ngDialog.open({
        template: '/templates/bookmarks/form.html',
        scope: modalScope
      });
    };
    self.fetchBookmarks = function() {
      return Bookmark.getAll(self.folderId).then(function(response) {
        return bookmarks = response;
      });
    };
    self.getBookmarks = function() {
      return bookmarks;
    };
    self.getFolders = function() {
      return folders;
    };
    self.newBookmark = function() {
      return self.editBookmark({});
    };
    self.openBookmark = function(bookmark) {
      if (bookmark.isFolder) {
        return openFolder(bookmark.id);
      }
    };
    self.removeBookmark = function(bookmark) {
      if (confirm("Are you sure you want to delete the bookmark \"" + bookmark.title + "\"?")) {
        return Bookmark.deleteBookmark(bookmark).then(function(response) {
          if (response) {
            Storage.deleteCustomData(bookmark);
            return self.bookmarks = _.reject(self.bookmarks, function(b) {
              return b.id === bookmark.id;
            });
          }
        });
      }
    };
    self.saveBookmark = function(bookmark) {
      bookmark.parentId = self.folderId;
      return Bookmark.saveBookmark(bookmark).then(function(response) {
        var savedBookmark;
        if (response) {
          savedBookmark = Storage.loadBookmark(bookmark);
          self.bookmarks.push(savedBookmark);
          self.bookmarks = _.uniq(self.bookmarks, function(b) {
            return b.id;
          });
          return ngDialog.close();
        }
      });
    };
    fetchFolders = function() {
      return Bookmark.getFolders().then(function(response) {
        return folders = response;
      });
    };
    openFolder = function(folderId) {
      self.folderId = folderId;
      return self.fetchBookmarks();
    };
    fetchFolders();
    openFolder(Bookmark.getStartingFolder());
    return self;
  };

  BookmarksCtrl.$inject = ['$scope', 'ngDialog', 'Bookmark', 'Capture', 'Storage'];

  angular.module("simpleSpeedDial").controller('BookmarksCtrl', BookmarksCtrl);

}).call(this);
