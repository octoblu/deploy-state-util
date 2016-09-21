_      = require 'lodash'
path   = require 'path'
url    = require 'url'
yaml   = require 'node-yaml'
debug  = require('debug')('deploy-state-util:travis-service')

class TravisService
  constructor: ({ config }) ->
    throw new Error 'Missing config argument' unless config?
    @travisYml = path.join process.cwd(), '.travis.yml'
    @webhookUrl = url.format {
      hostname: config['deploy-state'].hostname,
      protocol: 'https',
      slashes: true,
      pathname: '/deployments/travis-ci'
    }

  configure: ({ isPrivate }, callback) =>
    yaml.read @travisYml, (error, data) =>
      return callback error if error?
      type = 'com' if isPrivate
      type ?= 'org'
      _.set data, 'notifications.webhooks', "#{@webhookUrl}/#{type}"
      yaml.write @travisYml, data, callback

module.exports = TravisService
