command: ""

refreshFrequency: false

render: (output) -> 
  ""

update: (output, domEl) ->
  output = output.replace(/[^0-9hms :]/g, '')
  for sid in ['#status', '#status-notch']
    status = $(sid)
    if status
      html = status.html()
      if html
        newhtml = html.replace /(<i class="fas fa-fw fa-hourglass"><\/i>&nbsp;)[0-9hms ]+/, (match) ->
          (match.replace /[0-9hms ]+$/, "") + output
        status.html(newhtml)
