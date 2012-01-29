// -*- coding: utf-8 -*-
// vim:ff=unix:nowrap:tabstop=4:shiftwidth=4:softtabstop=4:smarttab:shiftround:expandtab
describe('Organism simple view', function () {
    beforeEach(function () {
        this.model = new Backbone.Model({
            chromosome: [1, 'test', 3, ['4', 5, 'test']],
            bases: [1, 3, ['4', 5, 'test'], 'test']
        });
        this.view = new jsGA.OrganismSimpleView({
            model: this.model
        });
    });

    describe('Initialization', function () {
        it('should have a class of "simple"', function () {
            expect($(this.view.el)).toHaveClass('simple');
        });

        it('should have a class of "organism"', function () {
            expect($(this.view.el)).toHaveClass('organism');
        });

        it('should create a list element', function () {
            expect(this.view.el.nodeName).toEqual('LI');
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

        it('should produce the correct HTML', function() {
            this.view.render();
            expect($(this.view.el).html())
                .toContain('[1,"test",3,["4",5,"test"]]');
        });

        it('should navigate to the viewOrganism route when clicked', function () {
            this.view.render();
            window.router = {navigate: function () {}};
            var routerNavSpy = sinon.spy(window.router, 'navigate');
            $(this.view.el).trigger('click');
            expect(routerNavSpy).toHaveBeenCalledOnce();
            expect(routerNavSpy).toHaveBeenCalledWith('organism/' + this.model.cid, true);
        });
    });
});
