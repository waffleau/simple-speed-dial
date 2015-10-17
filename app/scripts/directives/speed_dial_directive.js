(function() {
  var speedDial;

  speedDial = function($window) {
    return {
      restrict: 'A',
      link: function(scope, elem, width) {
        var calculateSizes, resize;
        calculateSizes = function() {
          var bookmarkMargin, dialColumns, dialWidth, minEntryWidth;
          dialColumns = localStorage.getItem('dial_columns');
          dialWidth = localStorage.getItem('dial_width');
          bookmarkMargin = 20;
          minEntryWidth = 120;
          scope.dialWidth = $window.innerWidth * dialWidth * 0.01;
          scope.entryWidth = (scope.dialWidth / dialColumns) - bookmarkMargin;
          if (scope.entryWidth < minEntryWidth) {
            scope.entryWidth = minEntryWidth;
          }
          return scope.entryHeight = scope.entryWidth * 0.8 || 0;
        };
        resize = function() {
          calculateSizes();
          if (localStorage.getItem('center_vertically')) {
            if (localStorage.getItem('show_folder_list')) {
              return scope.dialPadding = (($window.innerWidth - elem.innerHeight) / 2) - 50 || 0;
            } else {
              return scope.dialPadding = ($window.innerWidth - elem.innerHeight) / 2 || 0;
            }
          }
        };
        resize();
        angular.element($window).on('resize', function() {
          return resize();
        });
        return elem.on('keypress', function(e) {
          var key;
          if (document.activeElement.type !== 'text' && document.activeElement.type !== 'url') {
            key = String.fromCharCode(e.which);
            if (key >= 1 && key <= 9 && scope.bookmarks.length > key) {
              return window.location = scope.bookmarks[key - 1].url;
            }
          }
        });
      }
    };
  };

  angular.module('simpleSpeedDial').directive('speedDial', speedDial);

}).call(this);
