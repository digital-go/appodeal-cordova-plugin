var getWidgetName = require('./getWidgetName')
var path = require('path')

module.exports = context => {
    var widgetName = getWidgetName(context)
    return path.join('platforms', 'ios', widgetName + '.xcodeproj', 'project.pbxproj')
}
