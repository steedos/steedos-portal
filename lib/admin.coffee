db.portal_dashboards.adminConfig = 
    icon: "globe"
    color: "blue"
    tableColumns: [
        {name: "name"},
        {name: "icon"},
        {name: "modified"},
    ]
    selector: {space: -1}
    routerAdmin: "/portal/admin"

db.portal_widgets.adminConfig = 
    icon: "globe"
    color: "blue"
    tableColumns: [
        {name: "name"},
        {name: "title"},
        {name: "icon"},
        {name: "cols"},
        {name: "modified"},
    ]
    selector: {space: -1}
    routerAdmin: "/portal/admin"


Meteor.startup ->

    @portal_dashboards = db.portal_dashboards
    @portal_widgets = db.portal_widgets
    AdminConfig?.collections_add
        portal_dashboards: db.portal_dashboards.adminConfig
        portal_widgets: db.portal_widgets.adminConfig


if Meteor.isClient
    Meteor.startup ->
        Tracker.autorun ->
            if Meteor.userId() and Session.get("spaceId")
                AdminTables["portal_dashboards"]?.selector = {space: Session.get("spaceId")}
                AdminTables["portal_widgets"]?.selector = {space: Session.get("spaceId")}

