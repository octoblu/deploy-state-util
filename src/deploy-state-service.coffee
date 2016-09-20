url     = require 'url'
request = require 'request'
debug   = require('debug')('deploy-state-util:service')

class DeployStateService
  constructor: ({ config }) ->
    @deployStateUri = url.format {
      hostname: config['deploy-state'].hostname,
      protocol: 'https',
      slashes: true,
    }
    @auth = {
      username: config['deploy-state'].username,
      password: config['deploy-state'].password,
    }

  getStatus: ({ owner, repo, tag }, callback) =>
    options =
      baseUrl: @deployStateUri
      uri: "/deployments/#{owner}/#{repo}/#{tag}"
      auth: @auth,
      json: true
    debug 'get status options', options
    request.get options, (error, response, body) =>
      debug 'got status', { body, error }
      return callback error if error?
      if response.statusCode > 499
        return callback new Error 'Fatal error from deploy state service'
      if response.statusCode == 404
        return callback null
      callback null, body

  getList: ({ owner, repo }, callback) =>
    options =
      baseUrl: @deployStateUri
      uri: "/deployments/#{owner}/#{repo}"
      auth: @auth,
      json: true
    debug 'get list options', options
    request.get options, (error, response, body) =>
      return callback error if error?
      if response.statusCode > 499
        return callback new Error 'Fatal error from deploy state service'
      callback null, body

module.exports = DeployStateService
