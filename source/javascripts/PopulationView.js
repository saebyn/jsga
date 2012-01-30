(function () {
"use strict";
// Copyright (c) 2012 John Weaver. All Rights Reserved.
// -*- coding: utf-8 -*-
// vim:ff=unix:nowrap:tabstop=4:shiftwidth=4:softtabstop=4:smarttab:shiftround:expandtab

jsGA = this.jsGA = this.jsGA || {};

jsGA.PopulationView = Backbone.View.extend({
    className: 'population',
    events: {
        'click input.step': 'step',
        'click input.run': 'run',
        'click input.stop': 'stop'
    },

    initialize: function (options) {
        options = options || {};
        _.bindAll(this, 'step', 'run', 'stop');
        this.collection.bind('add', this.renderOrganisms, this);
        this.collection.bind('remove', this.renderOrganisms, this);
        this.collection.bind('change', this.renderOrganisms, this);
        this.collection.bind('reset', this.renderOrganisms, this);
        this.collection.bind('generation', this.updateSteps, this);
        this.template = _.template(options.template || $('#population-view-template').html());
    },

    render: function () {
        $('.topbar .nav li').removeClass('active');
        $('.topbar .nav a[href="#"]').parents('li').addClass('active');
        $(this.el).html(this.template());
        this.renderOrganisms();
        var settingsView = new jsGA.PopulationSettingsView({model: this.collection.settings});
        $(this.el).append(settingsView.render().el);
        return this;
    },

    renderOrganisms: function () {
        this.$('ol').html('');
        this.collection.each(this.addOrganism, this);
    },

    updateSteps: function (remaining) {
        if ( remaining === 0 ) {
            this.enableControls();
        }

        this.$('input.steps').val(remaining);
    },

    addOrganism: function (organism) {
        var view = new jsGA.OrganismSimpleView({
            model: organism
        });
        this.$('ol').append(view.render().el);
    },

    enableControls: function () {
        this.$('input.step, input.run').prop('disabled', false);
    },

    disableControls: function () {
        this.$('input.step, input.run').prop('disabled', true);
    },

    step: function () {
        this.disableControls();
        this.collection.run();
    },

    stop: function () {
        this.enableControls();
        this.collection.stop();
    },

    run: function () {
        var steps = parseInt(this.$('input.steps').val(), 10);
        if ( steps > 0 ) { // keeps NaN out, since any comparison to NaN is false.
            this.disableControls();
            this.collection.run(steps);
        } else {
            $(this.el).prepend('<div class="alert-message error">Invalid number of steps <a class="close" href="javascript:;">x</a></div>');
            return;
        }
    }
});

}).call(this);
