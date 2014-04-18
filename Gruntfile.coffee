module.exports = (grunt) ->

  stylusFiles = [
    '{**/,}*.styl',
    '!node_modules/{**/,}*'
  ]

  grunt.initConfig
    stylus:
      app:
        options:
          paths: [
            'lib'
          ]
        files:
          # get all styl files as
          # 'some.css': 'some.styl'
          (->
            files = {}
            grunt.file.expand(stylusFiles).forEach (path)->
              files['build/' + path.replace /(\.css)?\.styl$/i, '.css'] = [path]
            files
          )()

    coffee:
      app:
        join:    true
        flatten: true
        src: [
          'scripts/app.coffee',
          '{**/,}*.coffee',
          '!Gruntfile*',
          '!node_modules/{**/,}*'
        ]
        dest: 'build/coffee.tmp.js'

    concat:
      js:
        src: [
          'lib/*.js',
          'scripts/*.js',
          'build/*.tmp.js',
          '!Gruntfile*',
          '!node_modules/{**/,}*'
        ]
        dest: 'build/app.js'
    clean:
      app:
        src: [
          'build/{**/,}*.tmp.*'
        ]

    connect:
      server:
        options:
          keepalive: true
          port: 9000,
          base: './'

    watch:
      stylus:
        files: [
          '{**/,}*.styl'
        ]
        tasks: ['stylus']
      scripts:
        files: [
          '{**/,}*.{js,coffee}',
          '!Gruntfile*',
          '!{node_modules,build}/{**/,}*'
        ]
        tasks: ['js']

  grunt.loadNpmTasks 'grunt-contrib-stylus'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-concat'
  grunt.loadNpmTasks 'grunt-contrib-connect'
  grunt.loadNpmTasks 'grunt-contrib-clean'

  grunt.registerTask 'js', ['coffee', 'concat', 'clean']
  grunt.registerTask 'default', ['stylus', 'js', 'watch']