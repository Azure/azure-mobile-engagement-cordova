/*
 * Copyright (c) Microsoft Corporation.  All rights reserved.
 * Licensed under the MIT license. See License.txt in the project root for license information.
 */

exports.defineAutoTests = function () {

    describe('Engagement Object', function () {

        it('Engagement should exist', function () {
            expect(Engagement).toBeDefined();
        });

        it('Engagement should contain a startActivity function', function () {
            expect(Engagement.startActivity).toBeDefined();
            expect(typeof Engagement.startActivity == 'function').toBe(true);
        });

        it('Engagement should contain a endActivity function', function () {
            expect(Engagement.endActivity).toBeDefined();
            expect(typeof Engagement.endActivity == 'function').toBe(true);
        });

        it('Engagement should contain a sendAppInfo function', function () {
            expect(Engagement.sendAppInfo).toBeDefined();
            expect(typeof Engagement.sendAppInfo == 'function').toBe(true);
        });

        it('Engagement should contain a startJob function', function () {
            expect(Engagement.startJob).toBeDefined();
            expect(typeof Engagement.startJob == 'function').toBe(true);
        });

        it('Engagement should contain a endJob function', function () {
            expect(Engagement.endJob).toBeDefined();
            expect(typeof Engagement.endJob == 'function').toBe(true);
        });

        it('Engagement should contain a initializeReach function', function () {
            expect(Engagement.initializeReach).toBeDefined();
            expect(typeof Engagement.initializeReach == 'function').toBe(true);
        });

        it('Engagement should contain a handleOpenURL function', function () {
            expect(Engagement.handleOpenURL).toBeDefined();
            expect(typeof Engagement.handleOpenURL == 'function').toBe(true);
        });

        it('Engagement should contain a getStatus function', function () {
            expect(Engagement.getStatus).toBeDefined();
            expect(typeof Engagement.getStatus == 'function').toBe(true);
        });
    });

    describe('Plugin Methods', function() {

        var info;
        beforeEach(function(done) {
            Engagement.getStatus(function(_info) {
                info = _info;
                done();
            });
        });

        it('Engagement plugin version should be the same as the js plugin version', function () {
            expect(info.pluginVersion).toBeDefined();
            expect(info.pluginVersion == Engagement.pluginVersion).toBe(true);
        });
    });

};
