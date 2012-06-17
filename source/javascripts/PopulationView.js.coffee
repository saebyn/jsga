# Copyright (c) 2012 John Weaver. All Rights Reserved.
# -*- coding: utf-8 -*-
# vim:ff=unix:nowrap:tabstop=4:shiftwidth=4:softtabstop=4:smarttab:shiftround:expandtab

jsGA = this.jsGA = this.jsGA || {}


jsGA.PopulationView = Backbone.View.extend(
    className: 'population'

    events:
        'click input.step': 'step'
        'click input.run': 'run'
        'click input.stop': 'stop'

    initialize: (options) ->
        options or= {}
        _.bindAll(this)
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
        @$('ol').html('')
        @collection.each(@addOrganism, this)

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
