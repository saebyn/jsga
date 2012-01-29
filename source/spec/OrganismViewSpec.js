// -*- coding: utf-8 -*-
// vim:ff=unix:nowrap:tabstop=4:shiftwidth=4:softtabstop=4:smarttab:shiftround:expandtab
describe('Organism view', function () {
    beforeEach(function () {
        this.model = new Backbone.Model({
            chromosome: [1, 'test', 3, ['4', 5, 'test']],
            bases: [1, 3, ['4', 5, 'test'], 'test']
        });
        this.model.fitness = function () {
            return 1.0;
        };
        this.view = new jsGA.OrganismView({
            model: this.model
        });
    });

    describe('Initialization', function () {
        it('should have a class of "organism"', function () {
            expect($(this.view.el)).toHaveClass('organism');
        });

        it('should create a div element', function () {
            expect(this.view.el.nodeName).toEqual('DIV');
        });
    });

    describe('Rendering', function() {
        it('returns the view object', function() {
            expect(this.view.render()).toEqual(this.view);
        });

        it('should have an id that matches the models cid', function () {
            this.view.render();
            expect($(this.view.el)).toHaveId(this.model.cid);
        });

        it('should show an error message if model is false', function () {
            this.view.model = false;
            this.view.render();
            expect($(this.view.el)).toContain('.alert-message.error');
        });
    });
});
