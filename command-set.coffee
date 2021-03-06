colors      = require 'colors'
program     = require 'commander'
packageJSON = require './package.json'

program
  .version packageJSON.version
  .command 'cluster', 'set the state state of a deployment'
  .command 'build', 'set the build state of a deployment'

class Command
  constructor: ->
    process.on 'uncaughtException', @die
    {@runningCommand} = @parseOptions()

  parseOptions: =>
    program.parse process.argv
    { runningCommand } = program
    return { runningCommand }

  run: =>
    return if @runningCommand
    program.outputHelp()
    process.exit 0

  dieHelp: (error) =>
    program.outputHelp()
    return @die error

  die: (error) =>
    return process.exit(0) unless error?
    console.error error.stack
    process.exit 1

module.exports = Command
