(function() {
  var Bookmark;

  Bookmark = function($q, Storage) {
    return Bookmark = (function() {
      function Bookmark() {}

      Bookmark.deleteBookmark = function(bookmark) {
        var deferred;
        deferred = $q.defer();
        if (bookmark.isFolder) {
          chrome.bookmarks.removeTree(bookmark.id, function() {
            return deferred.resolve(true);
          });
        } else {
          chrome.bookmarks.remove(bookmark.id, function() {
            return deferred.resolve(true);
          });
        }
        return deferred.promise;
      };

      Bookmark.getAll = function(folderId) {
        var deferred;
        deferred = $q.defer();
        chrome.bookmarks.getSubTree(folderId, function(node) {
          var bookmarks;
          bookmarks = [];
          node[0].children.forEach(function(bookmark) {
            if (bookmark.url != null) {
              bookmark = Storage.loadBookmark(bookmark);
            } else {
              bookmark.isFolder = true;
            }
            bookmark.parentId = folderId;
            return bookmarks.push(bookmark);
          });
          return deferred.resolve(bookmarks);
        });
        return deferred.promise;
      };

      Bookmark.getStartingFolder = function() {
        return localStorage.getItem('default_folder_id') || "1";
      };

      Bookmark.getFolders = function() {
        var deferred;
        deferred = $q.defer();
        chrome.bookmarks.getTree(function(rootNode) {
          var child, folderList, node, openList;
          folderList = [];
          openList = [];
          openList.push(rootNode[0].children[0]);
          openList.push(rootNode[0].children[1]);
          while ((node = openList.pop()) != null) {
            if (node.children != null) {
              if (node.parentId === '0') {
                node.path = '';
              }
              node.path += node.title;
              while ((child = node.children.pop()) != null) {
                if (child.children != null) {
                  child.path = node.path + ' > ';
                  openList.push(child);
                }
              }
              folderList.push(node);
            }
          }
          folderList.sort(function(a, b) {
            return a.path.localeCompare(b.path);
          });
          return deferred.resolve(folderList);
        });
        return deferred.promise;
      };

      Bookmark.saveBookmark = function(bookmark) {
        var deferred, hash, id;
        deferred = $q.defer();
        id = bookmark.id;
        hash = {
          title: bookmark.title,
          url: bookmark.url
        };
        if (id != null) {
          chrome.bookmarks.update(id, hash, function(result) {
            Storage.saveCustomData(bookmark);
            return deferred.resolve(true);
          });
        } else {
          hash.parentId = bookmark.parentId;
          chrome.bookmarks.create(hash, function() {
            Storage.saveCustomData(bookmark);
            return deferred.resolve(true);
          });
        }
        return deferred.promise;
      };

      Bookmark.updateOrder = function(bookmarks) {
        var i, j, ref, results;
        results = [];
        for (i = j = 0, ref = bookmarks.length; j <= ref; i = j += 1) {
          results.push(chrome.bookmarks.move(bookmark.id, {
            parentId: bookmark.parentId,
            index: i
          }));
        }
        return results;
      };

      return Bookmark;

    })();
  };

  Bookmark.$inject = ['$q', 'Storage'];

  angular.module('simpleSpeedDial').factory('Bookmark', Bookmark);

}).call(this);
