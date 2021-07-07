const path = require('path')

exports.getAndroidPaths = () => {
    const parent = path.join(__dirname, '..')
    const libsAndroid = 'libs/android'
    const libsAndroidAar = path.join(libsAndroid, 'aar')
    const libsAndroidOptional = path.join(libsAndroid, 'optional')

    return {
        libsAndroid,
        libsAndroidAar,
        libsAndroidOptional,
        parent,
    }
}

exports.isAar = file => /\.aar$/.test(file)

exports.isJar = file => /\.jar$/.test(file)

exports.isJarOrAar = file => /\.jar$/.test(file) || /\.aar$/.test(file)
