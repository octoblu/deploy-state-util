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

  setState: ({ repo, owner, tag, state, passing, type }, callback) =>
    value = 'failed'
    value = 'passed' if passing
    options =
      baseUrl: @deployStateUri
      uri: "/deployments/#{owner}/#{repo}/#{tag}/#{type}/#{state}/#{value}"
      auth: @auth,

    debug 'set state options', options
    request.put options, (error, response) =>
      debug 'set state', { error }
      return callback error if error?
      if response.statusCode > 499
        return callback new Error 'Fatal error from deploy state service'
      callback null

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
