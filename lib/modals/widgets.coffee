db.portal_widgets = new Meteor.Collection('portal_widgets')

db.portal_widgets._simpleSchema = new SimpleSchema
	space: 
		type: String,
		autoform: 
			type: "hidden",
			defaultValue: ->
				return Session.get("spaceId");

	name: 
		type: String,
		optional: false,
		max: 500,
		autoform: 
			order: 21

	title: 
		type: String,
		optional: false,
		max: 500,
		autoform: 
			order: 20
	
	icon:
		type: String,
		optional: false
		autoform:
			omit: false

	cols: 
		type: Number,
		optional: false,
		autoform: 
			order: 20
			defaultValue: ->
				return 2

	template: 
		type: String,
		optional: true,
		autoform: 
			rows: 10,
			order: 3
		
	data: 
		type: String,
		optional: true,
		autoform: 
			rows: 10,
			order: 3

	onData: 
		type: String,
		optional: true,
		autoform: 
			rows: 10,
			order: 3

	onRendered: 
		type: String,
		optional: true,
		autoform: 
			rows: 10,
			order: 3

	description: 
		type: String,
		optional: true,
		autoform: 
			rows: 10,
			order: 3

	created: 
		type: Date,
		optional: true
	created_by:
		type: String,
		optional: true
	modified:
		type: Date,
		optional: true
	modified_by:
		type: String,
		optional: true

db.portal_widgets.config = 
	STATUS_PENDING: 1                                                                                      // 34
	STATUS_APPROVED: 2                                                                                     // 35
	STATUS_REJECTED: 3                                                                                     // 36
	STATUS_SPAM: 4                                                                                      // 37
	STATUS_DELETED: 5 

if Meteor.isClient
	db.portal_widgets._simpleSchema.i18n("portal_widgets")

db.portal_widgets.attachSchema(db.portal_widgets._simpleSchema)



if Meteor.isServer
	
	db.portal_widgets.before.insert (userId, doc) ->
		doc.created_by = userId
		doc.created = new Date()
		doc.modified_by = userId
		doc.modified = new Date()
		
		if !userId
			throw new Meteor.Error(400, t("portal_widgets_error_login_required"));


	db.portal_widgets.before.update (userId, doc, fieldNames, modifier, options) ->
		modifier.$set = modifier.$set || {};

		modifier.$set.modified_by = userId;
		modifier.$set.modified = new Date();

	
	db.portal_widgets.before.remove (userId, doc) ->
		# check space exists
		space = db.spaces.findOne(doc.space)
		if !space
			throw new Meteor.Error(400, t("portal_widgets_error_space_not_found"));
		# only space admin can remove space_users
		if space.admins.indexOf(userId) < 0
			throw new Meteor.Error(400, t("portal_widgets_error_space_admins_only"));
		# can not delete widget while some dashboards contains this widget
		currentWidgetId = doc._id
		if db.portal_dashboards.findOne({widgets: currentWidgetId})
			throw new Meteor.Error(400, t("portal_widgets_error_contains_in_dashboards"));




