checkUserSigned = (context, redirect) ->
	if !Meteor.userId()
		FlowRouter.go '/steedos/sign-in';

FlowRouter.route '/portal/admin', 
    action: (params, queryParams)->
        if Meteor.userId()
            BlazeLayout.render 'masterLayout',
                main: "portal_admin_home"

FlowRouter.route '/portal',
	action: (params, queryParams)->
		spaceId = Session.get("spaceId")
		dashboard = db.portal_dashboards.findOne({space:spaceId})
		if dashboard
			Session.set("dashboardId", dashboard._id)
		BlazeLayout.render 'masterLayout',
				main: "portal_home"