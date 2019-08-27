command: "/usr/local/bin/yabai -m query --spaces"

refreshFrequency: 100

generateIcons: (spaces) ->

  htmlString = """
    <div class="currentDesktop-container" data-count="#{spaces.length}">
      <ul>
  """

  for i in [0..spaces.length - 1]
    switch spaces[i]['index']
        when 1 then numeral = 'I'
        when 2 then numeral = 'II'
        when 3 then numeral = 'III'
        when 4 then numeral = 'IV'
        when 5 then numeral = 'V'
        when 6 then numeral = 'VI'
        when 7 then numeral = 'VII'
        when 8 then numeral = 'VII'
        when 9 then numeral = 'IX'
        else numeral = '?'
    htmlString += "<li id=\"desktop#{spaces[i]['index']}\">#{numeral}</li>"

  htmlString += """
      </ul>
    </div>
  """

  return htmlString

render: (output) ->
  spaces = JSON.parse(output)
  htmlString = @generateIcons(spaces)

style: """
  position: relative
  margin-top: 7px
  font: 14px "HelveticaNeue-Light", "Helvetica Neue Light", "Helvetica Neue", Helvetica, Arial, "Lucida Grande", sans-serif
  color: #aaa
  font-weight: 700

  ul
    list-style: none
    margin: 0 0 0 10px
    padding: 0

  li
    display: inline-block
    text-align: center
    width: 15px
    margin: 0 7px

  li.active
    color: #ededed
    border-bottom: 2px solid #ededed
"""

update: (output, domEl) ->
  spaces = JSON.parse(output)
  htmlString = @generateIcons(spaces)
  visible = (space['index'] for space in spaces when space['visible'] == 1)

  if ($(domEl).find('.currentDesktop-container').attr('data-count') != spaces.length.toString())
    $(domEl).find('.currentDesktop-container').attr('data-count', "#{spaces.length}")
    $(domEl).find('ul').html(htmlString)
  else
    $(domEl).find('li.active').removeClass('active')
  for space in visible
    $(domEl).find("li#desktop#{space}").addClass('active')
