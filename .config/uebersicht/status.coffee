command: "$HOME/dotfiles/blocks/uebersicht-status.sh"

refreshFrequency: 10000

render: (output) ->
  """
  <link rel="stylesheet" type="text/css" href="./assets/fontawesome-all.min.css">
  <div class="status"></div>
  """

style: """
  position: absolute
  z-index: 2
  color: #bebebe
  font-family: Monaco
  font-size: 10px
  right: 10px
  top: 10px
  """

update: (output, domEl) ->
  output = output.replace /@.*?@/g, (match) -> "<i class='fas fa-" + (match.replace /@/g, '') + "'></i>"
  $(domEl).find('.status').html(output)
