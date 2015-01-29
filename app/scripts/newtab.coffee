'use strict'


@addNewEntryButton = (entryArray) ->
  newEntry = $('<div class="entry new-entry" id="new-entry" title="Add New"><span class="new-entry__content"></span></div>')

  newEntry.on 'click', () ->
    showBookmarkEntryForm('New Bookmark or Folder', '', '', 'new-entry')

  entryArray.push(newEntry)


@addSpeedDialBookmark = (bookmark, entryArray) ->
  entry = $('<div id="' + bookmark.id + '" class="entry">' +
    '<a class="bookmark" href="' + bookmark.url + '" title="' + bookmark.title + '"">' +
      '<div class="bookmark__image"></div>' +
      '<div class="bookmark__details">' +
        '<span class="bookmark__action edit" title="Edit"><i class="fa fa-pencil"></i></span>' +
        '<span class="bookmark__action reload" title="Reload"><i class="fa fa-refresh"></i></span>' +
        '<span class="bookmark__title">' + bookmark.title + '</span>' +
        '<span class="bookmark__action remove" title="Remove"><i class="fa fa-times"></i></span>' +
      '</div>' +
    '</a>' +
  '</div>')


  #alert(localStorage.getItem('custom_icon_data' + bookmark.id))
  refreshImage(entry, bookmark)

  entry.find('.edit').on 'click', (e) ->
    e.preventDefault()
    showBookmarkEntryForm('Edit Bookmark: ' + bookmark.title, bookmark.title, bookmark.url, bookmark.id)

  entry.find('.remove').on 'click', (e) ->
    e.preventDefault()
    removeBookmark(bookmark) if confirm('Are you sure you want to remove this bookmark?')

  entry.find('.reload').on 'click', (e) ->
    e.preventDefault()
    captureTab(bookmark)

  # If custom icon URL has been set and exists, evaluates to true to center the custom icon
  if JSON.parse(localStorage.getItem('custom_icon_data'))[bookmark.url]
    entry.find('.bookmark__image').addClass('custom')

  entryArray.push(entry)


@addSpeedDialFolder = (bookmark, entryArray) ->
  entry = $('<div class="entry" id="' + bookmark.id + '">' +
              '<a class="bookmark" href="views/newtab.html#"' + bookmark.id + '" title="' + bookmark.title + '">' +
                '<div class="bookmark__image"><span class="fa fa-folder"></span></div>' +
                '<div class="bookmark__details">' +
                  '<span class="bookmark__action edit" title="Edit"><i class="fa fa-pencil"></i></span>' +
                  '<span class="bookmark__title">' + bookmark.title + '</span>' +
                    '<span class="bookmark__action remove" title="Remove"><i class="fa fa-times"></i></span>' +
                '</div>' +
              '</a>' +
            '</div>')

  entry.find('.edit').on 'click', (e) ->
    e.preventDefault()
    showBookmarkEntryForm('Edit Folder: ' + bookmark.title, bookmark.title, bookmark.url, bookmark.id)

  entry.find('.remove').on 'click', (e) ->
    e.preventDefault()

    if confirm('Are you sure you want to remove this folder including all of it\'s bookmarks?')
      removeFolder(bookmark.id)

  entryArray.push(entry)


@alignVertical = () ->
  if localStorage.getItem('center_vertically') == 'true'
    dial = $('#dial')

    if localStorage.getItem('show_folder_list') == 'true'
      dial.css('padding-top', ((window.innerHeight - dial.height()) / 2) - 50 || 0)
    else
      dial.css('padding-top', (window.innerHeight - dial.height()) / 2 || 0)


@captureTab = (bookmark) ->
  bookmarkUrl = "custom_icon_data_#{bookmark.url}"

  chrome.permissions.request {
    permissions: ['tabs'],
    origins: ['<all_urls>']
  }, (granted) ->
    if granted
      # Open bookmark in new window
      chrome.tabs.create({ url: bookmark.url }, (tab) ->
        # Add listener
        chrome.tabs.onUpdated.addListener (tabId, info) ->
          # If this current tab and it update complete - capture thumbnail
          if tab.id == tabId && info.status == 'complete'
            chrome.tabs.captureVisibleTab(null, {}, (dataUrl) ->
              localStorage.setItem(bookmarkUrl, dataUrl)

              # Close tab with thumbnail
              chrome.tabs.remove(tabId, () ->
                # Get current tab (tab with speed dial) and reload it (for load new thumbnail)
                chrome.tabs.getCurrent (tab) ->
                  refreshImage($("##{bookmark.id}"), bookmark)
              )
            )
      )


# Retrieve the bookmarks bar node and use it to generate speed dials
@createSpeedDial = (folderId) ->
  setDialStyles()

  chrome.bookmarks.getSubTree(folderId, (node) ->
    # Loop over bookmarks in folder and add to the dial
    entryArray = []

    (node[0].children).forEach (bookmark) ->
      if bookmark.url?
        addSpeedDialBookmark(bookmark, entryArray)

      if (bookmark.children? && localStorage.getItem('show_subfolder_icons') == 'true')
        addSpeedDialFolder(bookmark, entryArray)

    # Adds the + button to the dom only if enabled
    if localStorage.getItem('show_new_entry') == 'true'
      addNewEntryButton(entryArray)


    # Batch add all the entries to the dial at once and set the folderId
    $('#dial').html(entryArray).prop('folderId', folderId)
    alignVertical()

    # Show the options gear icon only if enabled and doesn't already exist
    if localStorage.getItem('show_options_gear') != 'true'
      $('#options-link').hide()

    if localStorage.getItem('drag_and_drop') == 'true'
      $('#dial').sortable({ items: '.entry:not(#new-entry)' }).on 'sortupdate', () ->
        updateBookmarksOrder()
  )


@getThumbnailUrl = (bookmark) ->
  jsonUrl = JSON.parse(localStorage.getItem('custom_icon_data'))[bookmark.url]

  return jsonUrl if jsonUrl

  if localStorage.getItem('force_http') == 'true'
    bookmark.url = bookmark.url.replace('https', 'http')

  return localStorage.getItem('thumbnailing_service').replace('[URL]', bookmark.url)


@refreshImage = (entry, bookmark) ->
  bookmarkUrl = "custom_icon_data_#{bookmark.url}"
  imageUrl = null

  if localStorage.getItem(bookmarkUrl) == null
    imageUrl = getThumbnailUrl(bookmark)
  else
    imageUrl = localStorage.getItem(bookmarkUrl)

  entry.find('.bookmark__image').css('background-image', 'url(' + imageUrl + ')')


# Figures out how big the dial and its elements should be
# Needs to be called before the entries are inserted
@setDialStyles = () ->
  dialColumns = localStorage.getItem('dial_columns')
  dialWidth = localStorage.getItem('dial_width')
  folderColor = localStorage.getItem('folder_color')
  adjustedDialWidth = window.innerWidth * dialWidth * 0.01
  minEntryWidth = 120
  entryWidth = adjustedDialWidth / dialColumns

  if entryWidth < minEntryWidth
    entryWidth = minEntryWidth

  # Set the values through CSS, rather than explicit individual CSS styles
  # Height values are 3/4 or * 0.75 width values
  $('#styles').html(
    '#dial { width:' + (adjustedDialWidth || 0) + 'px; } ' +
    '.entry { height:' + (entryWidth * 0.75 + 25 || 0) + 'px; width:' + (entryWidth || 0) + 'px; } ' +
    '.fa-folder { font-size:' + (entryWidth * 0.5 || 0) + 'px; top:' + (entryWidth * 0.05 || 0) + 'px; color:' + folderColor + ' } ' +
    '.fa-plus { font-size:' + (entryWidth * 0.3 || 0) + 'px; top:' + (entryWidth * 0.18 || 0) + 'px; } '
  )


@showBookmarkEntryForm = (heading, title, url, target) ->
  form = $('#bookmark-form')

  form.find('h1').html(heading)
  form.find('.title').prop('value', title)
  # Must || '' .url and .icon fields when using .prop() to clear previously set input values
  form.find('.url').prop('value', url || '')
  form.find('.icon').prop('value', JSON.parse(localStorage.getItem('custom_icon_data'))[url] || '')
  form.prop('target', target)

  # Selectors to hide URL & custom icon fields when editing a folder name
  if form.find('h1').text().indexOf('Edit Folder') > -1
    form.find('p').eq(1).hide()
    form.find('p').eq(2).hide()

  # Selectors to hide the cusom icon field when adding a new entry
  if form.find('h1').text().indexOf('New') > -1
    form.find('p').eq(2).hide()

  form.reveal()
  form.find('.title').focus()
  form.on 'reveal:close', () ->
    form.find('p').show()


@updateCustomIcon = (url, oldUrl) ->
  iconObject = JSON.parse(localStorage.getItem('custom_icon_data'))
  iconUrl = $('#bookmark-form .icon').prop('value').trim()

  iconObject[url] = iconUrl

  # Makes sure thumbnail URL changes along with the bookmark
  if url != oldUrl
    delete iconObject[oldUrl]

  # Cleans out any empty entries from localStorage
  if iconUrl.length == 0 || url.trim().length == 0
    delete iconObject[url]
    delete iconObject[oldUrl]

  localStorage.setItem('custom_icon_data', JSON.stringify(iconObject))

  if localStorage.getItem('enable_sync') == 'true'
    syncToStorage()

  createSpeedDial(getStartingFolder())


document.addEventListener 'DOMContentLoaded', () ->
  initialize()
  createSpeedDial(getStartingFolder())

  $('#bookmark-form .title, #bookmark-form .url, #bookmark-form .icon').on 'keydown', (e) ->
    if e.which == 13  # 13 is the character code of the return key
      $('#bookmark-form button').trigger('click')

  $('#bookmark-form button').on 'click', (e) ->
    target = $('#bookmark-form').prop('target')
    title = $('#bookmark-form .title').prop('value').trim()
    url = $('#bookmark-form .url').prop('value').trim()

    if target == 'new-entry'
      addBookmark(title, url)
    else
      updateBookmark(target, title, url)

  # Navigates to the entry corresponding to the single digit number between 1-9
  $(document.body).on 'keypress', (e) ->
    # Prevents navigation while typing numbers in #bookmark-form input fields
    if document.activeElement.type != 'text'
      key = String.fromCharCode(e.which)

      if key >= 1 && key <= 9 && $('.bookmark').eq(key - 1).length > 0
        window.location = $('.bookmark').get(key - 1).href

  $(window).on 'resize', () ->
    setDialStyles()
    alignVertical()

  # Change the current dial if the page hash changes
  $(window).on 'hashchange', () ->
    createSpeedDial(getStartingFolder())
