Steedos.subsPortal = new SubsManager();

Tracker.autorun (c)->
	if Session.get("spaceId")
		Steedos.subsPortal.subscribe "portal_dashboards", Session.get("spaceId")
		Steedos.subsPortal.subscribe "portal_widgets", Session.get("spaceId")


