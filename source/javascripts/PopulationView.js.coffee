# Copyright (c) 2012 John Weaver. All Rights Reserved.
# -*- coding: utf-8 -*-
# vim:ff=unix:nowrap:tabstop=4:shiftwidth=4:softtabstop=4:smarttab:shiftround:expandtab

jsGA = this.jsGA = this.jsGA || {}


jsGA.PopulationView = Backbone.View.extend(
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
        @pageSize = 50
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

    nextPage: ->
        if @index + @pageSize < @collection.length
            @index += @pageSize

        @renderOrganisms()
        return false

    previousPage: ->
        if @index - @pageSize >= 0
            @index -= @pageSize

        @renderOrganisms()
        return false

    updatePagination: ->
        console.log @collection.length, @index, @pageSize
        # get total count, update pagination link if count if over limit
        if @collection.length - @index > @pageSize
            @$('.pager .next').removeClass('disabled')
        else
            @$('.pager .next').addClass('disabled')

        if @collection.length <= @pageSize or @index == 0
            @$('.pager .previous').addClass('disabled')
        else
            @$('.pager .previous').removeClass('disabled')

        if @index > @collection.length
            @index = @collection.length - @pageSize

    renderOrganisms: ->
        @$('ol').html('')

        @updatePagination()

        @collection.chain()
            .rest(@index)
            .first(@pageSize)
            .each(@addOrganism, this)

    updateSteps: (remaining) ->
        if remaining == 0 
            @enableControls()

        @$('input.steps').val(remaining)

    addOrganism: (organism) ->
        view = new jsGA.OrganismSimpleView({
            model: organism
        })
        @$('ol').append(view.render().el)

    enableControls: ->
        @$('input.step, input.run').prop('disabled', false)

    disableControls: ->
        @$('input.step, input.run').prop('disabled', true)

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
