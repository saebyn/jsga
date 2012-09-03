# Copyright (c) 2012 John Weaver. All Rights Reserved.
# -*- coding: utf-8 -*-
# vim:ff=unix:nowrap:tabstop=4:shiftwidth=4:softtabstop=4:smarttab:shiftround:expandtab
jsGA = this.jsGA = this.jsGA || {}

# Chart clases

#
# Weighted adjacency graph, with colors indicating designated groups.
# Inspired by http://bost.ocks.org/mike/miserables/
#
class AdjacencyGraph
    constructor: (el, options) ->
        @el = el
        @margin = options.margin or {top: 80, right: 0, bottom: 10, left: 80}
        @width = options.width or 700
        @height = options.height or 700
        @matrix = []

        @nodes = options.nodes
        links = options.links

        # define scales
        @scaleX = d3.scale.ordinal().rangeBands([0, @width])
        @scaleZ = d3.scale.linear().domain([0, 10]).clamp(true)
        @scaleColor = d3.scale.category10().domain([0...10])

        @matrix = []
        @nodeCount = @nodes.length
        
        _.each(@nodes, @mapNode, this)
        _.each(links, @loadLinks, this)

        @orders = @findOrders()
        
        # set default order via scale
        @scaleX.domain(@orders.name)
  
    changeOrder: (order) ->
        @scaleX.domain(@orders[order])

        transition = @svg.transition().duration(2500)

        transition.selectAll("g.row")
            .delay((d, i) => @scaleX(i) * 4)
            .attr("transform", (d, i) => "translate(0," + @scaleX(i) + ")")
            .selectAll(".cell")
            .delay((d) => @scaleX(d.x) * 4)
            .attr("x", (d) => @scaleX(d.x))

        transition.selectAll("g.column")
            .delay((d, i) => @scaleX(i) * 4)
            .attr("transform", (d, i) => "translate(" + @scaleX(i) + ")rotate(-90)")

    # Tag sort
    # For each type of ordering, sort an array of node indices
    # so that each consecutive element gives the index of the node
    # that should have the corresponding sorted position.
    findOrders: ->
        name: d3.range(@nodeCount).sort((a, b) =>
            d3.ascending(@nodes[a].name, @nodes[b].name)
        )
        count: d3.range(@nodeCount).sort((a, b) =>
            @nodes[b].count - @nodes[a].count
        )
        group: d3.range(@nodeCount).sort((a, b) =>
            @nodes[b].group - @nodes[a].group
        )

    loadLinks: (link) ->
        @matrix[link.from][link.to].z += link.count
        @matrix[link.from][link.from].z += link.count
        @matrix[link.to][link.to].z += link.count
        @matrix[link.to][link.from].z += link.count
        @nodes[link.from].count += link.count
        @nodes[link.to].count += link.count

    mapNode: (node, nodeIndex) ->
        node.index = nodeIndex
        node.count = 0
        @matrix[nodeIndex] = ({x: x, y: nodeIndex, z: 0} for x in [0...@nodeCount])

    build: ->
        @svg = d3.select(@el).append("svg")
            .attr("width", @width + @margin.left + @margin.right)
            .attr("height", @height + @margin.top + @margin.bottom)
            .style("margin-left", -@margin.left + "px")
            .append("g")
            .attr("transform", "translate(" + @margin.left + "," + @margin.top + ")")

        @svg.append("rect")
            .attr("class", "background")
            .attr("width", @width)
            .attr("height", @height)

        cellBuilder = @makeCellBuilder()
        row = @svg.selectAll('.row')
            .data(@matrix)
            .enter()
            .append('g')
            .attr('class', 'row')
            .attr("transform", (d, i) => "translate(0," + @scaleX(i) + ")")
            .each(cellBuilder)

        # Create separator line above row
        row.append("line")
            .attr("x2", @width)

        row.append("text")
            .attr("x", -6)
            .attr("y", @scaleX.rangeBand() / 2)
            .attr("dy", ".32em")
            .attr("text-anchor", "end")
            .text((d, i) => @nodes[i].name)

        column = @svg.selectAll(".column")
            .data(@matrix)
            .enter()
            .append("g")
            .attr("class", "column")
            .attr("transform", (d, i) => "translate(" + @scaleX(i) + ") rotate(-90)")

        # Create separator line left of column
        column.append("line")
            .attr("x1", -@width)

        column.append("text")
            .attr("x", 6)
            .attr("y", @scaleX.rangeBand() / 2)
            .attr("dy", ".32em")
            .attr("text-anchor", "start")
            .text((d, i) => @nodes[i].name)

    makeCellBuilder: ->
        view = this
        (row) ->
            d3.select(this).selectAll(".cell")
                .data(row.filter((d) -> d.z))
                .enter()
                .append("rect")
                .attr("class", "cell")
                .attr('title', (d) -> d.z)
                .attr("x", (d) => view.scaleX(d.x))
                .attr("width", view.scaleX.rangeBand())
                .attr("height", view.scaleX.rangeBand())
                .style("fill-opacity", (d) -> view.scaleZ(d.z))
                .style("fill", (d) ->
                    if view.nodes[d.x].group == view.nodes[d.y].group
                        view.scaleColor(view.nodes[d.x].group)
                    else
                        null
                )
                .on('mouseover', (p) ->
                    d3.selectAll("g.row text").classed("active", (d, i) ->
                        i == p.y
                    )
                    d3.selectAll("g.column text").classed("active", (d, i) ->
                        i == p.x
                    )
                )
                .on('mouseout', ->
                    d3.selectAll("text").classed("active", false)
                )


class Histogram
    constructor: (el, options) ->
        @el = el
        @width = options.width or 300
        @height = options.height or 300
        @margin = options.margin or {top: 10, left: 30, bottom: 30, right: 0}
        @data = options.data
        @histogram = d3.layout.histogram()
            .range([0.0, 1.0])

    scaleVis: (vis) ->
        histogram = @histogram(@data)
        # Scales
        x = d3.scale.ordinal()
            .rangeBands([@margin.left, @width - @margin.left - @margin.right])
            .domain(histogram.map((d) -> d.x))
        y = d3.scale.linear()
            .domain([0, d3.max(histogram.map((d) -> d.y))])
            .range([@height - @margin.bottom - @margin.top, @margin.top])

        xAxis = d3.svg.axis()
            .scale(x)
            .orient('bottom')
            .tickFormat(d3.format(".1f"))

        yAxis = d3.svg.axis()
            .scale(y)
            .orient('left')
            .tickFormat(d3.format('d'))

        @visXAxis.call(xAxis)
        @visYAxis.call(yAxis)
        
        vis.attr('width', x.rangeBand())
            .attr('x', (d) -> x(d.x))
            .attr('y', (d) => @height - y(d.y) - @margin.bottom)
            .attr('height', (d) -> y(d.y))

    update: (data) ->
        @data = data
        @scaleVis(@vis.data(@histogram(@data)))

    build: ->
        # Base vis layer
        svg = d3.select(@el)
            .append('svg:svg')
            .attr('width', @width)
            .attr('height', @height)
      
        @vis = svg.selectAll('rect')
            .data(@histogram(@data))
            .enter().append('rect')

        @visXAxis = svg.append("g")
            .attr("class", "axis")
            .attr("transform", "translate(0," + (@height - @margin.bottom) + ")")
        @visYAxis = svg.append("g")
            .attr("class", "axis")
            .attr("transform", "translate(" + @margin.left + ",0)")

        @scaleVis(@vis)


class LineChart
    constructor: (el, options) ->
        @el = el
        @width = options.width or 700
        @height = options.height or 300
        @padding = options.padding or 25
        @data = options.data
        @options = options

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

    update: (data) ->
        @data = data
        @scaleVis(@vis.data([data]))

    build: ->
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


# Chart views

AlleleCoOccuranceGraphView = Backbone.View.extend(
    className: 'matrix chart'

    events:
        'change #allele-ordering': 'changeOrdering'

    initialize: (options) ->
        options.width or= 770
        options.height or= options.width
        @template = _.template(options.template || $('#allele-cooccurance-graph-controls-template').html())
        @chart = new AdjacencyGraph(@el, @buildData(options.population))
        options.population.bind('genlog', @update, this)

    update: ->
        @chart = new AdjacencyGraph(@el, @buildData(@options.population))
        @$('svg').remove()
        @chart.build()

    changeOrdering: ->
        order = @$('#allele-ordering').val()
        @chart.changeOrder(order)

    buildData: (population) ->
        labelAllele = (chromosome, chromosomeIndex) ->
            '' + (chromosomeIndex + 1) + '/' + JSON.stringify(chromosome[chromosomeIndex])

        # Build a set of unique alleles, where each member has a unique
        # index between [0, _(alleles).keys().length)
        alleles = {}
        alleleIndex = 0

        edges = []

        # Get the index that we will eventually use for the graph node
        # representing the allele indexed in the provided chromosome,
        # creating a new index if the function has never encountered
        # the allele.
        getAlleleIndex = (chromosome, index) ->
            label = labelAllele(chromosome, index)
            if not _.has(alleles, label)
                alleles[label] = alleleIndex
                allele = alleleIndex
                alleleIndex += 1
            else
                allele = alleles[label]

            allele

        # Increment the count of edges between the nodes selected
        # by the provided indices, creating a new edge with a count of one
        # if the edge object does not already exist in the array.
        incrementEdge = (sourceAllele, destinationAllele) ->
            # Switch around source and dest so that we only use half the
            # adjacency matrix, so the counts don't have to be added
            # together.
            if destinationAllele < sourceAllele
                [sourceAllele, destinationAllele] = [destinationAllele, sourceAllele]

            if not edges[sourceAllele]?
                edges[sourceAllele] = []

            if not edges[sourceAllele][destinationAllele]?
                edges[sourceAllele][destinationAllele] = 1
            else
                edges[sourceAllele][destinationAllele] += 1

        # Traverse all organisms and build the graph.
        jsGA.visitGenerations(population, (population) ->
            _.chain(population)
                .pluck('chromosome')
                .each((chromosome) ->
                    for sourceIndex in [0...chromosome.length]
                        for destinationIndex in [(sourceIndex+1)...chromosome.length]
                            incrementEdge(getAlleleIndex(chromosome, sourceIndex),
                                          getAlleleIndex(chromosome, destinationIndex))
                )
        )

        # Flatten the set into an array so that we can use their indices to
        # identify nodes in the co-occurance graph.
        nodes = []
        for label, index of alleles
            nodes[index] = {name: label, group: index}

        links = []
        # Convert adjacency matrix of links into list of link objects
        for sourceAllele in [0...edges.length]
            if edges[sourceAllele]?
                for destinationAllele in [0...edges[sourceAllele].length]
                    if edges[sourceAllele][destinationAllele]?
                        links.push({from: sourceAllele, to: destinationAllele, count: edges[sourceAllele][destinationAllele]})

        # TODO identify the top 10 most associated groups of nodes in the graph

        {nodes: nodes, links: links}

    render: ->
        @$el.html(@template())
        @chart.build()
        this
)


FitnessDistributionGraphView = Backbone.View.extend(
    className: 'chart histogram'

    initialize: (options) ->
        options.data = @buildData(options.population)
        @chart = new Histogram(@el, options)
        options.population.bind('genlog', @update, this)

    update: ->
        @chart.update(@buildData(@options.population))

    render: ->
        @chart.build()
        this

    buildData: (population) ->
        data = []

        jsGA.visitGenerations(population, (population) ->
            _.chain(population)
                .pluck('fitness')
                .each(data.push, data)
        )

        data
)


FitnessChartView = Backbone.View.extend(
    className: 'chart'

    initialize: (options) ->
        options.yMax = 1.0
        options.data = @buildData(options.population)
        @chart = new LineChart(@el, options)
        options.population.bind('genlog', @update, this)

    update: ->
        @chart.update(@buildData(@options.population))

    render: ->
        @chart.build()
        this

    buildData: (population) ->
        data = []

        jsGA.visitGenerations(population, (population) ->
            sum = _.chain(population)
                .pluck('fitness')
                .reduce((memo, num) ->
                    memo + num
                , 0)
                .value()

            if population.length > 0
                data.push(sum / population.length)
        )
        
        data.reverse()
)


jsGA.StatisticsView = Backbone.View.extend(
    initialize: (options) ->
        @fitnessChart = new FitnessChartView({population: options.population})
        @alleleGraph = new AlleleCoOccuranceGraphView({population: options.population})
        @fitnessDistGraph = new FitnessDistributionGraphView({population: options.population})
        @template = _.template(options.template || $('#statistics-view-template').html())

    render: ->
        $('.navbar li').removeClass('active')
        $('.navbar a[href="#statistics"]').parents('li').addClass('active')
        @$el.html(@template())
        @$('#fitness-chart').html(@fitnessChart.render().el)
        @$('#allele-cooccurance-graph').html(@alleleGraph.render().el)
        @$('#fitness-distribution-graph').html(@fitnessDistGraph.render().el)
        this
)
