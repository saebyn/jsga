# -*- coding: utf-8 -*-
# vim:ff=unix:nowrap:tabstop=4:shiftwidth=4:softtabstop=4:smarttab:shiftround:expandtab
describe('Population view', ->
    beforeEach(->
        @collection = new Backbone.Collection([
            new Backbone.Model
        ])
        @collection.settings = new Backbone.Model
        @collection.settings.isDefault = (attr) ->
            false

        @view = new jsGA.PopulationView(
            collection: @collection
        )
    )

    describe('Initialization', ->
        it('should create a div element', ->
            expect(@view.el.nodeName).toEqual('DIV')
        )

        it('should have a class of population', ->
            expect($(@view.el)).toHaveClass('population')
        )
    )

    describe('Changes', ->
        beforeEach(->
            model = new Backbone.Model
            model.set({chromosome: [1]})
            @collection.reset([model], {silent: true})
            @organismView = new Backbone.View
            @organismView.render = ->
                @el = document.createElement('li')
                this

            @simpleOrganismViewStub = sinon.stub(jsGA, 'OrganismSimpleView')
                .returns(@organismView)
            @view.render()
        )

        afterEach(->
            @simpleOrganismViewStub.restore()
        )

        it('should add the organism when an organism is added to the collection', ->
            model = new Backbone.Model
            model.set({chromosome: [1]})
            @collection.add(model)
            expect($(@view.el).find('.organisms li').length).toEqual(2)
        )

        it('should remove the organism when an organism is removed from the collection', ->
            model = @collection.at(0)
            @collection.remove(model)
            expect($(@view.el).find('.organisms li').length).toEqual(0)
        )
    )

    describe('Rendering', ->
        beforeEach(->
            @organismView = new Backbone.View
            @organismView.render = ->
                @el = document.createElement('li')
                this

            @organismViewRenderSpy = sinon.spy(@organismView, 'render')

            @simpleOrganismViewStub = sinon.stub(jsGA, 'OrganismSimpleView')
                .returns(@organismView)

            @settingsView = new Backbone.View
            @settingsViewStub = sinon.stub(jsGA, 'PopulationSettingsView')
                .returns(@settingsView)

            @organism1 = new Backbone.Model
            @organism2 = new Backbone.Model
            @organism3 = new Backbone.Model
            @collection.reset([
                @organism1,
                @organism2,
                @organism3
            ], {silent: true})
        )

        afterEach(->
            jsGA.OrganismSimpleView.restore()
            @simpleOrganismViewStub.restore()
            @settingsViewStub.restore()
        )

        it('should render a PopulationSettingsView', ->
            renderSpy = sinon.spy(@settingsView, 'render')
            @view.render()
            expect(renderSpy).toHaveBeenCalledOnce()
        )

        it('should create an OrganismSimpleView for each organism', ->
            @view.render()
            expect(@simpleOrganismViewStub)
                .toHaveBeenCalledThrice()
            expect(@simpleOrganismViewStub)
                .toHaveBeenCalledWith({model: @organism1})
            expect(@simpleOrganismViewStub)
                .toHaveBeenCalledWith({model: @organism2})
            expect(@simpleOrganismViewStub)
                .toHaveBeenCalledWith({model: @organism3})
        )

        it('should append the OrganismSimpleView to the list', ->
            @view.render()
            expect($(@view.el).find('ol').children().length).toEqual(3)
        )
    
        it("should return the view object", ->
            expect(@view.render()).toEqual(@view)
        )

        describe('Controls', ->
            beforeEach(->
                @collection.stop = ->

                @collection.run = (steps) ->

                @populationRunStub = sinon.stub(@collection, 'run')
                @view.render()
            )

            afterEach(->
                @populationRunStub.restore()
            )

            it('should disable the run and step controls while running', ->
                @view.$('.step').trigger('click')
                expect(@view.$('.step')).toBeDisabled()
                expect(@view.$('.run')).toBeDisabled()
            )

            it('should enable the run and steps controls when stopped', ->
                @view.$('.step').trigger('click')
                @view.collection.trigger('generation', 1)

                @view.$('.stop').click()

                expect(@view.$('.step')).not.toBeDisabled()
                expect(@view.$('.run')).not.toBeDisabled()
            )

            it('should enable the run and steps controls when finished running', ->
                @view.$('.step').trigger('click')
                @view.collection.trigger('generation', 0)

                expect(@view.$('.step')).not.toBeDisabled()
                expect(@view.$('.run')).not.toBeDisabled()
            )

            it('should count down the number of remaining steps', ->
                @view.$('input.steps').val('6')
                @view.$('.step').trigger('click')
                @view.collection.trigger('generation', 5)

                expect(@view.$('input.steps').val()).toEqual('5')
            )

            it('should run a single generation when an element with a step class' +
               ' is clicked', ->
                @view.$('.step').trigger('click')
                expect(@populationRunStub)
                    .toHaveBeenCalledOnce()
                expect(@populationRunStub)
                    .toHaveBeenCalledWithExactly()
            )

            it('should run several generations when an element with the run class' +
               ' is clicked and a number is in an input with the steps class', ->
                @view.$('input.steps').val('3')
                @view.$('.run').trigger('click')
                expect(@populationRunStub)
                    .toHaveBeenCalledOnce()
                expect(@populationRunStub)
                    .toHaveBeenCalledWithExactly(3)
            )

            it('should show a message if the run element is clicked without a' +
               ' number entered', ->
                @view.$('input.steps').val('')
                @view.$('.run').trigger('click')
                expect(@populationRunStub.called).toBeFalsy()
                expect(@view.$('.alert-error').length).toEqual(1)
            )
        )
    )
)
