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
        return Portal.autoCompileTemplate.compiledFreeboard dashboardId,freeboard,true

# 自动编译widget方法集
Portal.autoCompileTemplate =
    timeoutTag:null
    datasources:{}
    proxyurl:"https://thingproxy.freeboard.io/fetch/"
    compiledFreeboard: (dashboardId,freeboard,isFirstTime)->
        unless dashboardId
            return ""
        if isFirstTime
            #declare a global variable named dashboardId in datasources so we can fetch the correct datasources later
            @datasources[dashboardId] = {}
            Meteor.clearTimeout @timeoutTag
            @loadAllDatasource dashboardId,freeboard
            @loadDatasourceByTime dashboardId,freeboard
            return ""
        else
            compiledFreeboardHtml = @getCompiledFreeboardHtml dashboardId,freeboard,isFirstTime
            contentBox = $ "#freeboard-panes-#{dashboardId}"
            contentBox.empty();
            contentBox.append compiledFreeboardHtml
    getCompiledFreeboardHtml: (dashboardId,freeboard,isFirstTime)->
        try
            unless dashboardId
                return ""
            if typeof freeboard == "string"
                freeboard = JSON.parse freeboard
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
                            widgetClassname = "widget-content"
                            if isFirstTime
                                tempWidgetHtml = "<div class = \"#{widgetClassname}\"></div>"
                            else
                                # 这里执行的是一个传入datasources参数的闭包函数，用来避免变量污染
                                evalFunString = "(function(datasources){#{html}})(#{JSON.stringify Portal.autoCompileTemplate.datasources[dashboardId]})"
                                try
                                    widgetContentHtml = eval(evalFunString)
                                catch e
                                    # just show the error when catch error
                                    widgetClassname += " text-danger"
                                    widgetContentHtml = "#{pane.title} #{t("portal_freeboard_compiling_error")}:<br/>"
                                    widgetContentHtml += "#{e.message}<br/>#{e.stack}"
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
            console.log("trying to loadAllDatasource for dashboardId:#{dashboardId}");
            Meteor.clearTimeout @timeoutTag
            unless dashboardId
                return ""
            if typeof freeboard == "string"
                freeboard = JSON.parse freeboard
            if freeboard.datasources?.length
                freeboard.datasources.forEach (datasource) ->
                    settings = datasource.settings
                    # only when the datasource.settings has name,method,url property at least then try to load it
                    unless settings && settings.name && settings.method && settings.url
                        return
                    headers = settings.headers
                    $.ajax
                        type: settings.method
                        async: false,
                        url: "#{Portal.autoCompileTemplate.proxyurl}#{settings.url}"
                        beforeSend: (XHR) ->
                            if headers?.length
                                headers.forEach (header) ->
                                    XHR.setRequestHeader header.name, header.value
                        success: (result) ->
                            Portal.autoCompileTemplate.datasources[dashboardId][settings.name] = result
            # try to compile freeboard's js code and show the compiled html after all of the freeboard.datasources is loaded
            @compiledFreeboard dashboardId,freeboard,false

        catch e
            console.log 'loadAllDatasource faild'
        finally
            Portal.autoCompileTemplate.loadDatasourceByTime dashboardId,freeboard
    loadDatasourceByTime: (dashboardId,freeboard)->
        # get refresh property from freeboard,if nothing then apply the defalut refresh as 5 minute
        refresh = if freeboard?.refresh then freeboard.refresh else 300
        refresh = refresh*1000
        #启动定时器定时抓取数据源
        @timeoutTag = Meteor.setTimeout (->
            Portal.autoCompileTemplate.loadAllDatasource dashboardId,freeboard
        ), refresh
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
    # autoCompileByTime: ->
    #     #启动定时器定时抓取数据源
    #     @timeoutTag = Meteor.setTimeout @autoCompile, 3000
    # autoCompile: ->
    #     Meteor.clearTimeout @timeoutTag
    #     widgets = Portal.helpers.Widgets();
    #     widgets.forEach (widget) ->
    #         source = widget.template
    #         data = widget.data
    #         if source&&data
    #             result = Portal.autoCompileTemplate.getCompiledResult source,data
    #             id = widget._id
    #             contentBox = $("#portal-widget-#{id}-content")
    #             contentBox.empty()
    #             contentBox.append(result);

    #     Portal.autoCompileTemplate.autoCompileByTime()




