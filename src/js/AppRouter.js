// -*- coding: utf-8 -*-
// vim:ff=unix:nowrap:tabstop=4:shiftwidth=4:softtabstop=4:smarttab:shiftround:expandtab
(function () {
"use strict";

jsGA = this.jsGA = this.jsGA || {};

jsGA.AppRouter = Backbone.Router.extend({
    routes: {
        '': 'index',
        'create': 'createPopulation',
        'organism/:id': 'viewOrganism',
    },
          
    initialize: function (optioins) {
        this.population = new jsGA.Population;
    },

    index: function() {
        if ( this.population.length <= 0 ) {
            this.navigate('create', true);
            return;
        }

        this.populationView = new jsGA.PopulationView({
            collection: this.population
        });
        $('#main').html(this.populationView.render().el);
        $('#side').html('');
    },

    createPopulation: function() {
        this.createPopulationView = new jsGA.CreatePopulationView({
            collection: this.population
        });
        $('#main').html(this.createPopulationView.render().el);
        $('#side').html('');
    },

    viewOrganism: function (id) {
        this.organismView = new jsGA.OrganismView({
            model: this.population.getByCid(id)
        });
        $('#side').html(this.organismView.render().el);
    }
});

}).call(this);
