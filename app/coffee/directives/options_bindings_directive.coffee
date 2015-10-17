optionBindings = ($window) ->
  return {
    restrict: 'A'
    link: (scope, elem, attrs) ->
      # If the Esc key is pressed go back to the new tab page
      angular.element($window).on 'keyup', (e) ->
        if e.which == 27   # 27 is the character code of the escape key
          window.location = '/index.html'
  }


angular.module('simpleSpeedDial')
  .directive('optionBindings', optionBindings)
