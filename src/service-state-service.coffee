_       = require 'lodash'
url     = require 'url'
async   = require 'async'
request = require 'request'
moment  = require 'moment'
debug   = require('debug')('deploy-state-util:service-state-service')

class GovernatorService
  constructor: ({ config }) ->
    @serviceStates = config['service-state']

  getStatuses: ({ repo, owner, tag }, callback) =>
    _getStatus = async.apply(@getStatus, { repo, owner, tag })
    async.mapValues @serviceStates, _getStatus, callback

  getStatus: ({ repo, owner, tag }, { hostname, username, password }, cluster, callback) =>
    baseUrl = url.format {
      hostname: hostname
      protocol: 'https'
      slashes: true
    }
    options = {
      uri: "/#{owner}/#{repo}/docker_url",
      baseUrl,
      auth: {
        username,
        password,
      },
    }
    debug 'get docker_url', options
    request.get options, (error, response, body) =>
      debug 'got docker_url', { baseUrl, body, error, statusCode: response?.statusCode }
      return callback error if error?
      callback null, body

module.exports = GovernatorService
