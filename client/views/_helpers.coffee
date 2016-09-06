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
            if dashboard.widgets
                return db.portal_widgets.find({_id: {$in: dashboard.widgets}}).fetch()
            else
                return []
        else
            return []



Portal.autoCompileTemplate =
    timeoutTag:null,
    getCompiledResult: (source,data)->
        template = Handlebars.compile(source);
        return template(data);
    autoCompile: ->

        widgets = Portal.helpers.Widgets();
        self = this;
        widgets.forEach (widget) =>
            debugger;
            source = widget.template
            data = widget.data
            if source&&data
                result = self.getCompiledResult source,data
                id = widget._id
                contentBox = $("#portal-widget-#{id}-content")
                contentBox.empty()
                contentBox.append(result);


        # Meteor.setTimeout((->
        #     console.log '====123'

        # ), 3000)




