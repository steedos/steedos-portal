Template.portal_home.helpers Portal.helpers


Template.portal_home.onRendered ->
	Tracker.afterFlush ->
		$("body").addClass("sidebar-collapse")
	
	iframeGzptHidden = $("#rfiam-gzpt-iframe-hidden")

	iframeGzptHidden.load () ->
		if !Steedos.isNode()
			return;
		
		Portal.helpers.iframeGzptReload('rfiam-gzpt-iframe-hidden');
		console.log('------------rfiam-gzpt-iframe-hidden load----------------');

Template.portal_home.events ->