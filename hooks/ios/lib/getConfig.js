var getConfigParser = require('./getConfigParser')

module.exports = context => {
    var ConfigParser = getConfigParser(context)
    return new ConfigParser('config.xml')
}
