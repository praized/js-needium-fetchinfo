isNode = typeof process isnt "undefined" and process.versions and !!process.versions.node
if isNode then $ = jQuery = require 'jquery' else $ = jQuery = window.jQuery
require('jquery-d')
require('jquery-fetch')

applyFilters = ( data, type )->
    out = data
    for name, filter of filters
        do ( name, filter )->
            try
                out = filter.call null, data, type
            catch E
                console.log "Error in filter: #{name}"
    return out

filters = 
    google_static_map: ( data, type)->
        return data if type isnt 'json'
        parsegeo = (data)->
            if $.isPlainObject( data ) or data instanceof Array
                $.each data, (key, value)->
                    if key is 'coordinates' and value.type and value.type is 'Point' and value.coordinates 
                        data.google_static_map = "http://maps.google.com/maps/api/staticmap?size=500x300&markers=color:blue|label:N|#{value.coordinates.reverse().join(',')}&sensor=false"                        
                    data[key] = parsegeo( value )
            return data
        return parsegeo(data)

fetchers = 
    twitter:
        user:    ( username )->
            $.fetch 
                url: "http://api.twitter.com/1/users/show.json?screen_name=#{username}"
                dataType: 'jsonp'
                dataFilter: applyFilters
        hashtag: ( tag )->
            $.fetch( 
                url: "http://search.twitter.com/search.json?q=%23#{tag}&rpp=10"
                dataType: 'jsonp'
                dataFilter: applyFilters 
            ).pipe (data)->
                    if data.results then data.results else data
        tweets:  ( username )->
            $.fetch 
                url:      "http://api.twitter.com/1/statuses/user_timeline.json?screen_name=#{username}&count=10"
                dataType: 'jsonp'
                dataFilter: applyFilters
        profile: ( username )->
            fetches = 
                user:  fetchers.twitter.user    username 
                tweets: fetchers.twitter.tweets username 
            $.D.deep( fetches ).pipe (data)->
                response = data.user
                response.public_timeline = data.tweets
                return response
    

module.exports = fetchinfo = ( source, key, arg )->
    source = fetchers[source]
    if source
        fetcher = source[key]
        if fetcher and typeof fetcher is 'function'
                fetcher.call( source, arg )

