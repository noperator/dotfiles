command: "head -n 1 /var/tmp/blocks/termdown.txt 2>/dev/null"

refreshFrequency: 900

render: (output) -> 
  ""

update: (output, domEl) ->
  for sid in ['#status', '#status-notch']
    status = $(sid)
    if status
      html = status.html()
      if html
        newhtml = html.replace /(<i class="fas fa-fw fa-hourglass"><\/i>&nbsp;)[0-9hms ]+/, (match) ->
          (match.replace /[0-9hms ]+$/, "") + output
        status.html(newhtml)
