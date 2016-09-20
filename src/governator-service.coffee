_       = require 'lodash'
url     = require 'url'
async   = require 'async'
request = require 'request'
moment  = require 'moment'
debug   = require('debug')('deploy-state-util:governator-service')

class GovernatorService
  constructor: ({ config }) ->
    @governators = config['governators']

  getStatuses: ({ repo, owner, tag }, callback) =>
    _getStatus = async.apply(@getStatus, { repo, owner, tag })
    async.mapValues @governators, _getStatus, callback

  getStatus: ({ repo, owner, tag }, { hostname, username, password }, cluster, callback) =>
    baseUrl = url.format {
      hostname: hostname
      protocol: 'https'
      slashes: true
    }
    options = {
      uri: '/status',
      baseUrl,
      json: true,
      auth: {
        username,
        password,
      },
    }
    debug 'get governator', options
    request.get options, (error, response, body) =>
      debug 'got governator', { baseUrl, body, error, statusCode: response?.statusCode }
      return callback error if error?

      deploys = _.pickBy body, (value, key) =>
        return _.startsWith key, "governator:/#{owner}/#{repo}"
      debug 'deploys', deploys
      callback null, @formatAll deploys

  formatAll: (deployments) =>
    deployments = _.map deployments, @format
    deployments = _.sortBy deployments, 'deployAtFull'
    return deployments

  format: (deployment) =>
    deployment = _.cloneDeep deployment
    deployment.deployAtSince = moment.unix(deployment.deployAt).fromNow()
    [govKey, etcdKey, dockerUrl, tag ] = deployment.key.split(':')
    slug = dockerUrl.replace 'quay.io/', ''
    deployment.deploymentKey = "#{slug}:#{tag}"
    return deployment

module.exports = GovernatorService
