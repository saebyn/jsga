// -*- coding: utf-8 -*-
// vim:ff=unix:nowrap:tabstop=4:shiftwidth=4:softtabstop=4:smarttab:shiftround:expandtab
describe('Chromosome visualization', function () {
    beforeEach(function () {
        setFixtures(sandbox({class: 'organism simple'}));
        this.vis = new jsGA.ChromosomeVisualization('.organism.simple');
        this.vis.addChromosome([1, 1], [1, 2, 3]);
        this.vis.render();
    });
});
