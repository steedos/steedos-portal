checkUserSigned = (context, redirect) ->
	if !Meteor.userId()
		FlowRouter.go '/steedos/sign-in';

portalRoutes = FlowRouter.group
	triggersEnter: [ checkUserSigned ],
	prefix: '/portal',
	name: 'portalRoutes'


portalRoutes.route '/',
	action: (params, queryParams)->
		FlowRouter.go "/portal/home"
		$("body").addClass("sidebar-collapse")


portalRoutes.route '/home',
	action: (params, queryParams)->
		$("body").addClass("sidebar-collapse")
		if Meteor.userId()
			BlazeLayout.render 'masterLayout',
				main: "portal_home"

	triggersExit:[(context, redirect) ->
		console.log "portal home exiting"
		Meteor.clearTimeout Portal.autoCompileTemplate.timeoutTag
	]


