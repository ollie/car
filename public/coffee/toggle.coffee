class @Toggle
  constructor: ->
    $items = $('[data-toggle-target]')

    $items.on('click', @_handleClick)

  _handleClick: (e) =>
    e.preventDefault()

    $source = $(e.currentTarget)
    $target = $($source.data('toggle-target'))

    $target.toggleClass('d-none')
