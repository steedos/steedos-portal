Portal = 
	GetAuthByName: (auth_name,space_id,user_id) ->
		space = if space_id then space_id else Session.get("spaceId")
		user = if user_id then user_id else Meteor.userId()
		return db.apps_auth_users.findOne({space:space,user:user,auth_name:auth_name})

	GetLoginAuths: (space_id,user_id) ->
		# 遍历当前用户在db.apps_auth_users中的数据，返回如下格式JSON对象，ptr/cnpc为域名。
		# ptr
		# 	login_name
		# 	login_password
		# cnpc
		# 	login_name
		# 	login_password
		auths = {}
		space = if space_id then space_id else Session.get("spaceId")
		user = if user_id then user_id else Meteor.userId()
		db.apps_auth_users.find({space:space,user:user}).forEach (n, i) ->
			if n.is_encrypted
				n.login_password = Steedos.decrypt(n.login_password, n.login_name, Portal.cryptIvForAuthUsers)
			auths[n.auth_name] = login_name: n.login_name,login_password: n.login_password
		return auths


# Portal Freeboard设置中datasources变量保存到全局变量Portal.Datasources中
# 语法为：Portal.Datasources["{{dashboard_id}}"]["{{datasources_name}}"]
# 例如：Portal.Datasources["7jqC9JWqmrG4azMR5"]["EXPENSE_CNPC_GetMyTask"]
Portal.Datasources = {}

# Portal Freeboard设置中的widget模板脚本里面允许定义事件，事件函数变量名保存到全局变量Portal.Events中
# 定义函数语法为：Portal.Events.on_click_fun=function(){...};Portal.Events.try_to_login=function(){...};...
# 绑定事件通常的写法为：<a href="..." onclick="Portal.Events.try_to_login()"></a>
Portal.Events = {
	callBackForAjax: () ->

	callBackForAjaxError: () ->
}

if Meteor.isClient

	# Portal在Steedos中的菜单
	Admin.addMenu 
		_id: "portal"
		title: "Steedos Portal"
		icon: "ion ion-ios-albums-outline"
		app: "portal"
		sort: 10

	Admin.addMenu 
		_id: "portal_dashboards"
		title: "portal_dashboards"
		icon:"ion ion-ios-photos"
		url: "/admin/view/portal_dashboards"
		roles:["space_admin"]
		sort: 20
		parent: "portal"

	Admin.addMenu 
		_id: "apps_auths"
		title: "apps_auths"
		icon:"ion ion-aperture"
		url: "/admin/view/apps_auths"
		roles:["space_admin"]
		sort: 30
		parent: "portal"

	Admin.addMenu 
		_id: "apps_auth_users"
		title: "apps_auth_users"
		icon:"ion ion-ios-personadd"
		url: "/admin/view/apps_auth_users"
		onclick: ->
			Modal.show("accounts_guide_modal")
			return false
		sort: 40
		parent: "portal"

	Admin.addMenu 
		_id: "mail_domains"
		title: "mail_domains"
		icon:"ion ion-ios-email"
		url: "/admin/view/mail_domains"
		roles:["cloud_admin"]
		sort: 50
		parent: "portal"