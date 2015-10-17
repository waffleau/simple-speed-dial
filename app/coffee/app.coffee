'use strict'

angular.module('simpleSpeedDial', [
  'ngDialog'
  'ui.bootstrap'
])

.run(["$rootScope", "Storage", ($rootScope, Storage) ->
  $rootScope.backgroundColor = localStorage.getItem('background_color')
  Storage.createDefaults()
])
