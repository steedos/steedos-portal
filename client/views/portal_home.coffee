Template.portal_home.helpers Portal.helpers


Template.portal_home.onRendered ->
	Tracker.afterFlush ->
		$("body").addClass("sidebar-collapse")
	
	iframeGzptHidden = $("#rfiam-gzpt-iframe-hidden")

	iframeGzptHidden.load () ->
		if !Steedos.isNode()
			return;
		
		Portal.helpers.iframeGzptReload('rfiam-gzpt-iframe-hidden');
		if (nw.App.manifest.version.to_float() > 4.0)
			# 设置第一次登录后的时间
			Session.set("rfiamLoginTime",new Date().getTime());
			console.log("set rfiamLoginTime----: ",Session.get("rfiamLoginTime"));
		
		console.log('------------rfiam-gzpt-iframe-hidden load----------------');

Template.portal_home.events ->