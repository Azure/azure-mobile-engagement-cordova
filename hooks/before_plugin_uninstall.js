/*
 * Copyright (c) Microsoft Corporation.  All rights reserved.
 * Licensed under the MIT license. See License.txt in the project root for license information.
 */
 
var plugins = ['lazyarea-location','realtime-location','finerealtime-location','foreground-reporting','background-reporting'];

module.exports = function(context) {
	
	var pluginDir = context.opts.plugin.pluginInfo.dir;
	for(var i in plugins) {
		var plugin = 'cordova-plugin-ms-azure-mobile-engagement-'+plugins[i];
		context.cordova.raw.plugin('rm', plugin);
	}
}