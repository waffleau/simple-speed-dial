angular.module "speeddial"

  .factory "Bookmark", ["$q", "Storage", ($q, Storage) ->
    class Bookmark

      @deleteBookmark: (bookmark) ->
        deferred = $q.defer()

        if bookmark.isFolder
          chrome.bookmarks.removeTree(bookmark.id, () -> deferred.resolve(true))
        else
          chrome.bookmarks.remove(bookmark.id, () -> deferred.resolve(true))

        return deferred.promise


      @getAll: (folderId) ->
        deferred = $q.defer()

        chrome.bookmarks.getSubTree(folderId, (node) ->
          bookmarks = []

          node[0].children.forEach (bookmark) ->
            if bookmark.url?
              bookmark = Storage.loadBookmark(bookmark)
            else
              bookmark.isFolder = true

            bookmark.parentId = folderId
            bookmarks.push(bookmark)

          deferred.resolve(bookmarks)
        )

        return deferred.promise


      @getStartingFolder: () ->
        return localStorage.getItem('default_folder_id') || "1"  # Bookmarks bar


      # Generates a list of all folders under chrome bookmarks
      @getFolders = () ->
        deferred = $q.defer()

        chrome.bookmarks.getTree (rootNode) ->
          folderList = []
          openList = []

          # Never more than 2 root nodes, push both Bookmarks Bar & Other Bookmarks into array
          openList.push(rootNode[0].children[0])
          openList.push(rootNode[0].children[1])

          while (node = openList.pop())?
            if node.children?
              if node.parentId == '0'
                node.path = '' # Root elements have no parent so we shouldn't show their path

              node.path += node.title;

              while (child = node.children.pop())?
                if child.children?
                  child.path = node.path + ' > '
                  openList.push(child)


              folderList.push(node)

          folderList.sort (a, b) -> a.path.localeCompare(b.path)
          deferred.resolve(folderList)

        return deferred.promise


      # Persist changes to a bookmark
      @saveBookmark = (bookmark) ->
        deferred = $q.defer()

        id = bookmark.id
        hash = { title: bookmark.title, url: bookmark.url }

        if id?
          chrome.bookmarks.update(id, hash, (result) ->
            Storage.saveCustomData(bookmark)
            deferred.resolve(true)
          )
        else
          hash.parentId = bookmark.parentId

          chrome.bookmarks.create(hash, () ->
            Storage.saveCustomData(bookmark)
            deferred.resolve(true)
          )

        return deferred.promise


      @updateOrder = (bookmarks) ->
        for i in [0..bookmarks.length] by 1
          chrome.bookmarks.move(bookmark.id, { parentId: bookmark.parentId, index: i })

  ]  # Bookmark
