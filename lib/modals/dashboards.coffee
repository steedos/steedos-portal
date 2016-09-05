db.portal_dashboards = new Meteor.Collection('portal_dashboards')

db.portal_dashboards._simpleSchema = new SimpleSchema
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
			order: 20

	description: 
		type: String,
		optional: true,
		autoform: 
			rows: 10,
			order: 30
	
	icon:
		type: String,
		optional: false
		autoform:
			omit: false
		
	widgets: 
		type: [String],
		optional: true,
		autoform:
			omit: false
			type: "select"
			multiple: true
			defaultValue: ->
				return []
			options: ->
				options = db.portal_widgets.find().map (widget) ->
					return {
						value: widget._id,
						label: widget.name
					}
				return options;

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

db.portal_dashboards.config = 
	STATUS_PENDING: 1                                                                                      // 34
	STATUS_APPROVED: 2                                                                                     // 35
	STATUS_REJECTED: 3                                                                                     // 36
	STATUS_SPAM: 4                                                                                      // 37
	STATUS_DELETED: 5 

if Meteor.isClient
	db.portal_dashboards._simpleSchema.i18n("portal_dashboards")

db.portal_dashboards.attachSchema(db.portal_dashboards._simpleSchema)



if Meteor.isServer
	
	db.portal_dashboards.before.insert (userId, doc) ->
		doc.created_by = userId
		doc.created = new Date()
		doc.modified_by = userId
		doc.modified = new Date()
		
		if !userId
			throw new Meteor.Error(400, t("portal_dashboards_error_login_required"));


	db.portal_dashboards.before.update (userId, doc, fieldNames, modifier, options) ->
		modifier.$set = modifier.$set || {};

		modifier.$set.modified_by = userId;
		modifier.$set.modified = new Date();



