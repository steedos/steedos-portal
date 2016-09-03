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
		optional: false,
		autoform: 
			rows: 10,
			order: 30
	
	icon:
		type: String,
		optional: true
		autoform:
			omit: true
		
	widgets: 
		type: [String],
		optional: true,
		autoform:
			omit: true
			type: "select"
			multiple: true

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



# if Meteor.isServer
	
# 	db.portal_dashboards.before.insert (userId, doc) ->

# 		doc.created_by = userId
# 		doc.created = new Date()
# 		doc.modified_by = userId
# 		doc.modified = new Date()
		
# 		if !userId
# 			throw new Meteor.Error(400, t("portal_dashboards_error.login_required"));
		
# 		if !doc.postDate
# 			doc.postDate = new Date()

# 		# 暂时默认为已核准
# 		doc.status = db.portal_dashboards.config.STATUS_APPROVED
# 		doc.author = userId
# 		user = db.users.findOne({_id: userId})
# 		if user
# 			doc.author_name = user.name
# 		doc.summary = doc.body.substring(0, 400)

# 		# pick images from attachments 
# 		if doc and doc.attachments
# 			doc.attachments = _.compact(doc.attachments)
# 			atts = cfs.posts.find({_id: {$in: doc.attachments}}).fetch()
# 			doc.images = []
# 			_.each atts, (att)->
# 				if att.isImage()
# 					doc.images.push att._id


# 	db.portal_dashboards.after.insert (userId, doc) ->
# 		# update cfs meta
# 		if doc and doc.attachments
# 			cfs.posts.update {_id: {$in: doc.attachments}}, {
# 				$set: 
# 					site: doc.site
# 					post: doc._id
# 			}, {multi: true}
# 			cfs.posts.remove {post: doc._id, _id: {$not: {$in: doc.attachments}}}
	

# 	db.portal_dashboards.before.update (userId, doc, fieldNames, modifier, options) ->
# 		modifier.$set = modifier.$set || {};

# 		modifier.$set.modified_by = userId;
# 		modifier.$set.modified = new Date();

# 		# pick images from attachments 
# 		if modifier.$set.attachments
# 			modifier.$set.attachments = _.compact(modifier.$set.attachments)
# 			atts = cfs.posts.find({_id: {$in: modifier.$set.attachments}}).fetch()
# 			modifier.$set.images = []
# 			_.each atts, (att)->
# 				if att.isImage()
# 					modifier.$set.images.push att._id

# 		if modifier.$set.body 
# 			modifier.$set.summary = modifier.$set.body.substring(0, 400)


# 	db.portal_dashboards.after.update (userId, doc, fieldNames, modifier, options) ->
# 		self = this
# 		modifier.$set = modifier.$set || {}

# 		# update cfs meta
# 		if modifier.$set and modifier.$set.attachments
# 			cfs.posts.update {_id: {$in: modifier.$set.attachments}}, {
# 				$set: 
# 					site: doc.site
# 					post: doc._id
# 			}, {multi: true}
# 			cfs.posts.remove {post: doc._id, _id: {$not: {$in: modifier.$set.attachments}}}