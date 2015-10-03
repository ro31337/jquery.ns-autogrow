gulp = require 'gulp'
del = require 'del'
coffee = require 'gulp-coffee'
coffeelint = require 'gulp-coffeelint'
header = require 'gulp-header'
uglify = require 'gulp-uglify'
rename = require 'gulp-rename'
pjson = require './package.json'
copyright = """
/*!
  Non-Sucking Autogrow #{pjson.version}
  license: #{pjson.license}
  author: Roman Pushkin
  #{pjson.homepage}
*/

"""

dest = 'dist/'
source = 'src/'
code =
  in: "#{source}*.coffee"
  out: "#{dest}"

gulp.task 'clean', ->
  del [dest + '*']

gulp.task 'build', ->
  gulp
    .src code.in
    .pipe coffeelint()
    .pipe coffeelint.reporter() # Show coffeelint errors
    .pipe coffeelint.reporter('fail') # Make sure it fails in case of error
    .pipe coffee()
    .pipe header copyright
    .pipe gulp.dest(code.out)

  gulp
    .src code.in
    .pipe coffeelint()
    .pipe coffeelint.reporter() # Show coffeelint errors
    .pipe coffeelint.reporter('fail') # Make sure it fails in case of error
    .pipe coffee()
    .pipe uglify()
    .pipe rename({ suffix: '.min' })
    .pipe header copyright
    .pipe gulp.dest(code.out)

gulp.task 'watch', ->
  gulp
    .watch code.in, ['build']

gulp.task 'default', ['clean', 'build', 'watch'], ->
  
