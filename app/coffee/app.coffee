'use strict'

angular.module('simpleSpeedDial', [
  'ngDialog'
])

.run(["$rootScope", "Storage", ($rootScope, Storage) ->
  $rootScope.backgroundColor = localStorage.getItem('background_color')
  Storage.createDefaults()
])
