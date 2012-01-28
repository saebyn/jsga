// -*- coding: utf-8 -*-
// vim:ff=unix:nowrap:tabstop=4:shiftwidth=4:softtabstop=4:smarttab:shiftround:expandtab
(function () {
"use strict";

jsGA = this.jsGA = this.jsGA || {};

jsGA.ChromosomeVisualization = function (el, width, height) {
    el = $(el);
    this.initialize.apply(this, [el, width, height]);
};

_.extend(jsGA.ChromosomeVisualization.prototype, {
    initialize: function (el, width, height) {
        width = width || 40;
        height = height || 20;
        // Create a canvas the same size as the existing element.
        var canvas = this._getCanvas(width, height);
    
        // Grab the text contents of el for later.
        var text = el.text();

        // Clear the existing contents
        el.html('');
    
        // Attach the text to the canvas
        $(canvas).text(text);
    
        // Insert the canvas into the element
        el.append(canvas);

        this.canvas = canvas;
        this.bases = [];
        this.rawBases = [];
    },
    
    addChromosome: function (chromosome, bases) {
        // Merge the filtered bases of the provided chromosome into the
        // existing array of bases.
        var filtered = this._filterChromosome(chromosome, bases);
        this.bases.push.apply(this.bases, filtered);
        // Save the original base data in the same order, for later display.
        this.rawBases.push.apply(this.rawBases, _.map(filtered, function (base) { return bases[base]; }));
    },

    render: function () {
        var colors = this._generateColors(this.bases);
        var cellSize = this._getCellSize(this.canvas.width, this.canvas.height,
                                         this.bases.length);
        var cells = this._generateCells(this.bases.length, cellSize,
                                        this.canvas.width, this.canvas.height);
        this._drawCanvas(this.canvas, cells, colors);
    },

    _filterChromosome: function (chromosome, bases) {
        var filtered = [];
        for ( var i = 0 ; i < chromosome.length ; i++ ) {
            // TODO support chromosomes with non-flat structure
            filtered.push(_.indexOf(bases, chromosome[i]));
        }
        return filtered;
    },

    _getCanvas: function (width, height) {
        var canvas = document.createElement('canvas');
        canvas.width = width;
        canvas.height = height;
        return canvas;
    },

    /**
     *
     * Find the size of a rectangle that can be positioned `stringLength`
     * times with a larger canvas that is `canvasWidth` by `canvasHeight`.
     *
     * Return an array of [width, height].
     */
    _getCellSize: function (canvasWidth, canvasHeight, stringLength) {
        var n = Math.ceil(Math.sqrt(stringLength));
        return [Math.floor(canvasWidth / n), Math.floor(canvasHeight / n)];
    },

    _getColorFromRange: function (value, range, r, g, b) {
        if ( range <= 0 )
            range = 1;

        var step = 128.0 / range;

        value *= step;
        value = Math.round(value + 127.0);

        if ( r === false )
            r = value;

        if ( g === false )
            g = value;

        if ( b === false)
            b = value;

        var rs = r.toString(16),
            gs = g.toString(16),
            bs = b.toString(16);

        rs = rs.length == 2 ? rs : '0' + rs;
        gs = gs.length == 2 ? gs : '0' + gs;
        bs = bs.length == 2 ? bs : '0' + bs;

        return '#' + rs + gs + bs;
    },

    _generateColors: function (values) {
        var colors = [];
        var max = _.max(values);
        for ( var i = 0 ; i < values.length ; i++ ) {
            colors.push(this._getColorFromRange(values[i], max, 180, false, false));
        }

        return colors;
    },

    _generateCells: function (length, cellSize, canvasWidth, canvasHeight) {
        var cells = [];

        for ( var y = 0 ; y < canvasHeight ; y += cellSize[1] ) {
            for ( var x = 0 ; x + cellSize[0] < canvasWidth ; x += cellSize[0] ) {
                cells.push( [x, y, cellSize[0], cellSize[1]] );
                length--;

                // stop if we've already generated enough cells
                if ( length <= 0 )
                    return cells;
            }
        }

        return cells;
    },

    _drawCanvas: function (canvas, cells, colors) {
        // iterate over colors and cells
        // paint each cell onto the canvas
        var context = canvas.getContext('2d');
        context.textBaseline = 'middle';
        context.textAlign = 'center';
        context.font = 'normal 13px "Helvetica Neue",Helvetica,Arial,sans-serif';
        for ( var i = 0 ; i < cells.length ; i++ ) {
            var cell = cells[i];
            var x = cell[0],
                y = cell[1],
                width = cell[2],
                height = cell[3],
                color = colors[i];
            context.fillStyle = color;
            context.fillRect(x, y, width, height);
            // If the cell is sufficiently large, render the text
            // of the original base in the cell.
            var baseText = JSON.stringify(this.rawBases[i])
            var textMetric = context.measureText(baseText);
            if ( textMetric.width < width / 2 ) {
                context.fillStyle = '#000000';
                context.fillText(baseText, x + width / 2, y + height / 2);
            }
        }
    }
});

}).call(this);
