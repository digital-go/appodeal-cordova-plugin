var getConfig = require('./getConfig')

module.exports = context => {
    var config = getConfig(context)
    return config.name()
}
