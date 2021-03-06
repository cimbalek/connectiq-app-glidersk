// -*- mode:java; tab-width:2; c-basic-offset:2; intent-tabs-mode:nil; -*- ex: set tabstop=2 expandtab:

// Glider's Swiss Knife (GliderSK)
// Copyright (C) 2017-2018 Cedric Dufour <http://cedric.dufour.name>
//
// Glider's Swiss Knife (GliderSK) is free software:
// you can redistribute it and/or modify it under the terms of the GNU General
// Public License as published by the Free Software Foundation, Version 3.
//
// Glider's Swiss Knife (GliderSK) is distributed in the hope that it will be
// useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
//
// See the GNU General Public License for more details.
//
// SPDX-License-Identifier: GPL-3.0
// License-Filename: LICENSE/GPL-3.0.txt

using Toybox.Application as App;
using Toybox.Graphics as Gfx;
using Toybox.Position as Pos;
using Toybox.WatchUi as Ui;

class PickerDestinationLoad extends Ui.Picker {

  //
  // FUNCTIONS: Ui.Picker (override/implement)
  //

  function initialize() {
    // Destination memory
    var aiMemoryKeys = new [$.GSK_STORAGE_SLOTS];
    var asMemoryValues = new [$.GSK_STORAGE_SLOTS];
    var afMemoryDistances = new [$.GSK_STORAGE_SLOTS];
    var iMemoryUsed = 0;
    for(var n=0; n<$.GSK_STORAGE_SLOTS; n++) {
      var s = n.format("%02d");
      var dictDestination = App.Storage.getValue(Lang.format("storDest$1$", [s]));
      if(dictDestination != null) {
        aiMemoryKeys[iMemoryUsed] = n;
        if($.GSK_oPositionLocation != null) {  // ... we have a current position
          var oMemoryLocation = new Pos.Location({ :latitude => dictDestination["latitude"], :longitude => dictDestination["longitude"], :format => :degrees });
          asMemoryValues[iMemoryUsed] = dictDestination["name"];
          afMemoryDistances[iMemoryUsed] = LangUtils.distance($.GSK_oPositionLocation.toRadians(), oMemoryLocation.toRadians());
        }
        else {  // ... we have no current position
          asMemoryValues[iMemoryUsed] = Lang.format("[$1$]\n$2$", [s, dictDestination["name"]]);
          afMemoryDistances[iMemoryUsed] = 0.0f;
        }
        iMemoryUsed++;
      }
    }

    // Sort according to distance (nearest first)
    var aiMemoryKeys_sorted = null;
    var asMemoryValues_sorted = null;
    if(iMemoryUsed > 0) {
      aiMemoryKeys = aiMemoryKeys.slice(0, iMemoryUsed);
      asMemoryValues = asMemoryValues.slice(0, iMemoryUsed);
      afMemoryDistances = afMemoryDistances.slice(0, iMemoryUsed);
      if($.GSK_oPositionLocation != null) {  // ... we have a current position
        // Sort destination per increasing distance from current location
        var aiMemoryIndices_sorted = LangUtils.sort(afMemoryDistances);
        aiMemoryKeys_sorted = new [iMemoryUsed];
        asMemoryValues_sorted = new [iMemoryUsed];

        for(var i=0; i<iMemoryUsed; i++) {
          aiMemoryKeys_sorted[i] = aiMemoryKeys[aiMemoryIndices_sorted[i]];
          asMemoryValues_sorted[i] = Lang.format("($1$$2$)\n$3$", [(afMemoryDistances[i]*$.GSK_oSettings.fUnitDistanceCoefficient).format("%.0f"), $.GSK_oSettings.sUnitDistance, asMemoryValues[aiMemoryIndices_sorted[i]]]);
        }
      }
      else {  // ... we have no current position
        // Keep destination ordered as per memory slot number
        aiMemoryKeys_sorted = aiMemoryKeys;
        asMemoryValues_sorted = asMemoryValues;
      }
    }

    // Initialize picker
    var oPattern;
    if(iMemoryUsed > 0) {
      oPattern = new PickerFactoryDictionary(aiMemoryKeys_sorted, asMemoryValues_sorted, { :font => Gfx.FONT_TINY });
    }
    else {
      oPattern = new PickerFactoryDictionary([null], ["-"], { :color => Gfx.COLOR_DK_GRAY });
    }
    Picker.initialize({
      :title => new Ui.Text({ :text => Ui.loadResource(Rez.Strings.titleDestinationLoad), :font => Gfx.FONT_TINY, :locX=>Ui.LAYOUT_HALIGN_CENTER, :locY=>Ui.LAYOUT_VALIGN_BOTTOM, :color => Gfx.COLOR_BLUE }),
      :pattern => [ oPattern ]
    });
  }

}

class PickerDestinationLoadDelegate extends Ui.PickerDelegate {

  //
  // FUNCTIONS: Ui.PickerDelegate (override/implement)
  //

  function initialize() {
    PickerDelegate.initialize();
  }

  function onAccept(_amValues) {
    // Load destination
    if(_amValues[0] != null) {
      // Get property (destination memory)
      var s = _amValues[0].format("%02d");
      var dictDestination = App.Storage.getValue(Lang.format("storDest$1$", [s]));

      // Set property
      // WARNING: We MUST store a new (different) dictionary instance (deep copy)!
      App.Storage.setValue("storDestInUse", LangUtils.copy(dictDestination));
    }

    // Exit
    Ui.popView(Ui.SLIDE_IMMEDIATE);
  }

  function onCancel() {
    // Exit
    Ui.popView(Ui.SLIDE_IMMEDIATE);
  }

}
