RunConfig = ($rootScope, Storage) ->
  $rootScope.backgroundColor = localStorage.getItem('background_color')
  Storage.createDefaults()

RunConfig.$inject = ['$rootScope', 'Storage']


angular.module('simpleSpeedDial')
  .run(RunConfig)
