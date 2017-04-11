Template.portal_home.helpers Portal.helpers


Template.portal_home.onRendered ->
	Tracker.afterFlush ->
		$("body").addClass("sidebar-collapse")

Template.portal_home.events ->