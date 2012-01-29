# -*- coding: utf-8 -*-
# vim:ff=unix:nowrap:tabstop=4:shiftwidth=4:softtabstop=4:smarttab:shiftround:expandtab

describe 'Population settings view', () ->
    beforeEach () ->
        @model = new Backbone.Model()
        @view = new jsGA.PopulationSettingsView(
            model: @model
        )

    it 'should create a div element', () ->
        expect(@view.el.nodeName).toEqual('DIV')

    it 'should have a class of settings', () ->
        expect($(@view.el)).toHaveClass('settings')

    it 'should have a render that returns the view object', () ->
        expect(@view.render()).toEqual(@view)

    # it should:
    #  have an anchor element with a button class,
    #  data-controls-modal='population-settings-modal'
    #  link text == 'Settings'.
    #  have a div element with an id of 'population-settings-modal'
    #
