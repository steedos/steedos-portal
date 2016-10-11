checkUserSigned = (context, redirect) ->
	if !Meteor.userId()
		FlowRouter.go '/steedos/sign-in';

FlowRouter.route '/app/portal/admin', 
    action: (params, queryParams)->
        if Meteor.userId()
            BlazeLayout.render 'masterLayout',
                main: "portal_admin_home"

FlowRouter.route '/app/portal',
	action: (params, queryParams)->
		BlazeLayout.render 'masterLayout',
			main: "portal_home"