export PLUGIN_VERSION="1.0.0"
sed -i.bak "s/pluginVersion :.*/pluginVersion : \"$PLUGIN_VERSION\",/"  "www/AZME.js"
sed -i.bak "s/AZME_PLUGIN_VERSION .*/AZME_PLUGIN_VERSION \"$PLUGIN_VERSION\"/"  "src/ios/AZME.m"
sed -i.bak "s/pluginVersion = .*/pluginVersion = \"$PLUGIN_VERSION\";/"  "src/android/AZME.java"
sed -i.bak "s/\"version\": .*/\"version\": \"$PLUGIN_VERSION\",/"  "package.json"
sed -i.bak "s/id=\"cordova-plugin-ms-azme\" version=.*/id=\"cordova-plugin-ms-azme\" version=\"$PLUGIN_VERSION\">/"  "plugin.xml"
sed -i.bak "s/id=\"cordova-plugin-ms-azme-tests\" version=.*/id=\"cordova-plugin-ms-azme-tests\" version=\"$PLUGIN_VERSION\">/"  "tests/plugin.xml"



