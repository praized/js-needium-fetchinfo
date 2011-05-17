FS      = require 'fs'
spawn   = require( 'child_process' ).spawn
ugly    = require( "uglify-js"  )
jsp     = ugly.parser
pro     = ugly.uglify

spawnOpts   = 
    cwd: process.cwd()
    env: process.env
    customFds: [0,1,2]
    
coffeeArgs = [ '-o', './lib', '-c', './src']
    
    
FS = require 'fs'
MU = require 'mustache'
# MU.to_html
PACKAGE_MUSTACHE = '''
/***
{{name}}  {{version}}
    
{{#description}}
{{description}}
    
{{/description}}

{{#author}}
Copyright 2011 {{author}}
{{/author}}
{{#license}}
License: {{name}} {{url}}
{{/license}}
***/
'''

read = (path=process.cwd())->
    path = if /package\.json/.test( path ) then path else "#{path}/package.json"
    JSON.parse FS.readFileSync( path, 'utf8')


exports.desc = 'Minifies distribution'

exports.task = ()-> 
    compile = spawn 'coffee', coffeeArgs , spawnOpts
    compile.on 'exit', ()->
        orig_code = FS.readFileSync 'lib/fetchinfo.js', 'utf8'
        ast = jsp.parse(orig_code)
        ast = pro.ast_mangle(ast)
        ast = pro.ast_squeeze(ast)
        final_code =  pro.gen_code(ast)
        HEADER = MU.to_html( PACKAGE_MUSTACHE, read() )
        FS.writeFileSync 'lib/needium-fetchinfo.min.js', "#{HEADER}\n#{final_code}"
        FS.writeFileSync 'needium-fetchinfo.min.js',     "#{HEADER}\n#{final_code}"