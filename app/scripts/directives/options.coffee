angular.module "speeddial"

  .directive("optionBindings", ["$window", ($window) ->
    return {
      restrict: 'A'
      link: (scope, elem, attrs) ->
        # If the Esc key is pressed go back to the new tab page
        angular.element($window).on 'keyup', (e) ->
          if e.which == 27   # 27 is the character code of the escape key
            window.location = '/views/newtab.html'
    }
  ])  # optionBindings


  .directive("jsonEntry", [() ->
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
  ])  # jsonEntry

