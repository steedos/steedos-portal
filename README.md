# Steedos Portal App 

Steedos Portal App is an Notification Center for corperate apps, just like Mac. 

### Modal Design

portal_dashboards
{
	space: "",
	name: "Corp Dashboard",
	description: "",
	icon: "ion icon name",
	widgets: ["widget-id"]
}

portal_widgets
{
	name: "Email Inbox Widget",
	title: "Email Inbox",
	description: "show 5 new emails via imap",
	icon: "ion icon name",
	template: "spacebar template",
	cols: 2, // options: 1,2,3,4
	data: [{title: "111", posted: "2012-2-1"}, {title: "222", posted: "2012-1-1"}], // scripts return json data
	onData: "", // javascripts
	onRendered: "" // javascripts
}

