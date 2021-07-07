#!/usr/bin/env node

const { makeDependencySnippets } = require('./buildGradle')
const { getAndroidPaths } = require('./common')

const { libsAndroidAar, parent } = getAndroidPaths()

const snippets = makeDependencySnippets(libsAndroidAar, parent)

console.log('// BEGIN .aar dependencies')
console.log(snippets.join('\n'))
console.log('// END .aar dependencies')
