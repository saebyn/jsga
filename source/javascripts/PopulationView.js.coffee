# Copyright (c) 2012 John Weaver. All Rights Reserved.
# -*- coding: utf-8 -*-
# vim:ff=unix:nowrap:tabstop=4:shiftwidth=4:softtabstop=4:smarttab:shiftround:expandtab

jsGA = this.jsGA = this.jsGA || {}


BasePopulationView = Backbone.View.extend(
    nextPage: ->
        if @index + @options.pageSize < @collection.length
            @index += @options.pageSize

        @renderOrganisms()
        return false

    previousPage: ->
        if @index - @options.pageSize >= 0
            @index -= @options.pageSize

        @renderOrganisms()
        return false

    updatePagination: ->
        # get total count, update pagination link if count if over limit
        if @collection.length - @index > @options.pageSize
            @$('.pager li:last').removeClass('disabled')
        else
            @$('.pager li:last').addClass('disabled')

        if @collection.length <= @options.pageSize or @index == 0
            @$('.pager li:first').addClass('disabled')
        else
            @$('.pager li:first').removeClass('disabled')

        if @index > @collection.length
            @index = @collection.length - @options.pageSize

    addOrganism: (organism) ->
        view = new jsGA.OrganismSimpleView(
            model: organism
            generationId: @options.generationId
        )
        @$('ol').append(view.render().el)

    renderOrganisms: ->
        @$('ol').html('')

        @updatePagination()
        @collection.chain()
            .rest(@index)
            .first(@options.pageSize)
            .each(@addOrganism, this)
)


jsGA.PopulationSimpleView = BasePopulationView.extend(
    className: 'population simple'
    tagName: 'li'

    events:
        'click .pager a.higher': 'previousPage'
        'click .pager a.lower': 'nextPage'

    initialize: (options) ->
        options or= {}
        @index = 0
        @options.pageSize or= 50
        @template = _.template(options.template || $('#population-simple-view-template').html())
        @render()

    render: ->
        @$el.html(@template(@options))
        @renderOrganisms()
        this
)


jsGA.PopulationView = BasePopulationView.extend(
    className: 'population'

    events:
        'click button.step': 'step'
        'click button.run': 'run'
        'click button.stop': 'stop'
        'click .previous a': 'previousPage'
        'click .next a': 'nextPage'

    initialize: (options) ->
        options or= {}
        _.bindAll(this)
        @index = 0
        @options.pageSize or= 50
        @collection.bind('add', @renderOrganisms, this)
        @collection.bind('remove', @renderOrganisms, this)
        @collection.bind('change', @renderOrganisms, this)
        @collection.bind('reset', @renderOrganisms, this)
        @collection.bind('generation', @updateSteps, this)
        @template = _.template(options.template || $('#population-view-template').html())

    render: ->
        $('.navbar .nav li').removeClass('active')
        $('.navbar .nav a[href="#"]').parents('li').addClass('active')
        $(@el).html(@template())
        @renderOrganisms()
        settingsView = new jsGA.PopulationSettingsView({model: @collection.settings})
        $(@el).append(settingsView.render().el)
        this

    renderOrganisms: ->
        BasePopulationView.prototype.renderOrganisms.apply(this)
        @$('#organism-count').text(@collection.length)

    updateSteps: (remaining) ->
        if remaining == 0 
            @enableControls()

        @$('input.steps').val(remaining)

    enableControls: ->
        @$('button.step, button.run').prop('disabled', false)

    disableControls: ->
        @$('button.step, button.run').prop('disabled', true)

    step: ->
        @disableControls()
        @collection.run()

    stop: ->
        @enableControls()
        @collection.stop()

    run: ->
        steps = parseInt(@$('input.steps').val(), 10)
        if steps > 0 # keeps NaN out, since any comparison to NaN is false.
            @disableControls()
            @collection.run(steps)
        else
            $(@el).prepend('<div class="alert alert-error"><button class="close" data-dismiss="alert">&times;</button> Invalid number of steps</div>')
)
