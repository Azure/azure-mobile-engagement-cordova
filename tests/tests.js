/*
 * Copyright (c) Microsoft Corporation.  All rights reserved.
 * Licensed under the MIT license. See License.txt in the project root for license information.
 */

exports.defineAutoTests = function () {

    describe('AzureEngagement Object', function () {

        it('AzureEngagement should exist', function () {
            expect(AzureEngagement).toBeDefined();
        });

        it('AzureEngagement should contain a startActivity function', function () {
            expect(AzureEngagement.startActivity).toBeDefined();
            expect(typeof AzureEngagement.startActivity == 'function').toBe(true);
        });

        it('AzureEngagement should contain a endActivity function', function () {
            expect(AzureEngagement.endActivity).toBeDefined();
            expect(typeof AzureEngagement.endActivity == 'function').toBe(true);
        });

        it('AzureEngagement should contain a sendAppInfo function', function () {
            expect(AzureEngagement.sendAppInfo).toBeDefined();
            expect(typeof AzureEngagement.sendAppInfo == 'function').toBe(true);
        });

        it('AzureEngagement should contain a startJob function', function () {
            expect(AzureEngagement.startJob).toBeDefined();
            expect(typeof AzureEngagement.startJob == 'function').toBe(true);
        });

        it('AzureEngagement should contain a endJob function', function () {
            expect(AzureEngagement.endJob).toBeDefined();
            expect(typeof AzureEngagement.endJob == 'function').toBe(true);
        });

        it('AzureEngagement should contain a onOpenURL function', function () {
            expect(AzureEngagement.onOpenURL).toBeDefined();
            expect(typeof AzureEngagement.onOpenURL == 'function').toBe(true);
        });

        it('AzureEngagement should contain a handleOpenURL function', function () {
            expect(AzureEngagement.handleOpenURL).toBeDefined();
            expect(typeof AzureEngagement.handleOpenURL == 'function').toBe(true);
        });

        it('AzureEngagement should contain a getStatus function', function () {
            expect(AzureEngagement.getStatus).toBeDefined();
            expect(typeof AzureEngagement.getStatus == 'function').toBe(true);
        });
    });

    describe('Plugin Methods', function() {

        var info;
        beforeEach(function(done) {
            AzureEngagement.getStatus(function(_info) {
                info = _info;
                done();
            });
        });

        it('AzureEngagement plugin version should be the same as the js plugin version', function () {
            expect(info.pluginVersion).toBeDefined();
            expect(info.pluginVersion == AzureEngagement.pluginVersion).toBe(true);
        });
    });

};
