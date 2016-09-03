Meteor.publish 'portal_dashboards', (spaceId)->
  
    unless this.userId
      return this.ready()
    
    unless spaceId
      return this.ready()

    console.log '[publish] portal_dashboards for space.'

    selector = 
        space: spaceId

    return db.portal_dashboards.find selector, 
        sort: 
            modified: -1
        fields: 
            space: 1
            name: 1
            description: 1
            icon: 1
            widgets: 1
