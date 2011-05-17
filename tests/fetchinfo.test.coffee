require.paths.unshift require('path').resolve(__dirname,"../src")
$ = jQuery = require 'jquery'
if typeof XMLHttpRequest is 'undefined'
    XMLHttpRequest = require( 'xmlhttprequest' ).XMLHttpRequest

analyze = (msg,fn)-> module.exports[msg] = fn

fetchinfo = require('fetchinfo')

analyze "fetchinfo('twitter', 'user', 'quickredfox' ) should return quickrefox's user info", (test)->
    test.expect(1)
    fetch = fetchinfo( 'twitter', 'user', 'quickredfox' )
    fetch.done (v)-> 
        test.ok v.screen_name, 'has screen name'
    fetch.always ()-> test.done()
        
analyze "fetchinfo('twitter', 'hashtag', 'beer' ) should return beer-tagged tweets", (test)->
    test.expect(1)
    fetch = fetchinfo( 'twitter', 'hashtag', 'beer' )
    fetch.done (v)-> 
        test.ok v[0].text, 'has tweets'
    fetch.always ()-> test.done()

analyze "fetchinfo('twitter', 'hashtag', 'beer' ) should return beer-tagged tweets", (test)->
    test.expect(1)
    fetch = fetchinfo( 'twitter', 'hashtag', 'beer' )
    fetch.done (v)-> 
        test.ok v[0].text, 'has tweets'
    fetch.always ()-> test.done()
    
analyze "fetchinfo('twitter', 'tweets', 'quickredfox' ) should return quickredfox's recent tweets", (test)->
    test.expect(1)
    fetch = fetchinfo( 'twitter', 'tweets', 'quickredfox' )
    fetch.done (v)-> 
        test.ok v[0].text, 'has tweets'
    fetch.always ()-> test.done()
    
analyze "fetchinfo('twitter', 'profile', 'quickredfox' ) should bundle quickredfox's recent tweets and his profile data into one object", (test)->
    test.expect(2)
    fetch = fetchinfo( 'twitter', 'profile', 'quickredfox' )
    fetch.done (v)-> 
        test.ok v.public_timeline, 'has profile'
        test.ok v.screen_name,     'has tweets'
    fetch.always ()-> test.done()