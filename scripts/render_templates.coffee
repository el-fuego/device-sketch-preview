$ ->
  _.each templates, (template, name) ->
    $template = $("<template_#{name}>").html(template.html)
    $template.append $("<link href='#{template.stylePath}' rel='stylesheet' type='text/css' />") if template.stylePath
    $('body').append $template

  $(window).trigger 'templatesLoaded'