Template.portalHeader.helpers


Template.portalHeader.events

	'click .steedos-help': (event) ->
		Steedos.showHelp();

	'click .fssh-home-link': (event) ->
		openUrl = "https://fssh.eip.cnpc/Pages/default.aspx"
		if Steedos.isNode()
			exec = nw.require('child_process').exec
			cmd = "start iexplore.exe \"" + openUrl + "\""
			exec cmd, (error, stdout, stderr) ->
				if error
					toastr.error error
		else 
			Steedos.openWindow openUrl