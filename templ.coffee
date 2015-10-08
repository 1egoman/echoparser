
# a really basic templating language
# replace what we want to replace with in {}
# like: "this is a {test}" with data {test: "hello world"}
# makes "this is a hello world"
module.exports = (templ, opts={}) ->
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

#console.log module.exports("ya, 1{test} {bla}")(test: "abc")
