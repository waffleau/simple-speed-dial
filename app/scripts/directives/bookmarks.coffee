angular.module "speeddial"

  .directive("dialEntry", [() ->
    return {
      restrict : 'E'
      replace: true
      templateUrl: "/views/partials/bookmark.html"
    }
  ])  # dialEntry
