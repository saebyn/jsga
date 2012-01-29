// -*- coding: utf-8 -*-
// vim:ff=unix:nowrap:tabstop=4:shiftwidth=4:softtabstop=4:smarttab:shiftround:expandtab

describe('Create population view', function () {
    beforeEach(function () {
        this.view = new jsGA.CreatePopulationView({
            collection: new Backbone.Collection()
        });
    });

    it('should create a div element', function () {
        expect(this.view.el.nodeName).toEqual('DIV');
    });

    it('should have a class of creator', function () {
        expect($(this.view.el)).toHaveClass('creator');
    });

    it('should have a render that returns the view object', function() {
        expect(this.view.render()).toEqual(this.view);
    });

    describe('Controls', function () {
        beforeEach(function () {
            window.router = {navigate: function () {}};
            this.routerSpy = sinon.spy(window.router, 'navigate');
            this.view.collection.seed = function () {};
            this.populationCreateStub = sinon.stub(this.view.collection,
                                                   'seed');
            this.view.render();
        });

        afterEach(function () {
        });

        it('should add the population size input', function () {
            expect($(this.view.el)).toContain('input#population-size[type="number"]');
        });
        
        it('should add the population creation element', function () {
            expect($(this.view.el)).toContain('.create');
        });

        it('should create a new population when an element with the create class' +
           ' is clicked', function () {
            this.view.$('#population-size').val(4).change();
            this.view.$('.create').trigger('click');
            expect(this.populationCreateStub).toHaveBeenCalledOnce();
            expect(this.populationCreateStub.args[0][0].get('size')).toEqual(4);
        });

        it('should empty the existing population when a new one is created', function () {
            var resetSpy = sinon.spy();
            this.view.collection.bind('reset', resetSpy);
            this.view.$('#population-size').val('4').change();
            this.view.$('.create').trigger('click');
            expect(resetSpy).toHaveBeenCalledOnce();
            expect(resetSpy).toHaveBeenCalledBefore(this.populationCreateStub);
        });
    
        it('should switch to the main population view when' +
           ' an element with the create class is clicked', function () {
            this.view.$('#population-size').val('4').change();
            this.view.$('.create').trigger('click');
            expect(this.routerSpy).toHaveBeenCalledOnce();
            expect(this.routerSpy).toHaveBeenCalledWith('', true);
        });

        it('should enable the elitism input when the checkbox is enabled', function () {
            this.view.$('#selection-elitism-enabled').prop('checked', true).change();
            expect(this.view.$('#selection-elitism')).not.toBeDisabled();
        });

        it('should reset elitism to 0 when the checkbox is disabled', function () {
            this.view.$('#selection-elitism-enabled').prop('checked', false).change();
            expect(this.view.$('#selection-elitism')).toBeDisabled();
            expect(this.view.$('#selection-elitism').val()).toEqual('0');
        });
    });
});
