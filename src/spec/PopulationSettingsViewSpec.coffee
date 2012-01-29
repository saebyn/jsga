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
