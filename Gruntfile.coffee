module.exports = (grunt) ->
  # load package JSON
  pkg = grunt.file.readJSON 'package.json'
  
  # initialize grunt
  grunt.initConfig
    pkg: pkg
    clean:
      javascripts: ['test/*.js', 'test/collections/*.js', 'test/models/*.js']
    concat:
      coffee:
        src: [
          'sdk/ap/**.coffee'
          'sdk/utility/base64.coffee'
          'sdk/utility/cookie.coffee'
          'sdk/utility/url.coffee'
          'sdk/utility/mock_server.coffee'
          'sdk/utility/validator.coffee'
          'sdk/utility/transient_store.coffee'
          'sdk/utility/transient_cookie_store.coffee'
          'sdk/utility/transient_local_store.coffee'
          'sdk/utility/transient_large_local_store.coffee'
          'sdk/auth/**.coffee'
          'sdk/model/**.coffee'
          'sdk/relationship/relationship.coffee'
          'sdk/relationship/belongs_to_relationship.coffee'
          'sdk/relationship/has_many_relationship.coffee'
          'sdk/relationship/has_one_relationship.coffee'
          'sdk/collection/base_collection.coffee'
          'sdk/collection/base_scope_collection.coffee'
          'sdk/collection/base_aggregate_collection.coffee'
          'sdk/application/**.coffee'
          'sdk/models/**.coffee'
          'sdk/collections/**.coffee'
          'custom/**.coffee'
        ]
        dest: 'ap_sdk.coffee'
    coffee:
      sdk:
        files:
          'ap_sdk.js': 'ap_sdk.coffee'
      test:
        expand: true
        cwd: 'test/'
        src: ['**/*.coffee']
        dest: 'test/'
        ext: '.js'
    mocha_phantomjs:
      all: ['test/index.html']
    watch:
      sdk:
        files: ['sdk/**/*.coffee']
        tasks: ['build', 'test']
      test:
        files: ['test/**/*.coffee']
        tasks: ['coffee:test', 'test']
    yuidoc:
      all:
        name: '<%= pkg.name %>'
        description: '<%= pkg.description %>'
        version: '<%= pkg.version %>'
        options:
          syntaxtype: 'coffee'
          extension: '.coffee'
          paths: ['./sdk']
          outdir: './docs/api'
    guides:
      all:
        expand: true
        cwd: 'docs/guides/'
        src: ['guides.json']
        ext: '.html'
        template: 'guide.html.mustache'
    template:
      docs:
        src: 'docs/index.html.mustache'
        dest: 'docs/index.html'
    
  grunt.registerMultiTask 'guides', 'Compile guides', ->
    markdown = require('markdown').markdown
    @filesSrc.forEach (filepath) =>
      guidesConfig = grunt.file.readJSON filepath
      for section in guidesConfig
        for guide in section.items
          guide.section_name = section.name
          content = grunt.file.read "#{@data.cwd}/src/#{section.name}/#{guide.name}/README.md"
          compiled = markdown.toHTML content
          grunt.log.writeln "Compiling guide source for \"#{section.title}:  #{guide.title}\""
          grunt.config "template.guide-#{guide.name}",
            src: "#{@data.cwd}/#{@data.template}"
            dest: "#{@data.cwd}/#{section.name}/#{guide.name}/index.html"
            variables:
              title: guide.title
              name: guide.name
              section_title: section.title
              section_name: section.name
              content: compiled
          grunt.config 'template.docs.variables',
            guides: guidesConfig
    grunt.task.run 'template'
  
  # load required grunt tasks
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-concat'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-mocha-phantomjs'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-yuidoc'
  grunt.loadNpmTasks 'grunt-templater'
  
  # define custom tasks
  grunt.registerTask 'build', ['concat', 'coffee:sdk']
  grunt.registerTask 'build_docs', ['yuidoc', 'guides']
  grunt.registerTask 'test', ['coffee:test', 'mocha_phantomjs', 'clean']
