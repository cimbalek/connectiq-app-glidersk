// -*- mode:java; tab-width:2; c-basic-offset:2; intent-tabs-mode:nil; -*- ex: set tabstop=2 expandtab:

// Glider's Swiss Knife (GliderSK)
// Copyright (C) 2017 Cedric Dufour <http://cedric.dufour.name>
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
using Toybox.WatchUi as Ui;

// NOTE: Since Ui.Confirmation does not allow to pre-select "Yes" as an answer,
//       let's us our own "confirmation" menu and save one key press
class MenuDestinationEditFromCurrent extends Ui.Menu {

  //
  // FUNCTIONS: Ui.Menu (override/implement)
  //

  function initialize() {
    Menu.initialize();
    Menu.setTitle(Ui.loadResource(Rez.Strings.menuConfirm));
    Menu.addItem(Lang.format("$1$ ?", [Ui.loadResource(Rez.Strings.menuDestinationFromCurrent)]), :confirm);
  }

}

class MenuDelegateDestinationEditFromCurrent extends Ui.MenuInputDelegate {

  //
  // FUNCTIONS: Ui.MenuInputDelegate (override/implement)
  //

  function initialize() {
    MenuInputDelegate.initialize();
  }

  function onMenuItem(item) {
    if (item == :confirm and $.GSK_PositionLocation != null and $.GSK_PositionAltitude != null) {
      // Update destination (dictionary) with current location/altitude
      var dictDestination = App.getApp().getProperty("storDestInUse");
      if(dictDestination == null) {
        dictDestination = { "name" => "----", "latitude" => 0.0f, "longitude" => 0.0f, "elevation" => 0.0f };
      }
      dictDestination["name"] = "????";
      dictDestination["latitude"] = $.GSK_PositionLocation.toDegrees()[0];
      dictDestination["longitude"] = $.GSK_PositionLocation.toDegrees()[1];
      dictDestination["elevation"] = $.GSK_PositionAltitude;
      App.getApp().setProperty("storDestInUse", dictDestination);
    }
  }

}