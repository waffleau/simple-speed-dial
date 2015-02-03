'use strict'

angular.module('speeddial', [
  'ngDialog'
])

.run(["$rootScope", "Storage", ($rootScope, Storage) ->
  $rootScope.backgroundColor = localStorage.getItem('background_color')
  Storage.createDefaults()
])
