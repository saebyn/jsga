# Copyright (c) 2012 John Weaver. All Rights Reserved.
# -*- coding: utf-8 -*-
# vim:ff=unix:nowrap:tabstop=4:shiftwidth=4:softtabstop=4:smarttab:shiftround:expandtab

jsGA = this.jsGA = this.jsGA || {}

jsGA.PopulationSettingsView = Backbone.View.extend(
    tagName: 'div'
    className: 'settings'

    initialize: (options) ->
        options = options || {}
        _.bindAll(this, 'save')
        @template = _.template(options.template || $('#population-settings-view-template').html())

        $('body').on('click', '#population-settings-modal input.save', _.debounce(@save, 1000, true))
        $('body').on('click', '#population-settings-modal input.reset', =>
            @reset()
        )

        @model.bind('change', @render, @)

    render: () ->
        $(@el).html(@template({settings: @model}))
        @

    reset: ->
        $('#population-settings-modal').modal('hide')
        population = window.router.population
        population.reset()
        population.seed(@model)
        window.router.navigate('', true)

    save: ->
        $('#population-settings-modal').modal('hide')
        name = prompt('Name this population setting:')
        if name
            @model.save({name: name},
                error: =>
                    $('#main').prepend('<div class="alert alert-error"><button class="close" data-dismiss="alert">&times;</button> Failed to save settings</div>')
                success: =>
                    $('#main').prepend('<div class="alert alert-success"><button class="close" data-dismiss="alert">&times;</button> Settings saved</div>')
            )

)
