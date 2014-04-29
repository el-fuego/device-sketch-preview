module.exports = (grunt) ->

  stylusFiles = [
    '{**/,}*.styl',
    '!node_modules/{**/,}*'
  ]

  grunt.registerMultiTask 'js_templates_list', 'list of templates as js file', (a) ->
    options = @.options {
      prefix: 'var templates = '
    }
    @.files.forEach (data) ->
      templates = {}
      data.src.forEach (templateDir) ->
        pathArr = templateDir.split('/')
        templateName = pathArr[pathArr.length - 1]

        stylePath = grunt.file.expand("#{data.cwd||''}#{templateDir}/*.css")[0]
        stylePath = stylePath.replace data.cwd, '' if stylePath && data.cwd

        htmlPath = grunt.file.expand("#{data.cwd||''}#{templateDir}/*.html")[0]
        if htmlPath

          stylePath = grunt.file.expand("#{data.cwd||''}#{templateDir}/*.css")[0]
          stylePath = stylePath.replace data.cwd, '' if stylePath && data.cwd

          templates[templateName] = 
            stylePath: stylePath 
            html:      grunt.file.read htmlPath
        
      grunt.file.write data.dest, "#{options.prefix}#{JSON.stringify templates}"


  grunt.registerMultiTask 'set_files', ->

    options = @.options()
    grunt.config options.configName, @.files[0].src.map (path) ->
      data = {}
      data[path.replace(/\.[a-z0-9_-]+$/, ".#{options.resultExh}")] = path
      data

  grunt.registerMultiTask 'add_folder_to_templates_stylus', ->
    options = @.options {
      indent: '  '
    }
    @.files[0].src.map (path) ->
      pathArr = path.split('/')
      templateName = pathArr[pathArr.length - 2]

      file = grunt.file.read(path)
      grunt.file.write path, "template_#{templateName}\n" + file.replace(/(^|\n)/g, "$1#{options.indent}")

  grunt.initConfig
    stylus:
      app:
        options:
          paths: [
            'lib'
          ]
        files:
          'build/app.css': [
            '{,**/}*.styl'
            '!{node_modules,build,templates}/{**/,}*'
          ]
      templates:
        options:
          paths: [
            'lib'
          ]
        files: []

    coffee:
      app:
        join:    true
        flatten: true
        src: [
          'scripts/app.coffee',
          '{**/,}*.coffee',
          '!Gruntfile*',
          '!{node_modules,build,templates}/{**/,}*'
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

    set_files:
      stylus:
        options:
          resultExh: 'css'
          configName: 'stylus.templates.files'
        src: 'build/templates/**/{**,}*.styl'
      haml:
        options:
          resultExh: 'html'
          configName: 'haml.templates.files'
        src: 'build/templates/**/{**,}*.haml'

    add_folder_to_templates_stylus:
      stylus:
        src: 'build/templates/**/*.styl'

    copy:
      haml:
        src: [
          'templates/**/{**,}*.haml'
        ]
        dest: 'build/'
      stylus:
        src: [
          'templates/**/{**,}*.styl'
        ]
        dest: 'build/'
      images:
        src: [
          'templates/**/{**,}*.{jpg,jpeg,gif,png,tiff}'
        ]
        dest: 'build/'

    haml:
      app:
        files:
          'build/index.html': 'index.haml'
      templates:
        files: []

    clean:
      app:
        src: [
          'build/{**/,}*.tmp.*'
          'build/templates/{**/,}*.{haml,styl}'
        ]
    js_templates_list:
      templates:
        cwd: 'build/'
        src: [
          'templates/*'
        ]
        dest: 'build/templates.tmp.js'

    connect:
      server:
        options:
          livereload: true
          port: 3000,
          base: 'build/'

    open:
      app:
        path: 'http://localhost:3000/index.html'

    watch:
      stylus:
        files: [
          '{**/,}*.styl'
        ]
        tasks: ['styles_on_watch']
      scripts:
        files: [
          '{**/,}*.{js,coffee}',
          '!Gruntfile*',
          '!{node_modules,build}/{**/,}*'
        ]
        tasks: ['scripts_on_watch']
      haml:
        files: [
          '{**/,}*.{haml}',
          '!{node_modules,build}/{**/,}*'
        ]
        tasks: ['haml_to_html_on_watch']

      livereload:
        options:
          livereload: true
        files: [
          'build/{**/,}*.{html,js,css}'
        ]

  grunt.loadNpmTasks 'grunt-contrib-stylus'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-concat'
  grunt.loadNpmTasks 'grunt-contrib-haml'
  grunt.loadNpmTasks 'grunt-contrib-connect'
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadNpmTasks 'grunt-open'


  grunt.registerTask 'scripts', ['coffee', 'concat:js']
  grunt.registerTask 'scripts_on_watch', ['coffee', 'js_templates_list', 'concat:js', 'clean']

  grunt.registerTask 'styles', ['copy:stylus', 'set_files:stylus', 'add_folder_to_templates_stylus', 'stylus']
  grunt.registerTask 'styles_on_watch', ['styles', 'js_templates_list', 'scripts', 'clean']

  grunt.registerTask 'haml_to_html', ['copy:haml', 'set_files:haml', 'haml']
  grunt.registerTask 'haml_to_html_on_watch', ['haml_to_html', 'js_templates_list', 'scripts', 'clean']

  grunt.registerTask 'default', ['styles', 'haml_to_html', 'copy:images', 'js_templates_list', 'scripts', 'clean', 'connect', 'open', 'watch']