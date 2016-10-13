AppSSO =
	max_request_length: 100000
	proxy_request_timeout_ms: 10000
	enable_logging: true

	addCORSHeaders: (req, res)->
		if req.method.toUpperCase() == 'OPTIONS'
			if req.headers['access-control-request-headers']
				res.setHeader 'Access-Control-Allow-Headers', req.headers['access-control-request-headers']
			if req.headers['access-control-request-method']
				res.setHeader 'Access-Control-Allow-Methods', req.headers['access-control-request-method']

		if req.headers['origin']
			res.setHeader 'Access-Control-Allow-Origin', req.headers['origin']
		else
			res.setHeader 'Access-Control-Allow-Origin', '*'
	
	writeResponse: (res, httpCode, body)->
		res.statusCode = httpCode;
		res.end(body);
		
	sendInvalidURLResponse: (res)->
		return @writeResponse(res, 404, "url must be has querys as authToken,userId,authName");
		
	sendTooBigResponse: (res)->
		return @writeResponse(res, 413, "the content in the request or response cannot exceed " + @max_request_length + " characters.");
		
	getClientAddress: (req)->
		return (req.headers['x-forwarded-for'] or '').split(',')[0] or req.connection.remoteAddress

	sendHtmlResponse: (req, res)->
		app_id = req.params.app_id
		query = req.query
		auth_token = query.authToken
		user_id = query.userId
		auth_name = query.authName

		unless auth_token and user_id and auth_name
			AppSSO.sendInvalidURLResponse res

		apps_auth_user = Portal.GetAuthByName auth_name, user_id

		console.log "auth_name:"
		console.log auth_name
		console.log "user_id:"
		console.log user_id
		console.log "auth:"
		console.log apps_auth_user

		app = db.apps.findOne {_id:app_id}
		if app
			if app.is_use_ie
				app_script = app.on_click
				if app_script
					# 这里需要把脚本中{{login_name}}及{{login_password}}替换成当前用户在域账户（即apps_auth_user）中设置的域账户及密码
					reg_login_name = /{{login_name}}/g
					reg_login_password = /{{login_password}}/g
					if apps_auth_user
						login_name = apps_auth_user.login_name
						login_password = apps_auth_user.login_password
					else
						error_msg = "当前用户没有设置#{auth_name}域账户及密码"
						login_name = ""
						login_password = ""
					app_script = app_script.replace reg_login_name, login_name
					app_script = app_script.replace reg_login_password, login_password
				else
					error_msg = "当前应用的[链接脚本]属性内容为空，无法执行单点登录脚本"
					app_script = ""
			else
				error_msg = "当前应用的[使用IE打开]属性没有勾选，无法执行单点登录脚本"
				app_script = ""
		else
			error_msg = "当前应用不存在或已被删除"
			app_script = ""


		return @writeResponse res, 200, """
			<!DOCTYPE html>
			<html>
				<head>
					<meta charset="utf-8">
        			<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
        			<title>Steedos</title>
					<style>
						body { 
							background-color: #222d32;
							color:#fff;
						    font-family: 'Source Sans Pro', 'Helvetica Neue', Helvetica, Arial, sans-serif;
						}
						.loading{
						    position: absolute;
							left: 0px;
						    right: 0px;
						    top: 50%;
						    z-index: 1100;
						    text-align: center;
						    margin-top: -30px;
						    font-size: 36px;
						    color: #dfdfdf;
						}
					</style>
					<script type="text/javascript">
						#{app_script}
					</script>
				</head>
				<body>
					#{app_script}
					<div class = "loading">Loading...</div>
					<div class = "text-danger">#{error_msg}</div>
				</body>
			</html>
		"""



JsonRoutes.add 'get', '/api/app/sso/:app_id', (req, res, next) ->
	console.log 'fetching AppSSO from /api/app/sso: %s %s %s', (new Date).toJSON(), JSON.stringify(req.query), req.params.app_id
	AppSSO.sendHtmlResponse req, res


