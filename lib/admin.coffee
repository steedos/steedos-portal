db.portal_dashboards.adminConfig = 
    icon: "globe"
    color: "blue"
    tableColumns: [
        {name: "name"},
        {name: "description"},
        {name: "icon"},
        {name: "modified"},
    ]
    selector: {space: -1}
    routerAdmin: "/portal"

Meteor.startup ->

    @portal_dashboards = db.portal_dashboards
    AdminConfig?.collections_add
        portal_dashboards: db.portal_dashboards.adminConfig


if Meteor.isClient
    Meteor.startup ->
        Tracker.autorun ->
            if Meteor.userId() and Session.get("spaceId")
                db.portal_dashboards.adminConfig.routerAdmin = "/dashboards/"
                AdminTables["portal_dashboards"]?.selector = {space: Session.get("spaceId")}
                    