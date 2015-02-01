'use strict'

angular.module('speeddial', [
  'ngDialog'
  'ui.bootstrap'
])

.run(["$rootScope", "Storage", ($rootScope, Storage) ->
  $rootScope.backgroundColor = localStorage.getItem('background_color')
  Storage.createDefaults()
])
