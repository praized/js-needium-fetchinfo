spawn       = require( 'child_process' ).spawn
spawnOpts   = 
    cwd: process.cwd()
    env: process.env
    customFds: [0,1,2]
coffeeArgs =  ['-w', '-b', '-o', './lib', '-c', './src']

exports.desc = 'Watches for changes and compiles the .coffee files from /src to /lib into javascript'
exports.task = ()-> 
    console.log 'Watching coffeescript'
    spawn 'coffee', coffeeArgs , spawnOpts
    
