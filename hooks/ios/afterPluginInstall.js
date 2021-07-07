const {
    addPBXShellScriptBuildPhase,
    getPBXProject,
    getWidgetName,
    removePBXShellScriptBuildPhase,
} = require('./lib')
const { name } = require('../../package.json')
const fs = require('fs')

module.exports = context => {
    const pbxProject = getPBXProject(context).parseSync()
    const comment = name
    /* eslint no-template-curly-in-string: 0 */
    const shellScript =
        '"\\"${SRCROOT}/' + getWidgetName(context) + '/Plugins/cordova-plugin-appodeal/run\\""'

    removePBXShellScriptBuildPhase(pbxProject, comment)
    addPBXShellScriptBuildPhase(pbxProject, comment, shellScript)

    fs.writeFileSync(pbxProject.filepath, pbxProject.writeSync())
}
