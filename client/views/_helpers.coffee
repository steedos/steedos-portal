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

    widgetTemplate: (id,source,data)->
        # 这里因为定时抓取数据源编译那块可能先append了结果，所以这里需要每次变更时先清空标签内容，以防止出现用户看到两个重复widget界面的情况
        contentBox = $("#portal-widget-#{id}-content")
        contentBox.empty()
        return Portal.autoCompileTemplate.getCompiledResult source,data

    freeboardTemplate: (dashboardId,freeboard)->
        return Portal.autoCompileTemplate.compiledFreeboard dashboardId,freeboard

# 自动编译widget方法集
Portal.autoCompileTemplate =
    timeoutTag:null,
    datasources:{}
    compiledFreeboard: (dashboardId,freeboard,isFirstTime)->
        unless dashboardId
            return ""
        debugger
        if isFirstTime
            @loadAllDatasource dashboardId,freeboard
            @loadDatasourceByTime dashboardId,freeboard
            return @getCompiledFreeboardHtml dashboardId,freeboard,isFirstTime
        else
            compiledFreeboard = @getCompiledFreeboardHtml dashboardId,freeboard,isFirstTime
            context = $ "#freeboard-panes-#{dashboardId}"
            context.empty();
            context.append compiledFreeboard
    getCompiledFreeboardHtml: (dashboardId,freeboard,isFirstTime)->
        try
            unless dashboardId
                return ""
            debugger
            freeboard = JSON.parse(freeboard)
            reHtmls = []
            if freeboard.panes?.length
                freeboard.panes.forEach (pane) ->
                    widgetHtmls =[]
                    if pane.widgets?.length
                        # find widgets that contains settings.html children node only
                        activeWidgets = pane.widgets.filter (n)->
                            return n.settings?.html
                        activeWidgets.forEach (activeWidget) ->
                            html = activeWidget.settings.html
                            datasourceNames = Portal.autoCompileTemplate.getDatasourceNamesFromHtml html
                            if datasourceNames?.length
                                widgetClassname = datasourceNames.join(" ")
                                if isFirstTime
                                    tempWidgetHtml = "<div class = \"#{widgetClassname}\"></div>"
                                else
                                    # 这里执行的是一个闭包函数，用来避免变量污染
                                    widgetContentHtml = eval("(function(datasources){return #{html}})(#{Portal.autoCompileTemplate.datasources[dashboardId]})")
                                    tempWidgetHtml = "<div class = \"#{widgetClassname}\">#{widgetContentHtml}</div>"
                            else
                                widgetClassname = "no-datasource-widget"
                                # 这里执行的是一个闭包函数，用来避免变量污染
                                widgetContentHtml = eval("(function(){return #{html}})()")
                                tempWidgetHtml = "<div class = \"#{widgetClassname}\">#{widgetContentHtml}</div>"
                            widgetHtmls.push tempWidgetHtml
                    if widgetHtmls.length
                        reHtml = "<div clsss = \"freeboard-pane col-md-#{pane.col_width}\">#{widgetHtmls.join("")}</div>"
                        reHtmls.push reHtml
            return reHtmls.join ""
        catch e
            return ""
    loadAllDatasource: (dashboardId,freeboard)->
        try
            unless dashboardId
                return ""
            debugger
            freeboard = JSON.parse(freeboard)
            if freeboard.datasources?.length
                freeboard.datasources.forEach (datasource) ->
                    settings = datasource.settings
                    # only when the datasource.settings has name,method,refresh,url property at least then try to load it
                    unless settings && settings.name && settings.method && settings.refresh && settings.url
                        return
                    $.ajax
                        type: settings.method
                        url: settings.url
                        success: (result) ->
                            debugger
                            Portal.autoCompileTemplate.datasources[dashboardId][settings.name] = result
                            Portal.autoCompileTemplate.compiledFreeboard dashboardId,freeboard,false

        catch e
            console.log 'loadAllDatasource faild'
    loadDatasourceByTime: (dashboardId,freeboard)->
        debugger
    getDatasourceNamesFromHtml: (html)->
        # fetch datasources string as array from html,just like ["datasources["hotoa_pending_list"],datasources["hotoa_completed_list"]"]
        datasources = html.match(/datasources\[\"([^\r\n]+)\"\]/g)
        if datasources
            datasourceNames = datasources.map (n) ->
                # fetch datasources key name，just like fetch hotoa_pending_list from datasources["hotoa_pending_list"] then add "widget-datasource-" for prefix
                return "widget-datasource-" + n.match(/\"[^\r\n]+\"/)[0].replace /\"/g, ''
        else
            datasourceNames = []
        return _.uniq datasourceNames
    getCompiledResult: (source,data)->
        try
            return Spacebars.toHTML(eval(data),source)
        catch e
            return ""
    autoCompileByTime: ->
        #启动定时器定时抓取数据源
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




