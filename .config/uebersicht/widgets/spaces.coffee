command: "./query-spaces.sh"

refreshFrequency: 1000

BUILTIN_DISPLAY_NAME: "Built-in Retina Display"

removeDuplicates: (ar) ->
  if ar.length == 0
    return []
  res = {}
  res[ar[key]] = ar[key] for key in [0..ar.length-1]
  value for key, value of res

generateIcons: (spaces) ->
  displays = @removeDuplicates((space['monitor-appkit-nsscreen-screens-id'] for space in spaces))
  iconString = ""
  for display in displays
    for space in spaces when space['monitor-appkit-nsscreen-screens-id'] == display
      iconString += "<li id=\"desktop#{space['workspace']}\">#{space['workspace']}</li>"
    if display < displays.length
      iconString += "<li>—</li>"
  return iconString

render: (output) ->
  parsed = JSON.parse(output)
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
  display = parseInt(window.location.pathname.split("/")[1])

  if (output == "")
    console.log('Empty output: ', output)
    return
  parsed = JSON.parse(output)
  spaces = parsed['spaces']

  # Find the NSScreen index aerospace has assigned to the built-in display.
  # If our Ubersicht index matches it, we're the built-in. Otherwise we're
  # whatever external display is connected — no need to know its name.
  builtinScreenId = (space['monitor-appkit-nsscreen-screens-id'] for space in spaces when space['monitor-name'] == @BUILTIN_DISPLAY_NAME)[0]
  isBuiltin = display == builtinScreenId

  if ($(domEl).find('.spaces-container').attr('data-count') != spaces.length.toString())
    $(domEl).find('.spaces-container').attr('data-count', "#{spaces.length}")
    $(domEl).find('ul').html(@generateIcons(spaces))
  else
    $(domEl).find('li.visible').removeClass('visible')
  for space in spaces
    onThisDisplay = if isBuiltin
      space['monitor-name'] == @BUILTIN_DISPLAY_NAME
    else
      space['monitor-name'] != @BUILTIN_DISPLAY_NAME
    if space['workspace-is-visible'] and onThisDisplay
      $(domEl).find("li#desktop#{space['workspace']}").addClass('visible')
    if space['windows']
      $(domEl).find("li#desktop#{space['workspace']}").removeClass('empty')
    else
      $(domEl).find("li#desktop#{space['workspace']}").addClass('empty')
