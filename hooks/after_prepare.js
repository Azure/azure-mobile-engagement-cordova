
/*
 * Copyright (c) Microsoft Corporation.  All rights reserved.
 * Licensed under the MIT license. See License.txt in the project root for license information.
 */
 
var fs = require('fs');

module.exports = function(context) {

	// Only for Windows!
	 if (context.opts.platforms.indexOf('windows') < 0) {
        return;
    }

	var path = process.cwd()+"/platforms/windows/windows.json";
	if (!fs.existsSync(path) ) {
		console.error(path + " does not exist");
		return ;
	}

	var azme_variables ;
	try {
	     var contents = fs.readFileSync(path,'utf8');
 		 var jsonContent = JSON.parse(contents);
 		 var installed_plugins =  jsonContent['installed_plugins'];
		 azme_variables =  installed_plugins['cordova-plugin-ms-azure-mobile-engagement'];

	} catch (e) {
	    console.error(path + " could not be parsed");
	}

	// Retrieve version from config.xml
	var ConfigParser = require(process.cwd()+'/platforms/windows/cordova/node_modules/cordova-common/src/configparser/configparser.js');
	var cfg = new ConfigParser(process.cwd()+"/platforms/windows/config.xml");
	var version = cfg.doc._root.attrib['version'];

	azme_variables.APP_VERSION_NAME = version;

	var proxy = process.cwd()+"/platforms/windows/www/plugins/cordova-plugin-ms-azure-mobile-engagement/src/winjs/EngagementProxy.js";
	try {
	     var contents = fs.readFileSync(proxy,'utf8');
		for( var k in azme_variables)
		{
			var v = azme_variables[k];
			contents = contents.replace("\$"+k,v);
			console.log("--> replacing "+k+" by "+v);
	
		}
		fs.writeFileSync(proxy,contents);
	} catch (e) {
	    console.error(proxy + "does not exist");
	}

}