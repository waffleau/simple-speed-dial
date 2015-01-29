'use strict';


@getStartingFolder = () ->
  if window.location.hash.length > 0
    return window.location.hash.substring(1)
  else
    return localStorage.getItem('default_folder_id')

# Generates a list of all folders under chrome bookmarks
@generateFolderList = () ->
  if localStorage.getItem('show_folder_list') == 'true' || window.location.pathname == '/options.html'

    chrome.bookmarks.getTree (rootNode) ->
      folderList = []
      openList = []

      # Never more than 2 root nodes, push both Bookmarks Bar & Other Bookmarks into array
      openList.push(rootNode[0].children[0])
      openList.push(rootNode[0].children[1])

      while (node = openList.pop())?
        if node.children?
          if node.parentId == '0'
            node.path = '' # Root elements have no parent so we shouldn't show their path

          node.path += node.title;

          while (child = node.children.pop())?
            if child.children?
              child.path = node.path + '/'
              openList.push(child)


          folderList.push(node)

      folderList.sort (a, b) -> a.path.localeCompare(b.path)

      folderListHtml = $('<select id="folder-list" class="folder-list form-control"></select>')

      folderList.forEach (item) ->
        folderListHtml.append(new Option(item.path, item.id))

      $('#folder').html(folderListHtml)

      $('#folder_list').prop('value', getStartingFolder()).on 'change', () ->
        window.location.hash = $('#folder_list').prop('value')


# Create default localStorage values if they don't already exist
@createDefaults = () ->
  defaultValues = {
    'background_color' : '#cccccc',
    'custom_icon_data' : '{}',
    'center_vertically' : 'true',
    'default_folder_id' : '1',
    'dial_columns' : '6',
    'dial_width' : '70',
    'drag_and_drop' : 'true',
    'enable_sync' : 'false',
    'folder_color' : '#888888',
    'force_http' : 'true',
    'show_advanced' : 'false',
    'show_folder_list' : 'true',
    'show_new_entry' : 'true',
    'show_options_gear' : 'true',
    'show_subfolder_icons' : 'true',
    'thumbnailing_service' : 'http://api.webthumbnail.org/?width=500&height=400&screen=1280&url=[URL]'
  }

  # Creates default localStorage values if they don't already exist
  for name, value of defaultValues
    if !localStorage.getItem(name)? || localStorage.getItem(name) == "undefined"
      localStorage.setItem(name, value)


# Initialisation routines for all pages
@initialize = () ->
  createDefaults()
  document.body.style.backgroundColor = localStorage.getItem('background_color')
  generateFolderList()
