'use strict'


# Repopulate form with previously selected options
@restoreOptions = () ->
	$('#background_color').prop('value', localStorage.getItem('background_color'))
	$('#custom_icon_data').prop('value', localStorage.getItem('custom_icon_data'))
	$('#center_vertically').prop('checked', localStorage.getItem('center_vertically') == 'true')
	$('#folder_list').prop('value', localStorage.getItem('default_folder_id'))
	$('#dial_columns').prop('value', localStorage.getItem('dial_columns'))
	$('#dial_width').prop('value', localStorage.getItem('dial_width'))
	$('#drag_and_drop').prop('checked', localStorage.getItem('drag_and_drop') == 'true')
	$('#enable_sync').prop('checked', localStorage.getItem('enable_sync') == 'true')
	$('#folder_color').prop('value', localStorage.getItem('folder_color'))
	$('#force_http').prop('checked', localStorage.getItem('force_http') == 'true')
	$('#show_advanced').prop('checked', localStorage.getItem('show_advanced') == 'true')
	$('#show_folder_list').prop('checked', localStorage.getItem('show_folder_list') == 'true')
	$('#show_new_entry').prop('checked', localStorage.getItem('show_new_entry') == 'true')
	$('#show_options_gear').prop('checked', localStorage.getItem('show_options_gear') == 'true')
	$('#show_subfolder_icons').prop('checked', localStorage.getItem('show_subfolder_icons') == 'true')
	$('#thumbnailing_service').prop('value', localStorage.getItem('thumbnailing_service'))


# Write selected options back to local storage
saveOptions = () ->
	localStorage.setItem('background_color', $('#background_color').prop('value'))
	localStorage.setItem('custom_icon_data', JSON.stringify(JSON.parse($('#custom_icon_data').prop('value'))))
	localStorage.setItem('center_vertically', $('#center_vertically').prop('checked'))
	localStorage.setItem('default_folder_id', $('#folder_list').prop('value'))
	localStorage.setItem('dial_columns', $('#dial_columns').prop('value'))
	localStorage.setItem('dial_width', $('#dial_width').prop('value'))
	localStorage.setItem('drag_and_drop', $('#drag_and_drop').prop('checked'))
	localStorage.setItem('enable_sync', $('#enable_sync').prop('checked'))
	localStorage.setItem('folder_color', $('#folder_color').prop('value'))
	localStorage.setItem('force_http', $('#force_http').prop('checked'))
	localStorage.setItem('show_advanced', $('#show_advanced').prop('checked'))
	localStorage.setItem('show_folder_list', $('#show_folder_list').prop('checked'))
	localStorage.setItem('show_new_entry', $('#show_new_entry').prop('checked'))
	localStorage.setItem('show_options_gear', $('#show_options_gear').prop('checked'))
	localStorage.setItem('show_subfolder_icons', $('#show_subfolder_icons').prop('checked'))
	localStorage.setItem('thumbnailing_service', $('#thumbnailing_service').prop('value'))

	if localStorage.getItem('enable_sync') == 'true'
		syncToStorage()

	window.location = '/views/newtab.html'


document.addEventListener 'DOMContentLoaded', () ->
	initialize()
	restoreOptions()

	$('#save').on 'click', () ->
		try  # Just validate and make sure everything is good to save
			JSON.parse($('#custom_icon_data').prop('value'))
			saveOptions()
		catch e
			alert('The JSON you entered is not valid, try again.\nThe error message was: ' + e)

	$('#cancel').on 'click', () ->
		window.location = '/views/newtab.html'

	# If the Esc key is pressed go back to the new tab page
	$(document.body).on 'keyup', (e) ->
		if e.which == 27   # 27 is the character code of the escape key
			window.location = '/views/newtab.html'

	$('#background_color').on 'change', () ->
		document.body.style.backgroundColor = $('#background_color').prop('value')

	$('#enable_sync').on 'click', () ->
		if this.checked
			chrome.storage.sync.getBytesInUse(null, (bytes) ->
				if bytes > 0 && confirm('You have previously synchronized data!!\nDo you want to overwrite your current local settings with your previously saved remote settings?')
						restoreFromSync()
			)

	if localStorage.getItem('show_advanced') == 'false'
		$('#advanced').hide()

	$('#show_advanced').on 'click', () ->
		if this.checked
			$('#advanced').show()
		else
			$('#advanced').hide()

	$('#custom_icon_data').on 'keydown', (e) ->
		if e.which == 13  # 13 is the character code of the return key
			$('#save').trigger('click')

	$('#reset_local_settings').on 'click', () ->
		if confirm('Are you sure you want to reset all local values you have changed back to their defaults?')
			localStorage.clear()
			createDefaults()
			window.location.reload()

	$('#reset_synced_settings').on 'click', () ->
		if confirm('Are you sure you want to delete all previously synchronized data to start fresh?')
			chrome.storage.sync.clear()
