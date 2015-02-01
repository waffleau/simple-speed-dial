angular.module "speeddial"

  .factory "Storage", [() ->
    BOOKMARK_DATA = "bookmark"
    THUMBNAIL_SERVICE = 'thumbnailing_service'
    THUMBNAIL_TOKEN = '[URL]'

    class Storage

      @createDefaults = () ->
        defaultValues = {
          'background_color' : '#cccccc',
          'center_vertically' : true,
          'default_folder_id' : '1',
          'dial_columns' : 6,
          'dial_width' : 70,
          'drag_and_drop' : true,
          'enable_sync' : false,
          'folder_color' : '#888888',
          'force_http' : true,
          'show_advanced' : false,
          'show_folder_list' : true,
          'show_new_entry' : true,
          'show_options_gear' : true,
          'show_subfolder_icons' : true,
          'thumbnailing_service' : 'http://api.webthumbnail.org/?width=500&height=400&screen=1280&url=[URL]'
        }

        # Creates default localStorage values if they don't already exist
        for name, value of defaultValues
          if !localStorage.getItem(name)? || localStorage.getItem(name) == "undefined"
            localStorage.setItem(name, value)

      @deleteCustomData: (bookmark) ->
        localStorage.clear("#{BOOKMARK_DATA}_#{bookmark.id}")


      @getCustomData: (bookmark) ->
        return localStorage.getItem("#{BOOKMARK_DATA}_#{bookmark.id}")


      @getThumbnailUrl: (bookmark) ->
        return localStorage.getItem(THUMBNAIL_SERVICE).replace(THUMBNAIL_TOKEN, bookmark.url)


      @loadBookmark: (bookmark) ->
        data = Storage.getCustomData(bookmark)

        if data?
          bookmark.customIcon = data
          bookmark.image = data
        else
          bookmark.image = Storage.getThumbnailUrl(bookmark)

        return bookmark


      # Restore settings from chrome.storage.sync API
      @restoreFromSync: () ->
        chrome.storage.sync.get(null, (syncObject) ->
          Object.keys(syncObject).forEach (key) ->
            localStorage.setItem(key, syncObject[key])
        )


      @saveCustomData: (bookmark) ->
        if bookmark.id?
          localStorage.setItem("#{BOOKMARK_DATA}_#{bookmark.id}", bookmark.customIcon)


      # Sync settings to chrome.storage.sync API
      @syncToStorage: () ->
        if localStorage.getItem('enable_sync')
          settingsObject = {}

          Object.keys(localStorage).forEach (key) ->
            settingsObject[key] = localStorage[key]

          chrome.storage.sync.set(settingsObject)

      # Listen for sync events and update from synchronized data
      #if localStorage.getItem('enable_sync') == 'true'
      #  chrome.storage.onChanged.addListener () ->
      #    restoreFromSync()

  ]
