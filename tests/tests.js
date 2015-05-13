/*
 * Copyright (c) Microsoft Corporation.  All rights reserved.
 * Licensed under the Apache License, Version 2.0. See License.txt in the project root for license information.
 */

exports.defineAutoTests = function () {
  
    describe('AZME Object', function () {

        it("AZME should exist", function () {
            expect(AZME).toBeDefined();
        });

        it("AZME should contain a startActivity function", function () {
            expect(AZME.startActivity).toBeDefined();
            expect(typeof AZME.startActivity == 'function').toBe(true);
        });

        it("AZME should contain a endActivity function", function () {
            expect(AZME.endActivity).toBeDefined();
            expect(typeof AZME.endActivity == 'function').toBe(true);
        });

         it("AZME should contain a sendAppInfo function", function () {
            expect(AZME.sendAppInfo).toBeDefined();
            expect(typeof AZME.sendAppInfo == 'function').toBe(true);
        });     

        it("AZME should contain a startJob function", function () {
            expect(AZME.startJob).toBeDefined();
            expect(typeof AZME.startJob == 'function').toBe(true);
        });

        it("AZME should contain a endJob function", function () {
            expect(AZME.endJob).toBeDefined();
            expect(typeof AZME.endJob == 'function').toBe(true);
        });     

        it("AZME should contain a onOpenURL function", function () {
            expect(AZME.onOpenURL).toBeDefined();
            expect(typeof AZME.onOpenURL == 'function').toBe(true);
        }); 

        it("AZME should contain a handleOpenURL function", function () {
            expect(AZME.handleOpenURL).toBeDefined();
            expect(typeof AZME.handleOpenURL == 'function').toBe(true);
        });     

        it("AZME should contain a getStatus function", function () {
            expect(AZME.getStatus).toBeDefined();
            expect(typeof AZME.getStatus == 'function').toBe(true);
        });     
    });

    describe('Plugin Methods', function() {
        
        var info;
        beforeEach(function(done) {
               AZME.getStatus(function(_info) {
                    info = _info;
                    done();
                });
        });

        it("AZME plugin version should be the same as the js plugin version", function () {
                expect(info.pluginVersion).toBeDefined();
                expect(info.pluginVersion == AZME.pluginVersion).toBe(true);
        });
    });

 };