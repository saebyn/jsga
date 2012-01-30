(function () {
"use strict";
// Copyright (c) 2012 John Weaver. All Rights Reserved.
// -*- coding: utf-8 -*-
// vim:ff=unix:nowrap:tabstop=4:shiftwidth=4:softtabstop=4:smarttab:shiftround:expandtab

jsGA = this.jsGA = this.jsGA || {};

jsGA.OrganismView = Backbone.View.extend({
    events: {
        'click .close': 'close'
    },

    className: 'organism',

    initialize: function (options) {
        options = options || {};
        _.bindAll(this, 'close');
        this.template = _.template(options.template || $('#organism-template').html());
    },

    render: function () {
        if ( this.model ) {
            $(this.el).attr('id', this.model.cid);

            $(this.el).html(this.template({model: this.model}));
            var vis = new jsGA.ChromosomeVisualization(this.$('.vis'), 250, 250);
            vis.addChromosome(this.model.get('chromosome'), this.model.get('bases'));
            vis.render()
        } else {
            $(this.el).html('<div class="alert-message error">Does not exist.</div>');
        }

        return this;
    },

    close: function () {
        this.remove();
        window.router.navigate('', false);
    }
});

}).call(this);
