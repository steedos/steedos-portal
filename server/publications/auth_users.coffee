Meteor.publish 'apps_auth_users', (spaceId)->
  
    unless this.userId
      return this.ready()
    
    unless spaceId
      return this.ready()

    console.log '[publish] apps_auth_users for space.'

    selector = 
        space: spaceId

    return db.apps_auth_users.find selector, 
        sort: 
            modified: -1
        fields: 
            space: 1
            auth_name: 1
            user: 1
            user_name: 1
            login_name: 1
            login_password: 1
            modified: 1
