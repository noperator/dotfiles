command: "$HOME/dotfiles/blocks/uebersicht-status.sh"

refreshFrequency: 10000

render: (output) ->
  """
  <link rel="stylesheet" type="text/css" href="./assets/css/all.min.css">
  <span class="status"></span>
  """

style: """
  position: absolute
  z-index: 2
  color: #bebebe
  font-family: Monaco
  font-size: 9px
  right: 14px
  top: 14px
  """

update: (output, domEl) ->

  # font-size: 10px
  # notch_width = 32
  # usable_space = 111

  # font-size: 9px
  notch_width = 35
  usable_space = 124

  # Break string up so it fits on either side of the notch.
  split = output.split(' ')
  str_right = ''
  for token in split.reverse()
    pseudo_token = token.replace /@.*?@/g, (match) -> '@@'
    if (str_right.replace /@.*?@/g, (match) -> '@@').length + pseudo_token.length <= usable_space
      str_right = token + ' ' + str_right
    else
      break
  str_left = output.substring(0, output.length - str_right.length)

  # Fill in any unused space on the right side with non-breaking space, and
  # fill the left in with the same amount of space.
  margin = usable_space - (str_right.replace /@.*?@/g, (match) -> '@@').length
  # notch_str = str_left + 'A'.repeat(margin) + 'B'.repeat(notch_width) + 'C'.repeat(margin) + str_right
  notch_str = str_left + '&nbsp;'.repeat(margin * 2 + notch_width) + str_right
  notch_str = notch_str.replace /@.*?@/g, (match) -> "<i class='fas fa-" + (match.replace /@/g, '') + "'></i>"
  $(domEl).find('.status').html(notch_str)
