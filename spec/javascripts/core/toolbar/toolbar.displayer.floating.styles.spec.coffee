# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
require ["core/toolbar/toolbar.floating.displayer.styles", "jquery.custom"], (Styles, $) ->
  describe "Toolbar.Floating.Displayer.Styles", ->
    
    $container = $el = $floater = null
    beforeEach ->
      $container = $("<div/>").prependTo("body")
      $el = $("<div>text</div>").appendTo($container)
      $floater = $('<div style="display:none">floater</div>').appendTo($container)

    afterEach ->
      $container.remove()

    describe "#top", ->
      it "sets the floater absolutely above the el when there is space at the top", ->
        styles = new Styles($el, $floater)
        spyOn(styles, "doesFloaterFit").andReturn(true)
        spyOn(styles, "elCoords").andReturn(top: 200)
        spyOn(styles, "floaterSize").andReturn(y: 50)
        spyOn(styles, "x").andReturn(left: 100)

        top = styles.top()
        expect(top.position).toEqual("absolute")
        expect(top.top).toEqual(150)
        expect(top.left).toEqual(100)

      it "sets the floater fixed at the top when there is not enough space at the top", ->
        styles = new Styles($el, $floater)
        spyOn(styles, "doesFloaterFit").andReturn(false)
        spyOn(styles, "topFixed").andReturn(position: "fixed")
        spyOn(styles, "x").andReturn(left: 100)

        top = styles.top()
        expect(styles.topFixed).toHaveBeenCalled()
        expect(top.position).toEqual("fixed")
        expect(top.left).toEqual(100)

    describe "#bottom", ->
      it "sets the floater absolutely below the el when there is space at the bottom", ->
        styles = new Styles($el, $floater)
        spyOn(styles, "doesFloaterFit").andReturn(true)
        spyOn(styles, "elCoords").andReturn(bottom: 200)
        spyOn(styles, "x").andReturn(left: 100)
        bottom = styles.bottom()
        expect(bottom.position).toEqual("absolute")
        expect(bottom.top).toEqual(200)
        expect(bottom.left).toEqual(100)

      it "sets the floater fixed at the bottom given there is not enough space at the bottom", ->
        styles = new Styles($el, $floater)
        spyOn(styles, "doesFloaterFit").andReturn(false)
        spyOn(styles, "bottomFixed").andReturn(position: "fixed")
        spyOn(styles, "x").andReturn(left: 100)
        bottom = styles.bottom()
        expect(styles.bottomFixed).toHaveBeenCalled()
        expect(bottom.position).toEqual("fixed")
        expect(bottom.left).toEqual(100)

    describe "#x", ->
      it "is centered to the el when the floater shows up inside the window", ->
        styles = new Styles($el, $floater)
        spyOn(styles, "floaterSize").andReturn(x: 200)
        spyOn(styles, "elCoords").andReturn(left: 20)
        x = styles.x()
        expect(x.left).toEqual(20)

      it "is against the left side of the window when the floater shows up outside the left part of the window", ->
        styles = new Styles($el, $floater)
        spyOn(styles, "floaterSize").andReturn(x: 200)
        spyOn(styles, "elCoords").andReturn(left: 0, width: 100)
        x = styles.x()
        expect(x.left).toEqual(0)

      it "is against the right side of the window when the floater shows up outside the right part of the window", ->
        windowWidth = $(window).getSize().x
        styles = new Styles($el, $floater)
        spyOn(styles, "floaterSize").andReturn(x: 200)
        spyOn(styles, "elCoords").andReturn(left: windowWidth - 100, width: 100)
        x = styles.x()
        expect(x.left).toEqual(windowWidth - 200)

    describe "#spaceBetweenElAndWindow", ->
      describe "given where is set to top", ->
        it "returns a positive number when the el is below the window top", ->
          styles = new Styles($el, $floater)
          spyOn(styles, "elCoords").andReturn(top: 200)
          expect(styles.spaceBetweenElAndWindow("top")).toEqual(200)

        it "returns a negative number when the el is above the window top", ->
          $spacer = $('<div style="height:9999px;">spacer</div>').appendTo($container)
          window.scrollTo(0, 200)

          styles = new Styles($el, $floater)
          spyOn(styles, "elCoords").andReturn(top: 0)
          expect(styles.spaceBetweenElAndWindow("top")).toEqual(-200)

          window.scrollTo(0, 0)

      describe "given where is set to bottom", ->
        it "returns a positive number when the el is above the window bottom", ->
          styles = new Styles($el, $floater)
          spyOn(styles, "elCoords").andReturn(bottom: 10)
          expect(styles.spaceBetweenElAndWindow("bottom")).toEqual($(window).getSize().y - 10)

        it "returns a negative number when the el is below the window bottom", ->
          styles = new Styles($el, $floater)
          spyOn(styles, "elCoords").andReturn(bottom: 9999)
          expect(styles.spaceBetweenElAndWindow("bottom")).toEqual($(window).getSize().y - 9999)

    describe "#doesFloaterFit", ->
      it "returns true when the floater fits", ->
        styles = new Styles($el, $floater)
        spyOn(styles, "floaterSize").andReturn(y: 50)
        spyOn(styles, "spaceBetweenElAndWindow").andReturn(100)
        expect(styles.doesFloaterFit("top")).toBeTruthy()

      it "returns false when the floater does not fit", ->
        styles = new Styles($el, $floater)
        spyOn(styles, "floaterSize").andReturn(y: 50)
        spyOn(styles, "spaceBetweenElAndWindow").andReturn(0)
        expect(styles.doesFloaterFit("top")).toBeFalsy()

    describe "#topFixed", ->
        it "absolutely positions the floater to the top of the window", ->
          $spacer = $('<div style="height:9999px;">spacer</div>').appendTo($container)
          window.scrollTo(0, 100)

          styles = new Styles($el, $floater)
          top = styles.topFixed()
          if isIE
            expect(top.position).toEqual("absolute")
            expect(top.top).toEqual(100)
          else
            expect(top.position).toEqual("fixed")
            expect(top.top).toEqual(0)

          window.scrollTo(0, 0)

      describe "#bottomFixed", ->
        it "absolutely positions the floater to the bottom of the window", ->
          $spacer = $('<div style="height:9999px;">spacer</div>').appendTo($container)
          window.scrollTo(0, 200)

          windowHeight = $(window).getSize().y

          styles = new Styles($el, $floater)
          spyOn(styles, "floaterSize").andReturn(y: 50)
          bottom = styles.bottomFixed()
          if isIE
            expect(bottom.position).toEqual("absolute")
            expect(bottom.top).toEqual(windowHeight + 200 - 50)
          else
            expect(bottom.position).toEqual("fixed")
            expect(bottom.top).toEqual(windowHeight - 50)

          window.scrollTo(0, 0)
