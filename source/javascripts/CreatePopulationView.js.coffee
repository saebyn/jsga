# Copyright (c) 2012 John Weaver. All Rights Reserved.
# -*- coding: utf-8 -*-
# vim:ff=unix:nowrap:tabstop=4:shiftwidth=4:softtabstop=4:smarttab:shiftround:expandtab

jsGA = this.jsGA = this.jsGA || {}

jsGA.CreatePopulationView = Backbone.View.extend(
    events:
        'click .create': 'create'
        'change #selection-elitism-enabled': 'toggleElitism'
        'change #selection-mechanism': 'updateMechanismOptions'
        'click .load': 'loadSavedSettings'
        'click .demo-choice': 'loadDemo'

    tagName: 'div'

    className: 'creator'

    initialize: (options) ->
        options or= {}
        _.bindAll(this)
        @model or= new jsGA.PopulationSettings
        @existingSettings = new jsGA.PopulationSettingsCollection()
        @existingSettings.bind('add', @addSetting)
        @existingSettings.fetch()
        @template = _.template(options.template || $('#population-create-template').html())

    loadDemo: ->
        # Find selected demo radio and
        # load settings from input data- attributes.
        demoSettings = _(@$('.demo-choice:checked').data()).clone()

        # base64 decode fitness function source
        if 'fitness' of demoSettings
            demoSettings.fitness = Base64.decode(demoSettings.fitness)

        # Fix any case issues
        caseConversions = ['chromosomeLength', 'crossoverProbability',
                           'mutationProbability', 'selectionMechanism']

        # Note that having keys with undefined values breaks @model.set(),
        # causing the form to not update.
        for cc in caseConversions
            if cc.toLowerCase() of demoSettings
                demoSettings[cc] = demoSettings[cc.toLowerCase()]
                delete demoSettings[cc.toLowerCase()]

        @model.set(demoSettings)

    loadSavedSettings: ->
        id = @$('#load-settings').val()
        if id
            @model.set(@existingSettings.get(id).toJSON(), {silent: true})
            @model.unset('name', {silent: true})
            @model.unset('id', {silent: true})
            @model.change()

    clearFormError: (selector) ->
        @$('.alert-message.error').fadeOut()
        @$(selector).removeClass('error')
        @$(selector).parents('.clearfix').removeClass('error')

    setFormError: (selector, message) ->
        $(@el).prepend('<div class="alert-message error">' + message + ' <a class="close" href="javascript:;">x</a></div>')
        @$(selector).addClass('error')
        @$(selector).parents('.clearfix').addClass('error')

    setField: (jqe, val) ->
        if jqe.attr('type') == 'checkbox' or jqe.attr('type') == 'radio'
            jqe.prop('checked', false)
            jqe.filter('[value="' + val + '"]').prop('checked', true).change()
        else
            jqe.val(val).change()

    getField: (jqe) ->
        jqe.val()

    bindFormField: (selector, event, field, filter, outfilter) ->
        filter = filter || _.identity
        outfilter = outfilter || _.identity

        @model.bind('change:' + field, (model, val) =>
            @clearFormError(selector)
            @setField(@$(selector), outfilter(val))
            if field == 'elitism'
                $('#selection-elitism-enabled').prop('checked', val > 0).change()
        )

        @$(selector).bind(event, (ev) =>
            data = {}
            data[field] = filter(@getField(@$(ev.target)))
            @model.set(data, {error: (model, message) =>
                @setField(@$(selector), outfilter(@model.get(field)))
                @setFormError(selector, message)
            })
        )

        @setField(@$(selector), outfilter(@model.get(field)))

    addSetting: (model) ->
        @$('select#load-settings').append('<option value="' + model.id + '">' + model.get('name') + '</option>')

    render: ->
        $('.navbar li').removeClass('active')
        $('.navbar a[href="#create"]').parents('li').addClass('active')
        $(@el).html(@template({
            existingSettings: @existingSettings
        }))

        coerceInt = (val) ->
            parseInt(val, 10)

        @bindFormField('#population-size', 'change', 'size', coerceInt)
        @bindFormField('#selection-mechanism', 'change', 'selectionMechanism')
        @bindFormField('#tournament-size', 'change', 'tournamentSize', coerceInt)
        @bindFormField('#chromosome-length', 'change', 'chromosomeLength', coerceInt)
        @bindFormField('input[name="chromosome-bases"]', 'change', 'bases',
                       (baseType) ->
                           [0, 1] if baseType == 'binary'
                       , (bases) ->
                           'binary' if _.isEqual(bases, [0, 1]))
        @bindFormField('#selection-elitism', 'change', 'elitism', parseFloat)
        @bindFormField('#crossover-probability', 'change', 'crossoverProbability', parseFloat)
        @bindFormField('#mutation-probability', 'change', 'mutationProbability', parseFloat)
        @bindFormField('#fitness-function', 'change', 'fitness')
        this

    updateMechanismOptions: ->
        # hide everything first
        $('.optional').hide()

        # unset all optional settings
        @model.unset('tournamentSize')

        if $('#selection-mechanism').val() == 'tournament'
            # cause the model to update and show the field
            $('#tournament-size').change().parents('.optional').show()

    toggleElitism: ->
        checked = @$('#selection-elitism-enabled').prop('checked')
        @$('#selection-elitism').prop('disabled', not checked)
        if not checked
            @model.set({elitism: 0.0})

    create: ->
        @collection.reset()
        @collection.seed(@model)
        window.router.navigate('', true)
)
