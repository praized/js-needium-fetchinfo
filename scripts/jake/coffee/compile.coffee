spawn       = require( 'child_process' ).spawn
spawnOpts   = 
    cwd: process.cwd()
    env: process.env
    customFds: [0,1,2]
coffeeArgs = [ '-o', './lib', '-c', './src']

exports.desc = 'Compiles the .coffee files from /src to /lib into javascript'
exports.task = ()-> 
    spawn 'coffee', coffeeArgs , spawnOpts
    console.log 'succesfully compiled coffeescript'
    
