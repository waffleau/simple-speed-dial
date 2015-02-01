angular.module "speeddial"

  .factory("Capture", ["$q", "Bookmark", ($q, Bookmark) ->
    class Capture
      @captureVisibleTab = (url) ->
        deferred = $q.defer()

        chrome.permissions.request {
          permissions: ['tabs'],
          origins: ['<all_urls>']
        }, (granted) ->
          if granted
            # Open url in new window
            chrome.tabs.create { url: url }, (tab) ->
              # Add listener
              chrome.tabs.onUpdated.addListener (tabId, info) ->
                # If this current tab and it update complete - capture thumbnail
                if tab.id == tabId && info.status == 'complete'
                  chrome.tabs.captureVisibleTab(null, {}, (dataUrl) ->

                    # Close tab with thumbnail
                    chrome.tabs.remove(tabId, () ->

                      # Get current tab (tab with speed dial) and reload it (for load new thumbnail)
                      chrome.tabs.getCurrent (tab) ->
                        deferred.resolve(dataUrl)
                    )
                  )

        return deferred.promise
  ])
