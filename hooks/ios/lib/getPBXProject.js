const getPBXProjectPath = require('./getPBXProjectPath')
const xcode = require('xcode')

module.exports = context => {
    const pbxProjectPath = getPBXProjectPath(context)
    return xcode.project(pbxProjectPath)
}
