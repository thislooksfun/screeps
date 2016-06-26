secret = require './secret'

module.exports = (grunt) ->
  grunt.loadNpmTasks 'grunt-screeps'
  
  grunt.initConfig
    screeps:
      options:
        email: secret.email
        password: secret.password
        branch: grunt.option('branch') ? 'test'
        ptr: false
      dist:
        src: ['dist/*.js']