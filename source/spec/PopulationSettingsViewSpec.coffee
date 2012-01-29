# -*- coding: utf-8 -*-
# vim:ff=unix:nowrap:tabstop=4:shiftwidth=4:softtabstop=4:smarttab:shiftround:expandtab

describe 'Population settings view', () ->
    beforeEach () ->
        @model = new jsGA.PopulationSettings

        @view = new jsGA.PopulationSettingsView(
            model: @model
        )

    it 'should create a div element', () ->
        expect(@view.el.nodeName).toEqual('DIV')

    it 'should have a class of settings', () ->
        expect($(@view.el)).toHaveClass('settings')

    it 'should have a render that returns the view object', () ->
        expect(@view.render()).toEqual(@view)

    describe 'Rendering', () ->
        beforeEach () ->
            @view.render()

        it 'should have an anchor element with a button class that opens the settings modal', () ->
            expect(@view.$('a.btn')).toHaveData('controls-modal', 'population-settings-modal')
            expect(@view.$('a.btn')).toHaveText('Settings')

        it 'should have a div element modal with an id of population-settings-modal', () ->
            expect(@view.$('div')).toHaveId('population-settings-modal')
            expect(@view.$('div')).toHaveClass('modal')

        it 'should show the attributes in the settings', () ->
            @model.set({elitism: 95.2})
            expect(@view.$('tr#elitism th')).toHaveText('Elitism')
            expect(@view.$('tr#elitism td')).toHaveText('95.2%')

        it 'should show a default attribute with a default class', () ->
            expect(@view.$('tr#size td')).toHaveClass('default')

        it 'should show "Fitness Proportionate"', () ->
            expect(@view.$('tr#selectionMechanism td')).toHaveText('Fitness Proportionate')
