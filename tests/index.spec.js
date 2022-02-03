exports.defineAutoTests = function() {
    it('should be defined', function() {
        expect(window.plugins.Appodeal).toBeDefined()
    })

    describe('INTERSTITIAL', function() {
        var INTERSTITIAL = window.plugins.Appodeal.INTERSTITIAL

        it('should be defined', function() {
            expect(INTERSTITIAL).toBeDefined()
        })

        it('should be a number', function() {
            expect(typeof INTERSTITIAL).toBe('number')
        })

        it('should be 3', function() {
            expect(INTERSTITIAL).toBe(3)
        })
    })

    describe('BANNER', function() {
        var BANNER = window.plugins.Appodeal.BANNER

        it('should be defined', function() {
            expect(BANNER).toBeDefined()
        })

        it('should be a number', function() {
            expect(typeof BANNER).toBe('number')
        })

        it('should be 4', function() {
            expect(BANNER).toBe(4)
        })
    })

    describe('BANNER_BOTTOM', function() {
        var BANNER_BOTTOM = window.plugins.Appodeal.BANNER_BOTTOM

        it('should be defined', function() {
            expect(BANNER_BOTTOM).toBeDefined()
        })

        it('should be a number', function() {
            expect(typeof BANNER_BOTTOM).toBe('number')
        })

        it('should be 8', function() {
            expect(BANNER_BOTTOM).toBe(8)
        })
    })

    describe('BANNER_TOP', function() {
        var BANNER_TOP = window.plugins.Appodeal.BANNER_TOP

        it('should be defined', function() {
            expect(BANNER_TOP).toBeDefined()
        })

        it('should be a number', function() {
            expect(typeof BANNER_TOP).toBe('number')
        })

        it('should be 16', function() {
            expect(BANNER_TOP).toBe(16)
        })
    })

    describe('REWARDED_VIDEO', function() {
        var REWARDED_VIDEO = window.plugins.Appodeal.REWARDED_VIDEO

        it('should be defined', function() {
            expect(REWARDED_VIDEO).toBeDefined()
        })

        it('should be a number', function() {
            expect(typeof REWARDED_VIDEO).toBe('number')
        })

        it('should be 128', function() {
            expect(REWARDED_VIDEO).toBe(128)
        })
    })

    describe('NON_SKIPPABLE_VIDEO', function() {
        var NON_SKIPPABLE_VIDEO = window.plugins.Appodeal.NON_SKIPPABLE_VIDEO

        it('should be defined', function() {
            expect(NON_SKIPPABLE_VIDEO).toBeDefined()
        })

        it('should be a number', function() {
            expect(typeof NON_SKIPPABLE_VIDEO).toBe('number')
        })

        it('should be 256', function() {
            expect(NON_SKIPPABLE_VIDEO).toBe(256)
        })
    })

    describe('initialize', function() {
        var Appodeal = window.plugins.Appodeal

        it('should be defined', function() {
            expect(Appodeal.initialize).toBeDefined()
        })

        it('should be a function', function() {
            expect(typeof Appodeal.initialize).toBe('function')
        })
    })

    describe('manageConsent', function() {
        var Appodeal = window.plugins.Appodeal

        it('should be defined', function() {
            expect(Appodeal.manageConsent).toBeDefined()
        })

        it('should be a function', function() {
            expect(typeof Appodeal.manageConsent).toBe('function')
        })
    })

    describe('isInitialized', function() {
        var Appodeal = window.plugins.Appodeal

        it('should be defined', function() {
            expect(Appodeal.isInitialized).toBeDefined()
        })

        it('should be a function', function() {
            expect(typeof Appodeal.isInitialized).toBe('function')
        })
    })

    describe('setLogLevel', function() {
        var Appodeal = window.plugins.Appodeal

        it('should be defined', function() {
            expect(Appodeal.setLogLevel).toBeDefined()
        })

        it('should be a function', function() {
            expect(typeof Appodeal.setLogLevel).toBe('function')
        })
    })

    describe('setAutoCache', function() {
        var Appodeal = window.plugins.Appodeal

        it('should be defined', function() {
            expect(Appodeal.setAutoCache).toBeDefined()
        })

        it('should be a function', function() {
            expect(typeof Appodeal.setAutoCache).toBe('function')
        })
    })

    describe('canShow', function() {
        var Appodeal = window.plugins.Appodeal

        it('should be defined', function() {
            expect(Appodeal.canShow).toBeDefined()
        })

        it('should be a function', function() {
            expect(typeof Appodeal.canShow).toBe('function')
        })
    })

    describe('show', function() {
        var Appodeal = window.plugins.Appodeal

        it('should be defined', function() {
            expect(Appodeal.show).toBeDefined()
        })

        it('should be a function', function() {
            expect(typeof Appodeal.show).toBe('function')
        })
    })

    describe('showWithPlacement', function() {
        var Appodeal = window.plugins.Appodeal

        it('should be defined', function() {
            expect(Appodeal.showWithPlacement).toBeDefined()
        })

        it('should be a function', function() {
            expect(typeof Appodeal.showWithPlacement).toBe('function')
        })
    })

    describe('hasStatusBarPlugin', function() {
        var Appodeal = window.plugins.Appodeal

        it('should be defined', function() {
            expect(Appodeal.hasStatusBarPlugin).toBeDefined()
        })

        it('should be a function', function() {
            expect(typeof Appodeal.hasStatusBarPlugin).toBe('function')
        })
    })
}
