// -*- coding: utf-8 -*-
// vim:ff=unix:nowrap:tabstop=4:shiftwidth=4:softtabstop=4:smarttab:shiftround:expandtab
(function () {
"use strict";

jsGA = this.jsGA = this.jsGA || {};

jsGA.OrganismSimpleView = Backbone.View.extend({
    tagName: 'li',
    className: 'organism simple',
    events: {
        'click': 'showDetails'
    },

    initialize: function () {
        _.bindAll(this, 'showDetails');
    },

    render: function () {
        $(this.el).text(JSON.stringify(this.model.get('chromosome')));
        $(this.el).attr('id', this.model.cid);
        var vis = new jsGA.ChromosomeVisualization(this.el);
        vis.addChromosome(this.model.get('chromosome'), this.model.get('bases'));
        vis.render();

        return this;
    },

    showDetails: function () {
        window.router.navigate('organism/' + this.model.cid, true);
    }
});

}).call(this);
