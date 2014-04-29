$(window).on 'templatesLoaded', ->
  $('dropZone').each (i, el) ->
    el.ondragover = ->
      $('dropZone').addClass "hover"
      false

    el.ondragleave = ->
      $('dropZone').removeClass "hover"
      false

    el.ondrop = (event) ->
      event.preventDefault()
      $('dropZone').removeClass "hover"
      reader = new FileReader()
      reader.onload = (event) ->
        $('[data-name="userImage"]').attr 'src', event.target.result
        $('dropZone').addClass "dropped"

      reader.readAsDataURL event.dataTransfer.files[0]