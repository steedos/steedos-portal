Portal = 
	GetAuthByName: (auth_name) ->
		user = Meteor.userId()
		return db.apps_auth_users.findOne({user:user,auth_name:auth_name})

Portal.Datasources = {}
