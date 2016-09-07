Portal.helpers =

    Dashboard: ->
        spaceId = Session.get("spaceId")
        dashboardId = Session.get("dashboardId")
        if dashboardId
            return db.portal_dashboards.findOne({_id:dashboardId})
        else
            #fetch the first created dashboard as the dashboard
            dashboard = db.portal_dashboards.findOne({space:spaceId},{sort:{created:1}})
            if dashboard
                Session.set("dashboardId", dashboard._id)
            return dashboard;
    Widgets: ->
        dashboardId = Session.get("dashboardId")
        if dashboardId
            dashboard = db.portal_dashboards.findOne({_id:dashboardId})
            if dashboard?.widgets
                return db.portal_widgets.find({_id: {$in: dashboard.widgets}}).fetch()
            else
                return []
        else
            return []

    widgetTemplate: (source,data)->
        return Portal.autoCompileTemplate.getCompiledResult source,data


Portal.autoCompileTemplate =
    timeoutTag:null,
    getCompiledResult: (source,data)->
        try
            return Spacebars.toHTML(eval(data),source)
        catch e
            return ""
    autoCompileByTime: ->
        @timeoutTag = Meteor.setTimeout @autoCompile, 3000
    autoCompile: ->
        Meteor.clearTimeout @timeoutTag
        widgets = Portal.helpers.Widgets();
        widgets.forEach (widget) ->
            source = widget.template
            data = widget.data
            if source&&data
                result = Portal.autoCompileTemplate.getCompiledResult source,data
                id = widget._id
                contentBox = $("#portal-widget-#{id}-content")
                contentBox.empty()
                contentBox.append(result);

        Portal.autoCompileTemplate.autoCompileByTime()




