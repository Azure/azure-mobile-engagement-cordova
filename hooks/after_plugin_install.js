
module.exports = function(context) {
	
	var cmd = context.cmdLine.toLowerCase();
	var found = cmd.match(/--variable enablelocation=(\S*)/);
	if (!found) 
		return ;
	var location = found[1];
	if (location != "lazyarera" && location != "realtime" && location != "finerealtime")
		throw new Error( "Unsupported parameter with --variable enableLocation: "+location);

	var pluginDir = context.opts.plugin.pluginInfo.dir + "#:"+location+"-location";
	context.cordova.raw.plugin('add', pluginDir );

	found = cmd.match(/--variable backgroundreporting=(\S*)/i);
	var background = (found && found[1]=="true")?"background":"foreground";
	
	pluginDir = context.opts.plugin.pluginInfo.dir + "#:"+background+"-reporting";
	context.cordova.raw.plugin('add', pluginDir );

}