Template.portal_home.helpers Portal.helpers


Template.portal_home.onRendered ->
    Meteor.setTimeout((->
        console.log '====123'
        # widgets = Portal.helpers.Widgets();

    ), 3000)

Template.portal_home.events ->