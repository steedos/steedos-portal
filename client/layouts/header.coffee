Template.portalHeader.helpers


Template.portalHeader.events

	'click .steedos-help': (event) ->
		Steedos.showHelp();

	'click .fssh-home-link': (event) ->
		openUrl = "http://www.fssh.petrochina/Pages/default.aspx"
		if Steedos.isNode()
			exec = nw.require('child_process').exec
			cmd = "start iexplore.exe \"" + openUrl + "\""
			exec cmd, (error, stdout, stderr) ->
				if error
					toastr.error error
		else 
			Steedos.openWindow openUrl