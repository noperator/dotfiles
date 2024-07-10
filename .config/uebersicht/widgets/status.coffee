command: "$HOME/dotfiles/blocks/uebersicht-status.sh"

refreshFrequency: 10000

render: (output) ->
  """
  <link rel="stylesheet" type="text/css" href="./assets/css/all.min.css">
  <span id="status"></span>
  """

style: """
  position: absolute
  z-index: 2
  color: #bebebe
  font-family: Monaco
  font-size: 10px
  right: 14px
  top: 14px
  """

update: (output, domEl) ->
  output = output.replace /@.*?@/g, (match) -> "<i class='fas fa-fw fa-" + (match.replace /@/g, '') + "'></i>"
  $(domEl).find('#status').html(output)
