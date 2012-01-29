// -*- coding: utf-8 -*-
// vim:ff=unix:nowrap:tabstop=4:shiftwidth=4:softtabstop=4:smarttab:shiftround:expandtab
describe('Population view', function () {
    beforeEach(function () {
        this.collection = new Backbone.Collection([
            new Backbone.Model
        ]);
        this.view = new jsGA.PopulationView({
            collection: this.collection
        });
    });

    describe('Initialization', function () {
        it('should create a div element', function () {
            expect(this.view.el.nodeName).toEqual('DIV');
        });

        it('should have a class of population', function () {
            expect($(this.view.el)).toHaveClass('population');
        });
    });

    describe('Changes', function () {
        beforeEach(function () {
            var model = new Backbone.Model;
            model.set({chromosome: [1]});
            this.collection.reset([model], {silent: true});
            this.organismView = new Backbone.View;
            this.organismView.render = function() {
                this.el = document.createElement('li');
                return this;
            };
            this.simpleOrganismViewStub = sinon.stub(jsGA, 'OrganismSimpleView')
                .returns(this.organismView);
            this.view.render();
        });

        afterEach(function () {
            this.simpleOrganismViewStub.restore();
        });

        it('should add the organism when an organism is added to the collection', function () {
            var model = new Backbone.Model;
            model.set({chromosome: [1]});
            this.collection.add(model);
            expect($(this.view.el).find('li').length).toEqual(2);
        });

        it('should remove the organism when an organism is removed from the collection', function () {
            var model = this.collection.at(0);
            this.collection.remove(model);
            expect($(this.view.el).find('li').length).toEqual(0);
        });
    });

    describe('Rendering', function () {
        beforeEach(function () {
            this.organismView = new Backbone.View;
            this.organismView.render = function() {
                this.el = document.createElement('li');
                return this;
            };
            this.organismViewRenderSpy = sinon.spy(this.organismView, 'render');

            this.simpleOrganismViewStub = sinon.stub(jsGA, 'OrganismSimpleView')
                .returns(this.organismView);

            this.settingsView = new Backbone.View;
            this.settingsViewStub = sinon.stub(jsGA, 'PopulationSettingsView')
                .returns(this.settingsView);

            this.organism1 = new Backbone.Model;
            this.organism2 = new Backbone.Model;
            this.organism3 = new Backbone.Model;
            this.collection.reset([
                this.organism1,
                this.organism2,
                this.organism3
            ], {silent: true});
        });

        afterEach(function () {
            jsGA.OrganismSimpleView.restore();
            this.simpleOrganismViewStub.restore();
            this.settingsViewStub.restore();
        });

        it('should render a PopulationSettingsView', function () {
            var renderSpy = sinon.spy(this.settingsView, 'render');
            this.view.render();
            expect(renderSpy).toHaveBeenCalledOnce();
        });

        it('should create an OrganismSimpleView for each organism', function () {
            this.view.render();
            expect(this.simpleOrganismViewStub)
                .toHaveBeenCalledThrice();
            expect(this.simpleOrganismViewStub)
                .toHaveBeenCalledWith({model:this.organism1});
            expect(this.simpleOrganismViewStub)
                .toHaveBeenCalledWith({model:this.organism2});
            expect(this.simpleOrganismViewStub)
                .toHaveBeenCalledWith({model:this.organism3});
        });

        it('should append the OrganismSimpleView to the list', function () {
            this.view.render();
            expect($(this.view.el).find('ol').children().length).toEqual(3);
        });
    
        it("should return the view object", function() {
            expect(this.view.render()).toEqual(this.view);
        });

        describe('Controls', function () {
            beforeEach(function () {
                this.collection.stop = function () {
                };
                this.collection.run = function (steps) {
                };
                this.populationRunStub = sinon.stub(this.collection, 'run');
                this.view.render();
            });

            afterEach(function () {
                this.populationRunStub.restore();
            });

            it('should disable the run and step controls while running', function () {
                this.view.$('.step').trigger('click');
                expect(this.view.$('.step')).toBeDisabled();
                expect(this.view.$('.run')).toBeDisabled();
            });

            it('should enable the run and steps controls when stopped', function () {
                this.view.$('.step').trigger('click');
                this.view.collection.trigger('generation', 1);

                this.view.$('.stop').click();

                expect(this.view.$('.step')).not.toBeDisabled();
                expect(this.view.$('.run')).not.toBeDisabled();
            });

            it('should enable the run and steps controls when finished running', function () {
                this.view.$('.step').trigger('click');
                this.view.collection.trigger('generation', 0);

                expect(this.view.$('.step')).not.toBeDisabled();
                expect(this.view.$('.run')).not.toBeDisabled();
            });

            it('should count down the number of remaining steps', function () {
                this.view.$('input.steps').val('6');
                this.view.$('.step').trigger('click');
                this.view.collection.trigger('generation', 5);

                expect(this.view.$('input.steps').val()).toEqual('5');
            });

            it('should run a single generation when an element with a step class' +
            ' is clicked', function () {
                this.view.$('.step').trigger('click');
                expect(this.populationRunStub)
                    .toHaveBeenCalledOnce();
                expect(this.populationRunStub)
                    .toHaveBeenCalledWithExactly();
            });

            it('should run several generations when an element with the run class' +
            ' is clicked and a number is in an input with the steps class',
            function () {
                this.view.$('input.steps').val('3');
                this.view.$('.run').trigger('click');
                expect(this.populationRunStub)
                    .toHaveBeenCalledOnce();
                expect(this.populationRunStub)
                    .toHaveBeenCalledWithExactly(3);
            });

            it('should show a message if the run element is clicked without a' +
            ' number entered', function () {
                this.view.$('input.steps').val('');
                this.view.$('.run').trigger('click');
                expect(this.populationRunStub.called).toBeFalsy();
                expect(this.view.$('.error').length).toEqual(1);
            });
        });

    });
});
