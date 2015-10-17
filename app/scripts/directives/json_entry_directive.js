(function() {
  var jsonEntry;

  jsonEntry = function() {
    return {
      restrict: 'A',
      link: function(scope, elem, attrs) {
        return elem.on("blur", function(e) {
          try {
            return JSON.parse(elem[0].value);
          } catch (_error) {
            e = _error;
            alert("You must enter a valid JSON hash");
            return e.preventDefault();
          }
        });
      }
    };
  };

  angular.module('simpleSpeedDial').directive('jsonEntry', jsonEntry);

}).call(this);
