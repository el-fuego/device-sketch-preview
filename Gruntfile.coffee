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
            'lib',
            'templates'
          ]
        files:
          'build/app.css': [
            '{,**/}*.styl'
            '!{node_modules,build}/{**/,}*'
          ]

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

      haml:
        src: 'templates/*/*.haml'
        dest: 'build/templates.tmp.haml'


    haml:
      app:
        options:
          loadPath: 'build/'
        files:
          'build/index.tmp.html': 'index.haml'
          'build/templates.tmp.html': 'build/templates.tmp.haml'

    include_templates:
      app:
        src: [
          'build/*.tmp.html'
        ]

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
        tasks: ['scripts']
      haml:
        files: [
          '{**/,}*.{haml}',
          '!{node_modules,build}/{**/,}*'
        ]
        tasks: ['haml_to_html']

  grunt.loadNpmTasks 'grunt-contrib-stylus'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-concat'
  grunt.loadNpmTasks 'grunt-contrib-haml'
  grunt.loadNpmTasks 'grunt-contrib-connect'
  grunt.loadNpmTasks 'grunt-contrib-clean'

  grunt.registerMultiTask 'include_templates', 'fix haml require', ->
    file = grunt.file.read 'build/index.tmp.html'
    file = file.replace /<!--\s*include templates\s*-->/im, grunt.file.read('build/templates.tmp.html')
    grunt.file.write 'build/index.html', file

  grunt.registerTask 'scripts', ['coffee', 'concat:js']
  grunt.registerTask 'haml_to_html', ['concat:haml', 'haml', 'include_templates', 'clean']
  grunt.registerTask 'default', ['stylus', 'scripts', 'haml_to_html', 'watch']