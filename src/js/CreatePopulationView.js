// -*- coding: utf-8 -*-
// vim:ff=unix:nowrap:tabstop=4:shiftwidth=4:softtabstop=4:smarttab:shiftround:expandtab
(function () {
"use strict";

jsGA = this.jsGA = this.jsGA || {};

jsGA.CreatePopulationView = Backbone.View.extend({
    events: {
        'click .create': 'create',
        'change #selection-elitism-enabled': 'toggleElitism',
        'change #selection-mechanism': 'updateMechanismOptions'
    },
    tagName: 'div',
    className: 'creator',

    initialize: function (options) {
        options = options || {};
        _.bindAll(this, 'create', 'toggleElitism', 'updateMechanismOptions');
        this.model = this.model || new jsGA.PopulationSettings;
        this.template = _.template(options.template || $('#population-create-template').html());
    },

    clearFormError: function (selector) {
        this.$('.alert-message.error').fadeOut();
        this.$(selector).removeClass('error');
        this.$(selector).parents('.clearfix').removeClass('error');
    },

    setFormError: function (selector, message) {
        $(this.el).prepend('<div class="alert-message error">' + message + ' <a class="close" href="javascript:;">x</a></div>');
        this.$(selector).addClass('error');
        this.$(selector).parents('.clearfix').addClass('error');
    },

    bindFormField: function (selector, event, field, filter) {
        filter = filter || function (a) { return a; };

        var self = this;
        this.model.bind('change:' + field, function (model, val) {
            self.clearFormError(selector);
            self.$(selector).val(val);
        });

        this.$(selector).bind(event, function (ev) {
            var data = {};
            data[field] = filter(self.$(ev.target).val());
            self.model.set(data, {error: function (model, message) {
                self.$(selector).val(self.model.get(field));
                self.setFormError(selector, message);
            }});
        });

        this.$(selector).val(this.model.get(field));
    },

    render: function () {
        $('.topbar .nav li').removeClass('active');
        $('.topbar .nav a[href="#create"]').parents('li').addClass('active');
        $(this.el).html(this.template());
        this.bindFormField('#population-size', 'change', 'size',
                           function (a) { return parseInt(a, 10); });
        this.bindFormField('#selection-mechanism', 'change', 'selectionMechanism');
        this.bindFormField('#tournament-size', 'change', 'tournamentSize',
                           function (a) { return parseInt(a, 10); });
        this.bindFormField('#selection-elitism', 'change', 'elitism',
                           function (a) { return parseFloat(a); });
        this.bindFormField('#crossover-probability', 'change', 'crossoverProbability',
                           function (a) { return parseFloat(a); });
        this.bindFormField('#mutation-probability', 'change', 'mutationProbability',
                           function (a) { return parseFloat(a); });
        this.bindFormField('#fitness-function', 'change', 'fitness');
        return this;
    },

    updateMechanismOptions: function () {
        // hide everything first
        $('.optional').hide();

        // unset all optional settings
        this.model.unset('tournamentSize');

        if ( $('#selection-mechanism').val() === 'tournament' ) {
            // cause the model to update and show the field
            $('#tournament-size').change().parents('.optional').show();
        }
    },

    toggleElitism: function () {
        var checked = this.$('#selection-elitism-enabled').prop('checked');
        this.$('#selection-elitism').prop('disabled', !checked);
        if ( !checked ) {
            this.model.set({elitism: 0.0});
        }
    },

    create: function () {
        this.collection.reset();

        this.collection.seed(this.model);
        window.router.navigate('', true);
    }
});

}).call(this);
