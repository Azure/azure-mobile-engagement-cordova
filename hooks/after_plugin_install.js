/*
 * Copyright (c) Microsoft Corporation.  All rights reserved.
 * Licensed under the MIT license. See License.txt in the project root for license information.
 */
 
azmeLocationExtensionAlreadyInstalled = false;

module.exports = function(context) {
	
	// Do not install for each platform!
	if (azmeLocationExtensionAlreadyInstalled == true)
		return ;
	azmeLocationExtensionAlreadyInstalled = true;
	
	var cmd = context.cmdLine;	
	var regex = /--variable\s*(\w*)=([\S]*)/g
	var variables = {};
	var opts = { 
			cli_variables:{}
		};
	var match = regex.exec(cmd);
	while (match != null) {
		var key = match[1];
		var value = match[2];
	    opts.cli_variables[key]=value	// keep variables as is to pass to sub plugin
	    variables[key.toLowerCase()]=value // keep variables in lowercase to simplify detection
	    match = regex.exec(cmd);
	}
	
	var location = variables.enablelocation;
	if (!location)
		return ;

	location = location.toLowerCase();
	if (location != "lazyarera" && location != "realtime" && location != "finerealtime")
		throw new Error( "Unsupported parameter with --variable enableLocation: "+location);

	var locationPluginDir = context.opts.plugin.pluginInfo.dir + "#:"+location+"-location";

	context.cordova.raw.plugin('add', locationPluginDir, opts )
	.then(function() {

		var reporting = variables.backgroundreporting;
		var background = (reporting && reporting.toLowerCase()=="true")?"background":"foreground";
		var reportingPluginDir = context.opts.plugin.pluginInfo.dir + "#:"+background+"-reporting";
		context.cordova.raw.plugin('add', reportingPluginDir , opts);		
	});
}