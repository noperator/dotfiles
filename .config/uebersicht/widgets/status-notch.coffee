command: "$HOME/dotfiles/blocks/uebersicht-status.sh"

refreshFrequency: 10000

render: (output) ->
  """
  <link rel="stylesheet" type="text/css" href="./assets/css/all.min.css">
  <!--span id="timer"></span-->
  <span id="status-notch"></span>
  """

style: """
  position: absolute
  z-index: 2
  color: #bebebe
  font-family: Monaco
  font-size: 0.6em
  right: 14px
  top: 14px
  """

update: (output, domEl) ->
  # console.log(window.location.pathname.split("/")[1])

  # font-size: 10px
  # notch_width = 32
  # usable_space = 111

  # font-size: 9px
  # notch_width = 36
  # usable_space = 120

  # font-size: 9px
  notch_width = 37
  usable_space = 120

  # font-size: 0.6em
  notch_width = 31
  notch_width = 33
  # notch_width = 29
  notch_width = 31
  notch_width = 32
  notch_width = 33
  usable_space = 109
  usable_space = 108

  debug = false
  # debug = true

  # Troubleshoot:
  # - Trial-and-error getting the font-size to divide evenly into the fa-fw
  #   width (1.25em)
  # - Get the usable_space right
  # - Get the notch_width right

  # Break string up so it fits on either side of the notch.
  fa_placehold = '@'.repeat(2)
  split = output.split(' ')
  str_right = ''
  for token in split.reverse()
    pseudo_token = token.replace /@.*?@/g, (match) -> fa_placehold
    if (str_right.replace /@.*?@/g, (match) -> fa_placehold).length + pseudo_token.length <= (usable_space - 1)
      str_right = token + ' ' + str_right
    else
      break
  str_left = output.substring(0, output.length - str_right.length)

  # Fill in any unused space on the right side with non-breaking space, and
  # fill the left in with the same amount of space.
  margin = usable_space - (str_right.replace /@.*?@/g, (match) -> fa_placehold).length
  if margin <= 0
    # margin = 1
    margin = 0
  if debug
    notch_str = str_left + 'A'.repeat(margin) + 'B'.repeat(notch_width) + 'C'.repeat(margin) + str_right
  else
    notch_str = str_left + '&nbsp;'.repeat(margin * 2 + notch_width) + str_right
  if debug
    compare_str = ((notch_str.replace /@.*?@/g, (match) -> fa_placehold).replace /[^@]/g, (match) -> '#').replace /.$/, (match) -> ''
  else
    compare_str = ''
  notch_str = notch_str.replace /@.*?@/g, (match) -> "<i class='fas fa-fw fa-" + (match.replace /@/g, '') + "'></i>"
  notch_str += "<br/>" + compare_str
  $(domEl).find('#status-notch').html(notch_str)
