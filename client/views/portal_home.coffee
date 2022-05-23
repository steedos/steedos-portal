Template.portal_home.helpers Portal.helpers


Template.portal_home.onRendered ->
	Tracker.afterFlush ->
		$("body").addClass("sidebar-collapse")
	
	# iframeGzptHidden = $("#rfiam-gzpt-iframe-hidden")

	# iframeGzptHidden.load () ->
	# 	if !Steedos.isNode()
	# 		return;
		
	# 	Portal.helpers.iframeGzptReload('rfiam-gzpt-iframe-hidden');
		
	# 	# 设置第一次登录后的时间
	# 	Portal.helpers.rfiamLogin();
		
	# 	console.log('------------rfiam-gzpt-iframe-hidden load----------------');
	
	# 设置第一次登录后的时间
	Portal.helpers.rfiamLogin();

Template.portal_home.events ->