// -*- coding: utf-8 -*-
// vim:ff=unix:nowrap:tabstop=4:shiftwidth=4:softtabstop=4:smarttab:shiftround:expandtab
describe('The FitnessProportionateSelector', function () {
    beforeEach(function () {
        this.selector = new jsGA.FitnessProportionateSelector();
        this.population = new jsGA.Population([], {model: jsGA.Organism, selector: this.selector});
        this.population.seed(new jsGA.PopulationSettings({size: 4}));
        this.randomStub = sinon.stub(Math, 'random');
    });

    afterEach(function () {
        this.randomStub.restore();
    });

    it('should return the most fit organism', function () {
        this.randomStub.returns(0.0);
        var pair = this.selector.choose(this.population);
        expect(pair[0].fitness()).toEqual(this.population.at(0).fitness());
        expect(pair[1].fitness()).toEqual(this.population.at(0).fitness());
    });

    it('should return the least fit organism', function () {
        this.randomStub.returns(0.9999999999);
        var pair = this.selector.choose(this.population);
        expect(pair[0].fitness()).toEqual(this.population.at(3).fitness());
        expect(pair[1].fitness()).toEqual(this.population.at(3).fitness());
    });
});
