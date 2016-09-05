Steedos.subsDashboard = new SubsManager();

Tracker.autorun (c)->
	if Session.get("spaceId")
		Steedos.subsDashboard.subscribe "portal_dashboards", Session.get("spaceId")
		Steedos.subsDashboard.subscribe "portal_widgets", Session.get("spaceId")


