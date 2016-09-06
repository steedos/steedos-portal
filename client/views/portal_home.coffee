Template.portal_home.helpers Portal.helpers


Template.portal_home.onRendered ->
    Portal.autoCompileTemplate.autoCompile()
    # Meteor.setTimeout Portal.autoCompileTemplate, 3000

Template.portal_home.events ->