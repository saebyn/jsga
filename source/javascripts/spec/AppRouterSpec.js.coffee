# -*- coding: utf-8 -*-
# vim:ff=unix:nowrap:tabstop=4:shiftwidth=4:softtabstop=4:smarttab:shiftround:expandtab
describe('AppRouter', ->
    beforeEach(->
        this.collection = new Backbone.Collection()
        this.populationStub = sinon.stub(jsGA, 'Population')
            .returns(this.collection)

        this.router = new jsGA.AppRouter()
        this.routeSpy = sinon.spy()
        try
            Backbone.history.start({silent:true, root: '/testrunner.html#'})
        catch error

        this.router.navigate('elsewhere')

        this.fetchStub = sinon.stub(this.collection, "fetch")
            .returns(null)

        this.createPopulationView = new Backbone.View();
        this.createViewStub = sinon.stub(jsGA, 'CreatePopulationView')
            .returns(this.createPopulationView)

        this.organismView = new Backbone.View();
        this.organismViewStub = sinon.stub(jsGA, 'OrganismView')
            .returns(this.organismView)

        this.populationView = new Backbone.View()
        this.populationViewStub = sinon.stub(jsGA, 'PopulationView')
            .returns(this.populationView)
    )
      
    afterEach(->
        jsGA.CreatePopulationView.restore()
        jsGA.OrganismView.restore()
        jsGA.PopulationView.restore()
        jsGA.Population.restore()
        this.fetchStub.restore()
    )

    it('should create a Population collection', ->
        expect(this.populationStub)
            .toHaveBeenCalledOnce()
        expect(this.populationStub)
            .toHaveBeenCalledWithExactly()
    )

    describe('routes', ->
        it('fires the index route with a blank hash', ->
            this.router.bind('route:index', this.routeSpy)
            this.router.navigate('', true)
            expect(this.routeSpy).toHaveBeenCalledOnce()
            expect(this.routeSpy).toHaveBeenCalledWith()
        )

        it('fires the createPopulation route', ->
            this.router.bind('route:createPopulation', this.routeSpy)
            this.router.navigate('create', true)
            expect(this.routeSpy).toHaveBeenCalledOnce()
            expect(this.routeSpy).toHaveBeenCalledWith()
        )

        it('fires the viewOrganism route', ->
            this.router.bind('route:viewOrganism', this.routeSpy)
            this.router.navigate('organism/1', true)
            expect(this.routeSpy).toHaveBeenCalledOnce()
            expect(this.routeSpy).toHaveBeenCalledWith("1")
        )
    )

    describe('Index handler', ->
        it('should create a Population view', ->
            this.collection.add(new Backbone.Model, {silent: true})
            this.router.index()
            expect(this.populationViewStub)
                .toHaveBeenCalledOnce()
            expect(this.populationViewStub)
                .toHaveBeenCalledWith({collection: this.collection})
        )

        it('should render the view', ->
            renderSpy = sinon.spy(this.populationView, 'render')
            this.collection.add(new Backbone.Model, {silent: true})
            this.router.index()
            expect(renderSpy).toHaveBeenCalled()
        )

        it('should send the user to the create pop handler if no population exists', ->
            spy = sinon.spy(this.router, 'navigate')
            this.router.index()
            expect(spy).toHaveBeenCalledOnce()
            expect(spy).toHaveBeenCalledWith('create', true)
        )
    )

    describe('Create Population handler', ->
        it('should create a CreatePopulation view', ->
            this.router.createPopulation()
            expect(this.createViewStub)
                .toHaveBeenCalledOnce()
            expect(this.createViewStub)
                .toHaveBeenCalledWith({collection: this.collection})
        )

        it('should render the view', ->
            renderSpy = sinon.spy(this.createPopulationView, 'render')
            this.router.createPopulation()
            expect(renderSpy).toHaveBeenCalled()
        )
    )

    describe('View Organism handler', ->
        beforeEach(->
            this.model = new Backbone.Model()
            this.collection.add(this.model)
            this.renderSpy = sinon.spy(this.organismView, 'render')
            this.router.viewOrganism(this.model.cid)
        )

        it('should create an Organism view', ->
            expect(this.organismViewStub)
                .toHaveBeenCalledOnce()
            expect(this.organismViewStub)
                .toHaveBeenCalledWith({model: this.model})
        )

        it('should render the view', ->
            expect(this.renderSpy).toHaveBeenCalled()
        )
    )
)
