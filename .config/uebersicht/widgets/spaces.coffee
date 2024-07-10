command: "./query-spaces.sh"

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
  # spaces = JSON.parse(output)
  parsed = JSON.parse(output)
  # console.log(parsed)
  spaces = parsed['spaces']
  htmlString = """
    <span class="spaces-container" data-count="#{spaces.length}">
      <ul>
        #{@generateIcons(spaces)}
      </ul>
      <span id="fader"></span>
    </span>
  """

style: """
  z-index: 1
  font: 14px "HelveticaNeue-Light", "Helvetica Neue Light", "Helvetica Neue", Helvetica, Arial, "Lucida Grande", sans-serif
  color: #bebebe
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
    list-style: none
    margin: 11px 0px 0px 8px
    padding-left: 0px

  li
    display: inline-block
    text-align: center
    width: 12px
    margin: 0px 6px

  li.visible
    border-bottom: 2px solid #bebebe

  li.empty
    color: #585858
"""

update: (output, domEl) ->
  # https://github.com/felixhageloh/uebersicht/issues/216#issuecomment-231367936
  display = parseInt(window.location.pathname.split("/")[1])

  if (output == "")
    console.log('Empty output: ', output)
    return
  parsed = JSON.parse(output)
  spaces = parsed['spaces']
  displays = parsed['displays']
  didx = (d for d in displays when d.id is display)[0].index

  if ($(domEl).find('.spaces-container').attr('data-count') != spaces.length.toString())
    $(domEl).find('.spaces-container').attr('data-count', "#{spaces.length}")
    $(domEl).find('ul').html(@generateIcons(spaces))
  else
    $(domEl).find('li.visible').removeClass('visible')
  for space in spaces
    if space['is-visible'] and didx == space['display']
      $(domEl).find("li#desktop#{space['index']}").addClass('visible')
    # if space['windows'].length
    if space['first-window'] != 0 and space['last-window'] != 0
      $(domEl).find("li#desktop#{space['index']}").removeClass('empty')
    else
      $(domEl).find("li#desktop#{space['index']}").addClass('empty')
