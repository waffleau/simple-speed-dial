(function() {
  var optionBindings;

  optionBindings = function($window) {
    return {
      restrict: 'A',
      link: function(scope, elem, attrs) {
        return angular.element($window).on('keyup', function(e) {
          if (e.which === 27) {
            return window.location = '/index.html';
          }
        });
      }
    };
  };

  angular.module('simpleSpeedDial').directive('optionBindings', optionBindings);

}).call(this);
