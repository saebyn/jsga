# Copyright (c) 2012 John Weaver. All Rights Reserved.
# -*- coding: utf-8 -*-
# vim:ff=unix:nowrap:tabstop=4:shiftwidth=4:softtabstop=4:smarttab:shiftround:expandtab

jsGA = this.jsGA = this.jsGA || {}

# Save the current generation, if present, to the log. Reset the collection
# with the next generation. Assumes that the existing population collection
# has an id.
jsGA.generationLog = (population, children) ->
    if population.id
        generation = _.extend({population: population.toJSON()}, {parent: population.previousId})
        window.sessionStorage[population.id] = JSON.stringify(generation)
    
    population.reset(children)
