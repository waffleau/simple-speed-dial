'use strict';
/*global $:false*/

/*
* Methods which interface with chrome's bookmark API
*/

function isValidUrl(url) {
  //The regex used in AngularJS to validate a URL + chrome internal pages & extension url & on-disk files
  var URL_REGEXP = /^(http|https|ftp|file|chrome|chrome-extension):\/\/(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&%@!\-\/]))?$/;
  return URL_REGEXP.test(url);
}


function buildBookmarkHash(title, url) {
  if (title.length === 0) {
    return undefined;
  }
  // Chrome won't create bookmarks without HTTP
  if (!isValidUrl(url) && url.length !== 0) {
    url = 'http://' + url;
  }

  return { 'title': title, 'url': url };
}


// Adds a new bookmark to chrome, and displays it on the speed dial
function addBookmark(title, url) {
  var hash = buildBookmarkHash(title, url);
  if (hash !== undefined) {
    hash.parentId = $('#dial').prop('folderId');
    chrome.bookmarks.create(hash, function() {
      generateFolderList();
      createSpeedDial(getStartingFolder());
    });
  } else {
    alert('- Adding a new Folder only requires a Title \n- Adding a new Bookmark requires both a Title and a URL');
  }
}

// Deletes a bookmarks and removes it from the speed dial
function removeBookmark(bookmark) {
  chrome.bookmarks.remove(bookmark.id, function() {
    $('#' + bookmark.id).remove();
    updateCustomIcon('', bookmark.url);
    alignVertical();
  });
}

// Deletes an entire folder tree and removes it from the speed dial
function removeFolder(id) {
  chrome.bookmarks.removeTree(id, function() {
    $('#' + id).remove();
    generateFolderList();
    alignVertical();
  });
}

function updateBookmark(id, title, url) {
  var hash = buildBookmarkHash(title, url);
  var oldUrl = $('#' + id).find('.bookmark').prop('href');
  //Actually make sure the URL being modified is valid instead of always
  //prepending http:// to it creating new valid+invalid bookmark
  if (url.length !== 0 && !isValidUrl(url)) {
    hash = undefined;
  }

  if (hash !== undefined) {
    chrome.bookmarks.update(id, hash, function(result) {
      $('#' + result.id).find('.bookmark').prop({
        'title': result.title,
        'href': result.url
      });
    });
    updateCustomIcon(url, oldUrl);
  } else {
    alert('Editing an existing Bookmark requires both a Title and a valid URL in Chrome\n\n' +
    'For example, valid URL\'s start with: \n - http:// \n - https:// \n - ftp://');
  }
}

function updateBookmarksOrder() {
  $('.entry').not('#new_entry').each(function(index) {
    chrome.bookmarks.move(this.id, {
      'parentId': $('#dial').prop('folderId'),
      'index': index
    });
  });
}
