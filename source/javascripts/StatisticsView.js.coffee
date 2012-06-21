# Copyright (c) 2012 John Weaver. All Rights Reserved.
# -*- coding: utf-8 -*-
# vim:ff=unix:nowrap:tabstop=4:shiftwidth=4:softtabstop=4:smarttab:shiftround:expandtab
jsGA = this.jsGA = this.jsGA || {}


LineChartView = Backbone.View.extend(
    className: 'chart'

    initialize: (options) ->
        @width = options.width or 700
        @height = options.height or 300
        @padding = options.padding or 25
        @data = options.data

    scaleVis: (vis) ->
        if @options.yMax
            max = @options.yMax
        else
            max = d3.max(@data)
        
        # Scales
        x = d3.scale.linear().domain([0, @data.length - 1]).range [@padding, @width - @padding]
        y = d3.scale.linear().domain([0, max]).range [@height - @padding, @padding]

        xAxis = d3.svg.axis()
            .scale(x)
            .orient('bottom')

        yAxis = d3.svg.axis()
            .scale(y)
            .orient('left')

        @visXAxis.call(xAxis)
        @visYAxis.call(yAxis)
        
        vis.attr("d", d3.svg.line()
            .x((d,i) -> x(i))
            .y(y))

    updateChart: (data) ->
        @data = data
        @scaleVis(@vis.data([data]))

    buildChart: ->
        # Base vis layer
        svg = d3.select(@el)
          .append('svg:svg')
            .attr('width', @width)
            .attr('height', @height)
      
        # Add path layer
        @vis = svg.selectAll('path.line')
          .data([@data])
        .enter().append("svg:path")

        @visXAxis = svg.append("g")
            .attr("class", "axis")
            .attr("transform", "translate(0," + (@height - @padding) + ")")
        @visYAxis = svg.append("g")
            .attr("class", "axis")
            .attr("transform", "translate(" + @padding + ",0)")

        @scaleVis(@vis)


    render: ->
        @buildChart()
        this
)


FitnessChartView = LineChartView.extend(
    initialize: (options) ->
        options.yMax = 1.0
        options.data = @buildData(options.population)
        LineChartView.prototype.initialize.call(this, options)
        options.population.bind('genlog', @update, this)

    update: ->
        @updateChart(@buildData(@options.population))

    buildData: (population) ->
        data = []

        previousId = population.previousId
        # Loop over all generations, starting with the one immediately
        # before the current population, until either no previous generation
        # exists or is no longer in the session storage.
        while previousId != null
            # grab the generation from session storage with previousId
            json = window.sessionStorage[previousId]
            # if generation lookup fails, break the loop
            if json is undefined
                break

            generation = JSON.parse(json)

            sum = _.chain(generation.population)
                .pluck('fitness')
                .reduce((memo, num) ->
                    memo + num
                , 0)
                .value()

            if generation.population.length > 0
                data.push(sum / generation.population.length)

            # find the id of the generation prior to the fetched one
            previousId = generation.parent
        
        data.reverse()
)


jsGA.StatisticsView = Backbone.View.extend(
    initialize: (options) ->
        @fitnessChart = new FitnessChartView({population: options.population})
        @template = _.template(options.template || $('#statistics-view-template').html())

    render: ->
        $('.navbar li').removeClass('active')
        $('.navbar a[href="#statistics"]').parents('li').addClass('active')
        @$el.html(@template())
        @$('#fitness-chart').html(@fitnessChart.render().el)
        this
)
