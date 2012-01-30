// -*- coding: utf-8 -*-
// vim:ff=unix:nowrap:tabstop=4:shiftwidth=4:softtabstop=4:smarttab:shiftround:expandtab

describe('The Organism model', function () {
    it('should use the provided chromosome', function () {
        organism = new jsGA.Organism({chromosome: [1]});
        expect(organism.get('chromosome')).toEqual([1]);
    });

    describe('when creating a new organism', function() {
        beforeEach(function () {
            this.organism = new jsGA.Organism({bases: [1]});
        });

        it('should load a chromosome if not provided', function () {
            expect(this.organism.has('chromosome')).toBeTruthy();
        });

        it('should have a type attribute', function () {
            expect(this.organism.has('type')).toBeTruthy();
        });
    });

    describe('when mutating an organism', function () {
        beforeEach(function () {
            this.organism = new jsGA.Organism({chromosome: [2, 1, 0], bases: [0, 1, 2],
                                               mutationProbability: 0.9});
            this.randomStub = sinon.stub(Math, 'random');
        });

        afterEach(function () {
            this.randomStub.restore();
        });

        it('should do nothing most of the time', function () {
            this.randomStub.returns(this.organism.get('mutationProbability'));
            var eventSpy = sinon.spy();
            this.organism.bind("change:chromosome", eventSpy);
            this.organism.mutate();
            expect(eventSpy.called).toBeFalsy();
        });

        it('should mutate a random base', function () {
            // Convince Organism.mutate to mutate,
            // also mutate the first base in the chromosome,
            // and finally causes the method to choose the first base.
            this.randomStub.returns(0.0);
            this.organism.mutate();
            expect(this.organism.get('chromosome')[0]).toEqual(this.organism.get('bases')[0]);
        });
    });

    describe('when cloning an organism', function () {
        it('should give the new organism a different cid', function () {
            var organism = new jsGA.Organism({chromosome: [0, 1, 0, 1, 0, 1]});
            var clonedOrganism = organism.clone();
            expect(clonedOrganism.cid).toNotEqual(organism.cid);
        });

        it('should not give the new organism an id', function () {
            var organism = new jsGA.Organism({chromosome: [0, 1, 0, 1, 0, 1]});
            organism.set({id: 1});
            var clonedOrganism = organism.clone();
            expect(clonedOrganism.id).toBeUndefined();
        });
    });

    describe('when performing crossover', function () {
        beforeEach(function () {
            this.organism = new jsGA.Organism({chromosome: [0, 1, 0, 1, 0, 1],
                crossoverProbability: 0.9});
            this.otherOrganism = new jsGA.Organism({chromosome: [2, 2, 2, 2, 2, 2],
                crossoverProbability: 0.9});
            this.randomStub = sinon.stub(Math, 'random');
        });

        afterEach(function () {
            this.randomStub.restore();
        });

        it('should return two organisms', function () {
            this.randomStub.returns(0.4);
            var children = this.organism.crossover(this.otherOrganism);
            expect(children.length).toEqual(2);
            expect(children[0].has('chromosome')).toBeTruthy();
            expect(children[1].has('chromosome')).toBeTruthy();
        });

        it('should choose a random locus in the chromosome', function () {
            this.randomStub.returns(0.0);
            var children = this.organism.crossover(this.otherOrganism);
            expect(children.length).toEqual(2);
            expect(children[0].get('chromosome')).toEqual([0, 2, 2, 2, 2, 2]);
            expect(children[1].get('chromosome')).toEqual([2, 1, 0, 1, 0, 1]);
        });

        it('should return clones if it does not crossover', function () {
            this.randomStub.returns(this.organism.get('crossoverRate'));
            var children = this.organism.crossover(this.otherOrganism);
            expect(children[0].get('chromosome')).toEqual([0, 1, 0, 1, 0, 1]);
            expect(children[1].get('chromosome')).toEqual([2, 2, 2, 2, 2, 2]);
        });
    });
});
