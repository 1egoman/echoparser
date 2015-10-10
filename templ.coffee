xre = require "xregexp"

# http://stackoverflow.com/questions/5367369/named-capturing-groups-in-javascript-regex
`function namedRegexMatch(text, regex, matchNames) {
  var matches = regex.exec(text);

  return matches ? matches.reduce(function(result, match, index) {
    if (index > 0)
      // This substraction is required because we count 
      // match indexes from 1, because 0 is the entire matched string
      result[matchNames[index - 1]] = match;

    return result;
  }, {}) : null;
}`

# a really basic templating language
# replace what we want to replace with in {}
# like: "this is a {test}" with data {test: "hello world"}
# makes "this is a hello world"
exports.embed = (templ, opts={}) ->
  (data) ->
    templ.match(/\{[a-zA-Z0-9_]+\}/ig).forEach (m) ->
      # get the text within the match
      text = m.slice 1
      text = text.slice 0, text.length-1

      # get the location of this match in the string
      ind = templ.indexOf m

      # get the template's value
      comp = data[text] or "[none]"

      # reassemble the template
      templ = "#{templ.slice(0, ind)}#{comp}#{templ.slice(ind+m.length)}"
    templ


# using the data inside of a template string, reverse it into a parameter
# string.
exports.extract = (templ, opts={}) ->
  (data) ->
    # console.log "TEMPL:", templ
    # console.log "DATA:", data
    # console.log()


    names = (templ.match(/\{[a-zA-Z0-9_]+\}/ig) or []).map (m) ->
      # get the text within the match
      text = m.slice 1
      text = text.slice 0, text.length-1

      # get the location of this match in the string
      ind = templ.indexOf m
      templ = "#{templ.slice(0, ind)}(.*)#{templ.slice(ind+m.length)}"

      # return the name
      text

    # search with a regex
    namedRegexMatch data, new RegExp(templ, 'gi'), names



# console.log exports.extract("what time is it in {where} at {time}") "what time is it in bla at time"
