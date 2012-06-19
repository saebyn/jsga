// -*- coding: utf-8 -*-
// vim:ff=unix:nowrap:tabstop=4:shiftwidth=4:softtabstop=4:smarttab:shiftround:expandtab
// TODO add tests for elitism

describe('The Population collection', function () {
    beforeEach(function () {
        this.selector = {choose: function (collection) {return false;}};
        this.population = new jsGA.Population([], {model: jsGA.Organism, selector: this.selector});
        this.populationSettings = new jsGA.PopulationSettings({selectionMechaism: 'fp'});
    });

    describe('when seeding an initial generation', function () {
        beforeEach(function () {
            this.fpSelectorSpy = sinon.spy(jsGA, 'FitnessProportionateSelector');
            this.tSelectorSpy = sinon.spy(jsGA, 'TournamentSelector');
        });

        afterEach(function () {
            this.fpSelectorSpy.restore();
            this.tSelectorSpy.restore();
        });

        it('should create a model for each organism', function () {
            var eventSpy = sinon.spy();
            this.population.bind('reset', eventSpy);

            this.population.seed(this.populationSettings);
            
            expect(eventSpy.callCount).toEqual(1);
        });

        it('should not create the selector specified in the settings if one is provided', function () {
            this.population.seed(this.populationSettings);

            expect(this.fpSelectorSpy).not.toHaveBeenCalled();
        });

        it('should create a FitnessProportionateSelector if fp is chosen', function () {
            this.population.options.selector = false;
            this.population.seed(this.populationSettings);

            expect(this.fpSelectorSpy).toHaveBeenCalledOnce();
            expect(this.fpSelectorSpy).toHaveBeenCalledWithExactly();
        });

        it('should create a TournamentSelector if tournament is chosen', function () {
            this.population.options.selector = false;
            this.populationSettings.set({selectionMechanism: 'tournament', tournamentSize: 5});
            this.population.seed(this.populationSettings);

            expect(this.tSelectorSpy).toHaveBeenCalledOnce();
            expect(this.tSelectorSpy).toHaveBeenCalledWithExactly(5);
        });
    });

    describe('when breeding organisms', function () {
        it('should not call the selector with an elitism of 100%', function () {
            var chooseSpy = sinon.spy(this.selector, 'choose');

            this.populationSettings.set({elitism: 100.0});
            this.population.seed(this.populationSettings);

            this.population.run();

            expect(chooseSpy).not.toHaveBeenCalled();
        });

        it('should call the selector', function () {
            var chooseSpy = sinon.spy(this.selector, 'choose');

            this.population.seed(this.populationSettings);

            this.population.run();

            expect(chooseSpy).toHaveBeenCalled();
        });

        it('should give the selector a collection of available organisms', function () {
            var chooseSpy = sinon.spy(this.selector, 'choose');

            this.population.seed(this.populationSettings);

            this.population.run();

            expect(chooseSpy.getCall(0).args[0]).toBe(this.population);
        });

        it('should reset itself with each new generation', function () {
            var eventSpy = sinon.spy();

            this.choose = function (collection) {
                return [collection.first(), collection.last()];
            };
            this.population.seed(this.populationSettings);
            this.population.bind('reset', eventSpy);
            this.population.run(3);

            this.population.bind('generation', function (left) {
                if ( left == 0 ) {
                    expect(eventSpy).toHaveBeenCalledThrice();
                }
            });
        });
    });
});
