const { getPBXProject, removePBXShellScriptBuildPhase } = require('./lib')
const { name } = require('../../package.json')
const fs = require('fs')

module.exports = context => {
    const pbxProject = getPBXProject(context).parseSync()
    const comment = name
    removePBXShellScriptBuildPhase(pbxProject, comment)
    fs.writeFileSync(pbxProject.filepath, pbxProject.writeSync())
}
