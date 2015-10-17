speedDial = ($window) ->
  return {
    restrict : 'A'
    link: (scope, elem, width) ->

      calculateSizes = () ->
        dialColumns = localStorage.getItem('dial_columns')
        dialWidth = localStorage.getItem('dial_width')

        bookmarkMargin = 20
        minEntryWidth = 120

        # Assign sizes to the scope
        scope.dialWidth = $window.innerWidth * dialWidth * 0.01
        scope.entryWidth = (scope.dialWidth / dialColumns) - bookmarkMargin
        scope.entryWidth = minEntryWidth if scope.entryWidth < minEntryWidth
        scope.entryHeight = scope.entryWidth * 0.8 || 0


      resize = () ->
        calculateSizes()

        if localStorage.getItem('center_vertically')
          if localStorage.getItem('show_folder_list')
            scope.dialPadding = (($window.innerWidth - elem.innerHeight) / 2) - 50 || 0
          else
            scope.dialPadding = ($window.innerWidth - elem.innerHeight) / 2 || 0

      resize()

      angular.element($window).on 'resize', () ->
        resize()

      elem.on 'keypress', (e) ->
        if document.activeElement.type != 'text' && document.activeElement.type != 'url'
          key = String.fromCharCode(e.which)

          if key >= 1 && key <= 9 && scope.bookmarks.length > key
            window.location = scope.bookmarks[key - 1].url
  }


angular.module('simpleSpeedDial')
  .directive('speedDial', speedDial)
