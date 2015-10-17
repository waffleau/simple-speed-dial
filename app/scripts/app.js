(function() {
  'use strict';
  angular.module('simpleSpeedDial', ['ngDialog']).run([
    "$rootScope", "Storage", function($rootScope, Storage) {
      $rootScope.backgroundColor = localStorage.getItem('background_color');
      return Storage.createDefaults();
    }
  ]);

}).call(this);
