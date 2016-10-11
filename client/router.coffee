checkUserSigned = (context, redirect) ->
	if !Meteor.userId()
		FlowRouter.go '/steedos/sign-in';

portalRoutes = FlowRouter.group
	prefix: '/app/portal',
	name: 'portalRoutes'

portalRoutes.route '/index',
	action: (params, queryParams)->
		if Meteor.userId()
			BlazeLayout.render 'masterLayout',
				main: "portal_home"

portalRoutes.route '/admin', 
	action: (params, queryParams)->
		if Meteor.userId()
			BlazeLayout.render 'masterLayout',
				main: "portal_admin_home"

