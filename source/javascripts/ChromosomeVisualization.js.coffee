# Copyright (c) 2012 John Weaver. All Rights Reserved.
# -*- coding: utf-8 -*-
# vim:ff=unix:nowrap:tabstop=4:shiftwidth=4:softtabstop=4:smarttab:shiftround:expandtab

jsGA = this.jsGA = this.jsGA || {};


class jsGA.ChromosomeVisualization
    constructor: (el, width, height) ->
        el = $(el)
        width or= 40
        height or= 20
        # Create a canvas the same size as the existing element.
        canvas = this._getCanvas(width, height)
    
        # Grab the text contents of el for later.
        text = el.text()

        # Clear the existing contents
        el.html('')
    
        # Attach the text to the canvas
        $(canvas).text(text)
    
        # Insert the canvas into the element
        el.append(canvas)

        @canvas = canvas
        @bases = []
        @rawBases = []
    
    addChromosome: (chromosome, bases) ->
        # Merge the filtered bases of the provided chromosome into the
        # existing array of bases.
        filtered = @_filterChromosome(chromosome, bases)
        @bases.push.apply(@bases, filtered)
        # Save the original base data in the same order, for later display.
        @rawBases.push.apply(@rawBases, _.map(filtered, (base) ->
            bases[base]
        ))

    render: ->
        colors = @_generateColors(@bases)
        cellSize = @_getCellSize(@canvas.width, @canvas.height, @bases.length)
        cells = @_generateCells(@bases.length, cellSize,
                                @canvas.width, @canvas.height)
        @_drawCanvas(@canvas, cells, colors)

    _filterChromosome: (chromosome, bases) ->
        # TODO support chromosomes with non-flat structure
        _.indexOf(bases, chromosome[i]) for i in [0...chromosome.length]

    _getCanvas: (width, height) ->
        canvas = document.createElement('canvas')
        canvas.width = width
        canvas.height = height
        canvas

    #
    # Find the size of a rectangle that can be positioned `stringLength`
    # times with a larger canvas that is `canvasWidth` by `canvasHeight`.
    #
    # Return an array of [width, height].
    #
    _getCellSize: (canvasWidth, canvasHeight, stringLength) ->
        n = Math.ceil(Math.sqrt(stringLength))
        [Math.floor(canvasWidth / n), Math.floor(canvasHeight / n)]

    _getColorFromRange: (value, range, r, g, b) ->
        if range <= 0
            range = 1

        step = 128.0 / range

        value *= step
        value = Math.round(value + 127.0)

        if not r
            r = value

        if not g
            g = value

        if not b
            b = value

        rs = r.toString(16)
        gs = g.toString(16)
        bs = b.toString(16)

        if rs.length == 1
            rs = '0' + rs

        if gs.length == 1
            gs = '0' + gs

        if bs.length == 1
            bs = '0' + bs

        '#' + rs + gs + bs

    _generateColors: (values) ->
        max = _.max(values)
        @_getColorFromRange(values[i], max, 180, false, false) for i in [0...values.length]

    _generateCells: (length, cellSize, canvasWidth, canvasHeight) ->
        cells = []
        y = 0

        while y < canvasHeight
            x = 0
            while (x + cellSize[0]) < canvasWidth
                cells.push([x, y, cellSize[0], cellSize[1]])
                length--

                # stop if we've already generated enough cells
                if ( length <= 0 )
                    return cells

                x += cellSize[0]

            y += cellSize[1]

        cells

    _drawCanvas: (canvas, cells, colors) ->
        # iterate over colors and cells
        # paint each cell onto the canvas
        context = canvas.getContext('2d')
        context.textBaseline = 'middle'
        context.textAlign = 'center'
        context.font = 'normal 13px "Helvetica Neue",Helvetica,Arial,sans-serif'
        for i in [0...cells.length]
            cell = cells[i]
            x = cell[0]
            y = cell[1]
            width = cell[2]
            height = cell[3]
            color = colors[i]
            context.fillStyle = color
            context.fillRect(x, y, width, height)
            # If the cell is sufficiently large, render the text
            # of the original base in the cell.
            baseText = JSON.stringify(this.rawBases[i])
            textMetric = context.measureText(baseText)
            if textMetric.width < width / 2
                context.fillStyle = '#000000'
                context.fillText(baseText, x + width / 2, y + height / 2)
