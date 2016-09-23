# Steedos Portal App 

Steedos Portal App is an Notification Center for corperate apps, just like Mac. 

### Modal Design
portal_dashboards
	space: "",
	name: "Corp Dashboard",
	description: "",
	icon: "ion icon name",
	widgets: ["widget-id"]

apps
   id: "",
   space: "",
   auth_name: "",
   on_click: ""

apps_auth
   id: "",
   name: "",, unique
   title: ""
  
[{
  name: 'ptr',
  title: "PTR域"
},{
  name: 'cnpc',
  title: "CNPC域"
}]


apps_auth_user
   auth_name: "",
   user_id: "",
   user_fullname: "",
   login_name: "",
   login_password: ""



{{Portal.GetAuthByName('cnpc').login_name}}