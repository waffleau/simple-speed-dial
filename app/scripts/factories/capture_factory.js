(function() {
  var Capture;

  Capture = function($q, Bookmark) {
    return Capture = (function() {
      function Capture() {}

      Capture.captureVisibleTab = function(url) {
        var deferred;
        deferred = $q.defer();
        chrome.permissions.request({
          permissions: ['tabs'],
          origins: ['<all_urls>']
        }, function(granted) {
          if (granted) {
            return chrome.tabs.create({
              url: url
            }, function(tab) {
              return chrome.tabs.onUpdated.addListener(function(tabId, info) {
                if (tab.id === tabId && info.status === 'complete') {
                  return chrome.tabs.captureVisibleTab(null, {}, function(dataUrl) {
                    return chrome.tabs.remove(tabId, function() {
                      return chrome.tabs.getCurrent(function(tab) {
                        return deferred.resolve(dataUrl);
                      });
                    });
                  });
                }
              });
            });
          }
        });
        return deferred.promise;
      };

      return Capture;

    })();
  };

  Capture.$inject = ['$q', 'Bookmark'];

  angular.module('simpleSpeedDial').factory('Capture', Capture);

}).call(this);
