command: "/usr/local/bin/yabai -m query --spaces"

refreshFrequency: 1000

removeDuplicates: (ar) ->
  if ar.length == 0
    return []
  res = {}
  res[ar[key]] = ar[key] for key in [0..ar.length-1]
  value for key, value of res

generateIcons: (spaces) ->
  displays = @removeDuplicates((space['display'] for space in spaces))
  iconString = ""
  for display in displays
    for space in spaces when space['display'] == display
      iconString += "<li id=\"desktop#{space['index']}\">#{space['index']}</li>"
    if display < displays.length
      iconString += "<li>—</li>"
  return iconString

render: (output) ->
  spaces = JSON.parse(output)
  htmlString = """
    <div class="spaces-container" data-count="#{spaces.length}">
      <ul>
        #{@generateIcons(spaces)}
      </ul>
      <span id="fader"></span>
    </div>
  """

style: """
  z-index: 1
  font: 14px "HelveticaNeue-Light", "Helvetica Neue Light", "Helvetica Neue", Helvetica, Arial, "Lucida Grande", sans-serif
  color: #aaa
  font-weight: 700

  #fader
    position: absolute
    top: 14px
    width: 42px
    height: 18px
    --brown-bg:        rgb(45, 45, 45)
    --brown-bg-trans: rgba(45, 45, 45, 0)
    background: linear-gradient(to right,
                                var(--brown-bg)       0%,
                                var(--brown-bg-trans) 100%)

  ul
    display: inline-block
    background: #2d2d2d
    list-style: none
    margin: 11px 0px 0px 8px
    padding-left: 0px

  li
    display: inline-block
    text-align: center
    width: 14px
    margin: 0px 7px

  li.visible
    color: #ededed
    border-bottom: 2px solid #ededed
"""

update: (output, domEl) ->
  if (output == "")
    console.log('Empty output: ', output)
    return
  spaces = JSON.parse(output)
  if ($(domEl).find('.spaces-container').attr('data-count') != spaces.length.toString())
    $(domEl).find('.spaces-container').attr('data-count', "#{spaces.length}")
    $(domEl).find('ul').html(@generateIcons(spaces))
  else
    $(domEl).find('li.visible').removeClass('visible')
  for space in spaces when space['visible'] == 1
    $(domEl).find("li#desktop#{space['index']}").addClass('visible')
