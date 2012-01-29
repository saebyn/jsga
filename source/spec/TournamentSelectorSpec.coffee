# -*- coding: utf-8 -*-
# vim:ff=unix:nowrap:tabstop=4:shiftwidth=4:softtabstop=4:smarttab:shiftround:expandtab
describe 'The TournamentSelector', () ->
    beforeEach () ->
        @selector = new jsGA.TournamentSelector(2)
        @population = new jsGA.Population([], {model: jsGA.Organism, selector: @selector})
        @population.seed(new jsGA.PopulationSettings({size: 4, tournamentSize: 2}))
        @randomStub = sinon.stub(Math, 'random')

    afterEach () ->
        @randomStub.restore()

    it 'should return the most fit organism', () ->
        @randomStub.returns(0.0)
        pair = @selector.choose(@population)
        expect(pair[0].fitness()).toEqual(@population.at(0).fitness())
        expect(pair[1].fitness()).toEqual(@population.at(0).fitness())

    it 'should return the least fit organism', () ->
        @randomStub.returns(0.9)
        pair = @selector.choose(@population)
        expect(pair[0].fitness()).toEqual(@population.at(3).fitness())
        expect(pair[1].fitness()).toEqual(@population.at(3).fitness())
