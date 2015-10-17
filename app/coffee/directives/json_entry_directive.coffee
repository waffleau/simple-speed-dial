jsonEntry = () ->
  return {
    restrict: 'A'
    link: (scope, elem, attrs) ->
      elem.on "blur", (e) ->
        try
          JSON.parse(elem[0].value)
        catch e
          alert("You must enter a valid JSON hash")
          e.preventDefault()
  }


angular.module('simpleSpeedDial')
  .directive('jsonEntry', jsonEntry)
