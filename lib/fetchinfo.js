(function() {
  var $, D, applyFilters, fetch, fetchers, fetchinfo, filters, isNode, jQuery;
  isNode = typeof process !== "undefined" && process.versions && !!process.versions.node;
  if (isNode) {
    $ = jQuery = require('jquery');
  } else {
    $ = jQuery = window.jQuery;
  }
  D = require('jquery-d');
  fetch = require('jquery-fetch');
  applyFilters = function(data, type) {
    var filter, name, out, _fn;
    out = data;
    _fn = function(name, filter) {
      try {
        return out = filter.call(null, data, type);
      } catch (E) {
        return console.log("Error in filter: " + name);
      }
    };
    for (name in filters) {
      filter = filters[name];
      _fn(name, filter);
    }
    return out;
  };
  filters = {
    google_static_map: function(data, type) {
      var parsegeo;
      if (type !== 'json') {
        return data;
      }
      parsegeo = function(data) {
        if ($.isPlainObject(data) || data instanceof Array) {
          $.each(data, function(key, value) {
            if (key === 'coordinates' && value.type && value.type === 'Point' && value.coordinates) {
              data.google_static_map = "http://maps.google.com/maps/api/staticmap?size=500x300&markers=color:blue|label:N|" + (value.coordinates.reverse().join(',')) + "&sensor=false";
            }
            return data[key] = parsegeo(value);
          });
        }
        return data;
      };
      return parsegeo(data);
    }
  };
  fetchers = {
    twitter: {
      user: function(username) {
        return fetch({
          url: "http://api.twitter.com/1/users/show.json?screen_name=" + username,
          dataType: 'jsonp',
          dataFilter: applyFilters
        });
      },
      hashtag: function(tag) {
        return fetch({
          url: "http://search.twitter.com/search.json?q=%23" + tag + "&rpp=10",
          dataType: 'jsonp',
          dataFilter: applyFilters
        }).pipe(function(data) {
          if (data.results) {
            return data.results;
          } else {
            return data;
          }
        });
      },
      tweets: function(username) {
        return fetch({
          url: "http://api.twitter.com/1/statuses/user_timeline.json?screen_name=" + username + "&count=10",
          dataType: 'jsonp',
          dataFilter: applyFilters
        });
      },
      profile: function(username) {
        var fetches;
        fetches = {
          user: this.user(username),
          tweets: this.tweets(username)
        };
        return D.deep(fetches).pipe(function(data) {
          var response;
          response = data.user;
          response.public_timeline = data.tweets;
          return response;
        });
      }
    }
  };
  fetchinfo = function(source, key, arg) {
    var fetcher;
    source = fetchers[source];
    if (source) {
      fetcher = source[key];
      if (fetcher && typeof fetcher === 'function') {
        return fetcher.call(source, arg);
      }
    }
  };
  if (isNode) {
    module.exports = fetchinfo;
  }
}).call(this);
