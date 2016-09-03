Meteor.publish 'portal_widgets', (spaceId)->
  
    unless this.userId
      return this.ready()
    
    unless spaceId
      return this.ready()

    console.log '[publish] portal_widgets for space.'

    selector = 
        space: spaceId

    return db.portal_widgets.find selector, 
        sort: 
            modified: -1
        fields: 
            space: 1
            name: 1
            title: 1
            description: 1
            icon: 1
            template: 1
            cols:1
            data:1
            onData:1
            onRendered:1
