(($, window) ->

  $.fn.autogrow = (options) ->
    options            ?= {}
    options.horizontal ?= true
    options.vertical   ?= true
    options.debugx     ?= -10000
    options.debugy     ?= -10000
    options.debugcolor ?= 'yellow'
    options.flickering ?= true
    options.postGrowCallback ?= ->
    options.verticalScrollbarWidth ?= getVerticalScrollbarWidth()

    if options.horizontal is false and options.vertical is false
      return

    @.filter('textarea').each ->

      $e = $(@)

      return if $e.data 'autogrow-enabled'
      $e.data 'autogrow-enabled'

      minHeight     = $e.height()
      minWidth      = $e.width()
      heightPadding = $e.css('lineHeight') * 1 || 0
      $e.hasVerticalScrollBar = ->
        $e[0].clientHeight < $e[0].scrollHeight

      $shadow = $('<div class="autogrow-shadow"></div>')
        .css (
          position:           'absolute'
          display:            'inline-block'
          'background-color': options.debugcolor
          top:                options.debugy
          left:               options.debugx
          'max-width':        $e.css 'max-width'
          'padding':          $e.css 'padding'
          fontSize:           $e.css 'fontSize'
          fontFamily:         $e.css 'fontFamily'
          fontWeight:         $e.css 'fontWeight'
          lineHeight:         $e.css 'lineHeight'
          resize:             'none'
          'word-wrap':        'break-word' )
        .appendTo document.body

      if options.horizontal is false
        # fix width of shadow div, so it will remain unchanged
        $shadow.css({'width': $e.width()})
      else
        # make sure we have right padding to avoid flickering
        fontSize = $e.css 'font-size' # => 20px
        $shadow.css('padding-right', '+=' + fontSize)
        $shadow.normalPaddingRight = $shadow.css 'padding-right'

      update = (event) =>
        val = @
          .value
          .replace /&/g,   '&amp;'
          .replace /</g,   '&lt;'
          .replace />/g,   '&gt;'
          .replace /\n /g, '<br/>&nbsp;'
          .replace /"/g,   '&quot;'
          .replace /'/g,   '&#39;'
          .replace /\n$/,  '<br/>&nbsp;'
          .replace /\n/g,  '<br/>'
          .replace(
            / {2,}/g
            (space) -> Array(space.length - 1).join('&nbsp;') + ' '
          )

        if /(\n|\r)/.test @.value
          val += '<br />'

          # no flickering, but one extra line will be added
          if options.flickering is false
            val += '<br />'

        $shadow.html val

        if options.vertical is true
          height = Math.max($shadow.height() + heightPadding, minHeight)
          $e.height height

        if options.horizontal is true
          $shadow.css 'padding-right', $shadow.normalPaddingRight

          # if it should not grow vertically and if we have scrollbar,
          # add additional padding to shadow div to emulate the scrollbar
          if options.vertical is false and $e.hasVerticalScrollBar()
            $shadow.css 'padding-right', "+=#{options.verticalScrollbarWidth}px"

          # outerWidth is width with padding
          width = Math.max $shadow.outerWidth(), minWidth
          $e.width width

        options.postGrowCallback $e

      $e.change  update
        .keyup   update
        .keydown update

      $(window).resize update
      update()

) window.jQuery, window

getVerticalScrollbarWidth = ->
  inner = document.createElement('p')
  inner.style.width = "100%"
  inner.style.height = "200px"

  outer = document.createElement('div')
  outer.style.position = "absolute"
  outer.style.top = "0px"
  outer.style.left = "0px"
  outer.style.visibility = "hidden"
  outer.style.width = "200px"
  outer.style.height = "150px"
  outer.style.overflow = "hidden"
  outer.appendChild (inner)

  document.body.appendChild (outer)
  w1 = inner.offsetWidth
  outer.style.overflow = 'scroll'
  w2 = inner.offsetWidth
  if w1 is w2
    w2 = outer.clientWidth

  document.body.removeChild (outer)
  w1 - w2
