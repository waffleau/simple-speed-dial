'use strict';

##
# Methods which interface with chrome's bookmark API
##
URL_REGEXP = /^(http|https|ftp|file|chrome|chrome-extension):\/\/(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&%@!\-\/]))?$/

@isValidUrl = (url) ->
  # The regex used in AngularJS to validate a URL + chrome internal pages & extension url & on-disk files
  return URL_REGEXP.test(url)


@buildBookmarkHash = (title, url) ->
  return undefined if title.length == 0

  # Chrome won't create bookmarks without HTTP
  if !isValidUrl(url) && url.length != 0
    url = "http://#{url}"

  return { title: title, url: url }


# Adds a new bookmark to chrome, and displays it on the speed dial
@addBookmark = (title, url) ->
  hash = buildBookmarkHash(title, url)

  if hash?
    hash.parentId = $('#dial').prop('folderId')

    chrome.bookmarks.create(hash, () ->
      generateFolderList()
      createSpeedDial(getStartingFolder())
    )
  else
    alert '- Adding a new Folder only requires a Title \n- Adding a new Bookmark requires both a Title and a URL'


# Deletes a bookmarks and removes it from the speed dial
@removeBookmark = (bookmark) ->
  chrome.bookmarks.remove(bookmark.id, () ->
    $('#' + bookmark.id).remove()
    updateCustomIcon('', bookmark.url)
    alignVertical()
  )


# Deletes an entire folder tree and removes it from the speed dial
@removeFolder = (id) ->
  chrome.bookmarks.removeTree(id, () ->
    $('#' + id).remove()
    generateFolderList()
    alignVertical()
  )


@updateBookmark = (id, title, url) ->
  hash = buildBookmarkHash(title, url)
  oldUrl = $('#' + id).find('.bookmark').prop('href')

  if url.length > 0 && !isValidUrl(url)
    hash = undefined

  if hash?
    chrome.bookmarks.update(id, hash, (result) ->
      $('#' + result.id).find('.bookmark').prop({ title: result.title, href: result.url })
    )

    updateCustomIcon(url, oldUrl)
  else
    alert 'Editing an existing Bookmark requires both a Title and a valid URL in Chrome\n\nFor example, valid URL\'s start with: \n - http:// \n - https:// \n - ftp://'


@updateBookmarksOrder = () ->
  $('.entry').not('#new_entry').each (index) ->
    chrome.bookmarks.move(this.id, { parentId: $('#dial').prop('folderId'), index: index })
