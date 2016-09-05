Template.portal_home.helpers 
    Dashboard: ->
        dashboardId = Session.get("dashboardId")
        if dashboardId
            return db.portal_dashboards.findOne({_id:dashboardId})
        else
            return null
    Widgets: ->
        return []

Template.portal_home.onRendered ->


Template.portal_home.events ->