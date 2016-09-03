Steedos.subsDashboard = new SubsManager();

Tracker.autorun (c)->
	if Session.get("spaceId")
		Steedos.subsDashboard.subscribe "portal_dashboards", Session.get("spaceId")
	if Session.get("dashboardId")
		Steedos.subsDashboard.clear()
		Steedos.subsDashboard.subscribe "portal_dashboard", Session.get("dashboardId")   
		# Steedos.subsDashboard.subscribe "portal_widgets", Session.get("dashboardId")
	if Session.get("widgetId")     
		Steedos.subsDashboard.subscribe "portal_widget", Session.get("widgetId")  


