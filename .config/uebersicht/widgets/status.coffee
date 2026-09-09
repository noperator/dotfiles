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
  escapeHtml = (s) -> s.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;').replace(/'/g,'&#39;')
  output = escapeHtml(output)
  output = output.replace /@([a-z0-9-]+)@/g, (match, icon) -> "<i class='fas fa-fw fa-" + icon + "'></i>"
  $(domEl).find('#status').html(output)
