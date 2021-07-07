#!/usr/bin/env node

const { makeSourceFileSnippets, makeResourceFileSnippets } = require('./pluginXML')
const { getAndroidPaths } = require('./common')

const { libsAndroid, libsAndroidAar, libsAndroidOptional, parent } = getAndroidPaths()

const snippets = []
    .concat(makeSourceFileSnippets(libsAndroid, parent))
    .concat(makeSourceFileSnippets(libsAndroidOptional, parent))
    //.concat(makeResourceFileSnippets(libsAndroidAar, parent))
    .concat(makeSourceFileSnippets(libsAndroidAar, parent))

console.log('<!-- BEGIN .jar, .aar dependencies -->')
console.log(snippets.join('\n'))
console.log('<!-- END .jar, .aar dependencies -->')
