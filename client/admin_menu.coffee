# if Meteor.isClient

# 	Portal菜单暂时先放到FSSH包中，以后需要公开时再放开（要同时把FSSH中相关菜单移除）
# 	# 门户
# 	Admin.addMenu 
# 		_id: "portal"
# 		title: "Steedos Portal"
# 		icon: "ion ion-ios-albums-outline"
# 		app: "portal"
# 		sort: 40

# 	# 面板
# 	Admin.addMenu 
# 		_id: "portal_dashboards"
# 		title: "portal_dashboards"
# 		icon:"ion ion-ios-photos"
# 		url: "/admin/view/portal_dashboards"
# 		roles:["space_admin"]
# 		sort: 10
# 		parent: "portal"