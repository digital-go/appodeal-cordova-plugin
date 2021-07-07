const path = require('path')
const fs = require('fs')
const { isAar, isJar, isJarOrAar } = require('./common')

exports.makeSourceFileSnippets = (dir, parentDir) => {
    const files = fs.readdirSync(path.join(parentDir, dir))
    return files
        .filter(isJarOrAar)
        .map(file => `<source-file src="${path.join(dir, file)}" target-dir="libs" />`)
}

exports.makeResourceFileSnippets = (dir, parentDir) => {
    const files = fs.readdirSync(path.join(parentDir, dir))
    return files
        .filter(isAar)
        .map(file => `<resource-file src="${path.join(dir, file)}" target="aar/${file}" />`)
}
