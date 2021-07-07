const path = require('path')
const fs = require('fs')
const { isAar } = require('./common')

exports.makeDependencySnippets = (dir, parentDir) => {
    const files = fs.readdirSync(path.join(parentDir, dir))
    return files
        .filter(isAar)
        .map(file => file.replace(/\.aar$/, ''))
        .map(fileWithoutExt => `compile name: '${fileWithoutExt}', ext: 'aar'`)
}
