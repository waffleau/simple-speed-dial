(function() {
  var dialEntry;

  dialEntry = function() {
    return {
      restrict: 'E',
      replace: true,
      templateUrl: '/templates/bookmarks/show.html'
    };
  };

  angular.module('simpleSpeedDial').directive('dialEntry', dialEntry);

}).call(this);
