// Copyright (c) 2012 John Weaver. All Rights Reserved.
// -*- coding: utf-8 -*-
// vim:ff=unix:nowrap:tabstop=4:shiftwidth=4:softtabstop=4:smarttab:shiftround:expandtab
(function () {
"use strict";

jsGA = this.jsGA = this.jsGA || {};

jsGA.CreatePopulationView = Backbone.View.extend({
    events: {
        'click .create': 'create',
        'change #selection-elitism-enabled': 'toggleElitism',
        'change #selection-mechanism': 'updateMechanismOptions',
        'click .load': 'loadSavedSettings'
    },
    tagName: 'div',
    className: 'creator',

    initialize: function (options) {
        options = options || {};
        _.bindAll(this, 'create', 'toggleElitism', 'updateMechanismOptions', 'loadSavedSettings');
        this.model = this.model || new jsGA.PopulationSettings;
        this.existingSettings = new jsGA.PopulationSettingsCollection();
        this.existingSettings.fetch();
        this.template = _.template(options.template || $('#population-create-template').html());
    },

    loadSavedSettings: function () {
        var id = this.$('#load-settings').val();
        if ( id ) {
            this.model.set(this.existingSettings.get(id).toJSON());
        }
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

    setField: function (jqe, val) {
      if ( jqe.attr('type') === 'checkbox' || jqe.attr('type') === 'radio' ) {
          jqe.prop('checked', false);
          jqe.filter('[value="' + val + '"]').prop('checked', true).change();
      } else {
          jqe.val(val).change();
      }
    },

    getField: function (jqe) {
      return jqe.val();
    },

    bindFormField: function (selector, event, field, filter, outfilter) {
        filter = filter || _.identity;
        outfilter = outfilter || _.identity;

        var self = this;
        this.model.bind('change:' + field, function (model, val) {
            self.clearFormError(selector);
            self.setField(self.$(selector), outfilter(val));
            if ( field === 'elitism' ) {
                $('#selection-elitism-enabled').prop('checked', val > 0).change();
            }
        });

        this.$(selector).bind(event, function (ev) {
            var data = {};
            data[field] = filter(self.getField(self.$(ev.target)));
            self.model.set(data, {error: function (model, message) {
                self.setField(self.$(selector), outfilter(self.model.get(field)));
                self.setFormError(selector, message);
            }});
        });

        this.setField(this.$(selector), outfilter(this.model.get(field)));
    },

    render: function () {
        $('.topbar .nav li').removeClass('active');
        $('.topbar .nav a[href="#create"]').parents('li').addClass('active');
        $(this.el).html(this.template({
            existingSettings: this.existingSettings
        }));
        this.bindFormField('#population-size', 'change', 'size',
                           function (a) { return parseInt(a, 10); });
        this.bindFormField('#selection-mechanism', 'change', 'selectionMechanism');
        this.bindFormField('#tournament-size', 'change', 'tournamentSize',
                           function (a) { return parseInt(a, 10); });
        this.bindFormField('#chromosome-length', 'change', 'chromosomeLength',
                           function (a) { return parseInt(a, 10); });
        this.bindFormField('input[name="chromosome-bases"]', 'change', 'bases',
                           function (baseType) {
                               if ( baseType === 'binary' ) {
                                   return [0, 1];
                               }
                           }, function (bases) {
                               if ( _.isEqual(bases, [0, 1]) ) {
                                   return 'binary';
                               }
                           });
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
