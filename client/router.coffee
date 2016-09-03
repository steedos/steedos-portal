checkUserSigned = (context, redirect) ->
	if !Meteor.userId()
		FlowRouter.go '/steedos/sign-in';

FlowRouter.route '/portal/admin', 
    action: (params, queryParams)->
        if Meteor.userId()
            BlazeLayout.render 'masterLayout',
                main: "portal_admin_home"

# FlowRouter.route '/portal/admin/dashboards', 
#     action: (params, queryParams)->
#         if Meteor.userId()
#             BlazeLayout.render 'masterLayout',
#                 main: "portal_admin_dashboards"