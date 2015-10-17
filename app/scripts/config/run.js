(function() {
  var RunConfig;

  RunConfig = function($rootScope, Storage) {
    $rootScope.backgroundColor = localStorage.getItem('background_color');
    return Storage.createDefaults();
  };

  RunConfig.$inject = ['$rootScope', 'Storage'];

  angular.module('simpleSpeedDial').run(RunConfig);

}).call(this);
