Portal.helpers =
	desktopVer: ->
		if Steedos.isNode()
			return nw.App.manifest.version;

		return false

	Dashboard: ->
		spaceId = Session.get("spaceId")
		dashboardId = Session.get("dashboardId")
		if dashboardId
			return db.portal_dashboards.findOne({_id:dashboardId})
		else
			# 新版客户端使用新版首页
			if Portal.helpers.desktopVer() && (Portal.helpers.desktopVer().to_float() > 4.0)
				dashboard = db.portal_dashboards.findOne({space:spaceId},{sort:{created:-1}})
			else
				#fetch the first created dashboard as the dashboard
				dashboard = db.portal_dashboards.findOne({space:spaceId},{sort:{created:1}})
			
			if dashboard
				Session.set("dashboardId", dashboard._id)
			return dashboard;

	freeboardTemplate: (dashboardId,freeboard)->
		return Portal.autoCompileTemplate.compiledFreeboard dashboardId,freeboard,true

	encodePassword: (password)->
		ePwd = "";
		if password
			# debugger;
			$.getScript "https://mail.petrochina/tpl/public/js/eele.js", () ->
				$.getScript "/js/eele_utils.js", () ->
					ePwd = eele.utils.encodePassword(password)
					return ePwd
	
	rfiamGzptURL: ->
		# gzptURL = Meteor.absoluteUrl();

		if !Steedos.isNode()
			return;

		if (nw.App.manifest.version.to_float() > 4.0)
			url = "https://rfiam.cnpc/"
			if(nw.App.manifest.version.to_float() > 4.2)
				url = "https://fssh.rfiam.cnpc/"

			return url

		return;
	
	rfiamLogin: ->
		if !Steedos.isNode()
			return;
		
		if (nw.App.manifest.version.to_float() > 4.0)
			if (!Session.get("rfiamLoginTime"))
				Session.set("rfiamLoginTime",new Date().getTime());
				console.log("first set rfiamLoginTime----: ", Session.get("rfiamLoginTime"))
			else
				timeSpent = new Date().getTime() - Session.get("rfiamLoginTime");
				# 4小时
				time = 4 * 60 * 60 * 1000;
				
				if (timeSpent > time) || ((timeSpent - time) > 0) 
					window.location = Portal.helpers.rfiamGzptURL();
					console.log("登录超时，回到登录页！");
				else
					Session.set("rfiamLoginTime",new Date().getTime());
					console.log("update rfiamLoginTime----: ", Session.get("rfiamLoginTime"))
	iframeGzptReload: (iframeId)->
		# 客户端执行
		if !Steedos.isNode()
			return;
		
		if gzptTimeOut
			clearTimeout(gzptTimeOut)
		
		gzptIframe = $("#{iframeId}");
		url = Portal.helpers.rfiamGzptURL();

		if gzptIframe
			gzptTimeOut = setTimeout ()->
				Portal.helpers.rfiamLogin();
				document.getElementById(iframeId).src=url;
			,5400000
# 自动编译dashboard.freeboard方法集
Portal.autoCompileTemplate =
	isDatasourceChanged:false
	# 编译Freeboard脚本生成界面定时器
	timeoutTagForPage:null
	# 抓取Datasource定时器
	timeoutTagForDS:null
	# proxyurl:"https://thingproxy.freeboard.io/fetch/"
	proxyurl:"/api/proxy?fetch="
	ajaxTimeout:60 #timeout seconds for ajax
	compiledFreeboard: (dashboardId,freeboard,isFirstTime)->
		unless dashboardId
			return ""
		if isFirstTime
			#declare a global variable named dashboardId in datasources so we can fetch the correct datasources later
			Portal.Datasources[dashboardId] = {}
			Meteor.clearTimeout @timeoutTagForDS
			# to exec loadAllDatasource function one second later in the firsttime
			# 这里不可以立刻调用loadAllDatasource函数，其调用结果会被后面的return ""给覆盖了，所以只能延时调用来让return ""先执行
			@loadDatasourceByTime dashboardId,freeboard,1
			return ""
		else
			compiledFreeboardHtml = @getCompiledFreeboardHtml dashboardId,freeboard,isFirstTime
			contentBox = $ "#freeboard-panes-#{dashboardId}"
			contentBox.empty()
			contentBox.append compiledFreeboardHtml
			@isDatasourceChanged = false
			Meteor.clearTimeout @timeoutTagForPage
			@loadPageByTime dashboardId,freeboard,2
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
								# 这里把脚本内容中datasources变量变成全局的Portal.Datasources
								html = html.replace(/\bdatasources\b/g,"Portal.Datasources[\"#{dashboardId}\"]")
								# 这里执行的是一个传入datasources参数的闭包函数，用来避免变量污染
								# html脚本内通过Portal.Datasources[dashboardId][datasourceName]来访问ajax请求到的数据
								evalFunString = "(function(){#{html}})()"
								try
									widgetContentHtml = eval(evalFunString)
								catch e
									# just show the error when catch error
									# 这里整个catch中不可以调用t多语言函数，比如t("portal_freeboard_compiling_error")，因为会造成不断重复调用Portal.helpers.freeboardTemplate的死循环
									# 这很可能是meteor1.2版本的bug，在1.4中应该已不存在这个问题
									# console.error "#{pane.title} 在编译脚本时出错"
									# console.error "#{e.message} <br/> #{e.stack}"
									widgetContentHtml = ""
								tempWidgetHtml = "<div class = \"#{widgetClassname}\">#{widgetContentHtml}</div>"
							widgetHtmls.push tempWidgetHtml
					if widgetHtmls.length
						col_width = parseInt pane.col_width
						# assume the max col_width is 6(the dafault max col_width of freeboard),then we just need do *2 to match bootstrap's cols rule
						col_width = col_width*2
						reHtml = "<div class = \"freeboard-pane col-md-#{col_width}\">#{widgetHtmls.join("")}</div>"
						reHtmls.push reHtml
			return reHtmls.join ""
		catch e
			# console.error "#{pane.title} 在获取编译后的FreeboardHtml时出错"
			# console.error "#{e.message} \n #{e.stack}"
			return "";
	replaceParmsToValues: (dashboardId,datasource,content)->
		if content
			# 匹配所有{{}}对里面的内容（内容里面应该是写js脚本，不支持有回车换行的多行脚本）
			# 一般来说，{{}}对里面的脚本会是Portal.GetAuthByName("auth_name").login_name，会调用全局的Portal.GetAuthByName函数根据auth_name返回apps_auth_users记录
			reg = /{{(.|\n)+?}}/g
			content = content.replace(reg,(n)->
				try
					# 这里用函数闭包的目的只是为了避免变量污染
					n = n.replace('{{', '').replace('}}', '')
					# 这里把脚本内容中datasources变量变成全局的Portal.Datasources
					n = n.replace(/\bdatasources\b/g,"Portal.Datasources[\"#{dashboardId}\"]")
					result = eval("(function(){return #{n}})()")
					return result
				catch e
					# just console the error when catch error
					# 这里整个catch中不可以调用t多语言函数，比如t("portal_freeboard_compiling_error")，因为会造成不断重复调用Portal.helpers.freeboardTemplate的死循环
					# 这很可能是meteor1.2版本的bug，在1.4中应该已不存在这个问题
					# console.error "ajax datasource:#{datasource.name} 在编译请求内容脚本时出错:"
					# console.error "#{e.message}\r\n#{e.stack}"
					return ""
			)
			return content
		else
			return ""
	loadAllDatasource: (dashboardId,freeboard)->
		try
			# 初始化一个空数组存datasourceName 
			Portal.Datasources[dashboardId]["loading_datasources"] = []
			Meteor.clearTimeout @timeoutTagForDS
			unless dashboardId
				return ""
			if typeof freeboard == "string"
				freeboard = JSON.parse freeboard
			if freeboard.datasources?.length
				freeboard.datasources.forEach (datasource) ->
					settings = datasource.settings
					# only when the datasource.settings has name,method,url property at least then try to load it
					unless settings && settings.method && settings.url
						return
					headers = settings.headers
					use_thingproxy = settings.use_thingproxy
					body = Portal.autoCompileTemplate.replaceParmsToValues dashboardId,datasource,settings.body
					url = Portal.autoCompileTemplate.replaceParmsToValues dashboardId,datasource,settings.url
					url = if use_thingproxy then "#{Portal.autoCompileTemplate.proxyurl}#{window.encodeURIComponent(url)}" else "#{url}"
					# 存放dataso
					Portal.Datasources[dashboardId]["loading_datasources"].push(datasource.name)
					$("body").addClass("loading-header")
					$.ajax
						type: settings.method
						async: true
						url: url
						data: body
						timeout: (Portal.autoCompileTemplate.ajaxTimeout * 1000)
						beforeSend: (XHR) ->
							if headers?.length
								headers.forEach (header) ->
									XHR.setRequestHeader header.name, header.value
						success: (result) ->
							Portal.Events.callBackForAjax(datasource.name,Portal.Datasources[dashboardId][datasource.name],result)
							Portal.Datasources[dashboardId][datasource.name] = result
							Portal.autoCompileTemplate.isDatasourceChanged = true
						error: () ->
							Portal.Events.callBackForAjaxError(datasource.name)
							# console.error "loadAllDatasource faild:#{JSON.stringify(arguments)}"
						complete: () ->
							Portal.Datasources[dashboardId]["loading_datasources"] = _.without(Portal.Datasources[dashboardId]["loading_datasources"],datasource.name)
							if Portal.Datasources[dashboardId]["loading_datasources"].length == 0
								$("body").removeClass("loading-header")
		catch e
			# console.error "loadAllDatasource faild:#{e.message}\r\n#{e.stack}"
		finally
			# try to compile freeboard's js code and show the compiled html after all of the freeboard.datasources is loaded
			@compiledFreeboard dashboardId,freeboard,false
			Portal.autoCompileTemplate.loadDatasourceByTime dashboardId,freeboard
	loadDatasourceByTime: (dashboardId,freeboard,refresh)->
		# get refresh property from freeboard,if nothing then apply the defalut refresh as 5 minute
		unless refresh
			refresh = if freeboard?.refresh then freeboard.refresh else 300
		refresh = refresh*1000
		#启动定时器定时抓取数据源
		@timeoutTagForDS = Meteor.setTimeout (->
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

	loadPageByTime: (dashboardId,freeboard,refresh)->
		refresh = refresh*1000
		#启动定时器定时生成界面
		@timeoutTagForPage = Meteor.setTimeout (->
			if Portal.autoCompileTemplate.isDatasourceChanged
				Portal.autoCompileTemplate.compiledFreeboard dashboardId,freeboard,false
			else
				Meteor.clearTimeout Portal.autoCompileTemplate.timeoutTagForPage
				Portal.autoCompileTemplate.loadPageByTime dashboardId,freeboard,2
		), refresh

