// -*- coding: utf-8 -*-
// vim:ff=unix:nowrap:tabstop=4:shiftwidth=4:softtabstop=4:smarttab:shiftround:expandtab

describe('The PopulationSettings model', function () {
    beforeEach(function () {
        this.model = new jsGA.PopulationSettings;
    });

    it('should require a population of at least 2', function () {
        expect(this.model.validate({size: 1})).not.toBeUndefined();
    });

    it('should require that the tournament size be no larger than the population', function () {
        expect(this.model.validate({tournamentSize: 21})).not.toBeUndefined();
    });

    it('should require a percentage for elitism', function () {
        expect(this.model.validate({elitism: -1})).not.toBeUndefined();
        expect(this.model.validate({elitism: 100.1})).not.toBeUndefined();
    });

    it('should require a percentage for crossover', function () {
        expect(this.model.validate({crossoverProbability: -1})).not.toBeUndefined();
        expect(this.model.validate({crossoverProbability: 100.1})).not.toBeUndefined();
    });

    it('should require a percentage for mutation rate', function () {
        expect(this.model.validate({mutationProbability: -1})).not.toBeUndefined();
        expect(this.model.validate({mutationProbability: 100.1})).not.toBeUndefined();
    });

    it('should disallow unknown selection mechanisms', function () {
        expect(this.model.validate({selectionMechanism: 'somethingelse'})).not.toBeUndefined();
    });

    it('should require at least one chromosome base', function () {
        expect(this.model.validate({bases: []})).not.toBeUndefined();
    });

    it('should require a function body string to determine fitness', function () {
        expect(this.model.validate({fitness: 0})).not.toBeUndefined();
    });

    it('should require a positive chromosome length', function () {
        expect(this.model.validate({chromosomeLength: 0})).not.toBeUndefined();
        expect(this.model.validate({chromosomeLength: -1})).not.toBeUndefined();
    });
});
