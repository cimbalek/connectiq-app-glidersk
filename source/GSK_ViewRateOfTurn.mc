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
using Toybox.Attention as Attn;
using Toybox.Graphics as Gfx;
using Toybox.Position as Pos;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.System as Sys;
using Toybox.WatchUi as Ui;

class GSK_ViewRateOfTurn extends Ui.View {

  //
  // VARIABLES
  //

  // Display mode (internal)
  private var bShow;

  // Resources
  // ... fonts
  private var oRezFontMeter;
  private var oRezFontStatus;
  // ... strings
  private var sValueActivityStandby;
  private var sValueActivityRecording;
  private var sValueActivityPaused;


  //
  // FUNCTIONS: Ui.View (override/implement)
  //

  function initialize() {
    View.initialize();

    // Display mode
    // ... internal
    self.bShow = false;
  }

  function onLayout(_oDC) {
    // No layout; see drawLayout() below
  }

  function onShow() {
    //Sys.println("DEBUG: GSK_ViewRateOfTurn.onShow()");

    // Load resources
    // ... fonts
    self.oRezFontMeter = Ui.loadResource(Rez.Fonts.fontMeter);
    self.oRezFontStatus = Ui.loadResource(Rez.Fonts.fontStatus);
    // ... strings
    self.sValueActivityStandby = Ui.loadResource(Rez.Strings.valueActivityStandby);
    self.sValueActivityRecording = Ui.loadResource(Rez.Strings.valueActivityRecording);
    self.sValueActivityPaused = Ui.loadResource(Rez.Strings.valueActivityPaused);

    // Reload settings (which may have been changed by user)
    App.getApp().loadSettings();

    // Unmute tones
    App.getApp().unmuteTones(GSK_App.TONES_SAFETY);

    // Done
    self.bShow = true;
    $.GSK_oCurrentView = self;
    return true;
  }

  function onUpdate(_oDC) {
    //Sys.println("DEBUG: GSK_ViewRateOfTurn.onUpdate()");

    // Update layout
    View.onUpdate(_oDC);
    self.drawLayout(_oDC);

    // Done
    return true;
  }

  function onHide() {
    //Sys.println("DEBUG: GSK_ViewRateOfTurn.onHide()");
    $.GSK_oCurrentView = null;
    self.bShow = false;

    // Mute tones
    App.getApp().muteTones();

    // Free resources
    // ... fonts
    self.oRezFontMeter = null;
    self.oRezFontStatus = null;
    // ... strings
    self.sValueActivityStandby = null;
    self.sValueActivityRecording = null;
    self.sValueActivityPaused = null;
  }


  //
  // FUNCTIONS: self
  //

  function updateUi() {
    //Sys.println("DEBUG: GSK_ViewRateOfTurn.updateUi()");

    // Request UI update
    if(self.bShow) {
      Ui.requestUpdate();
    }
  }


  //
  // FUNCTIONS: self (cont'd) - layout-specific
  //

  (:layout_240x240)
  function drawLayout(_oDC) {
    // Draw background
    _oDC.setPenWidth(120);

    // ... background
    _oDC.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
    _oDC.clear();

    // ... rate of turn
    var fValue;
    _oDC.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_DK_GRAY);
    _oDC.drawArc(120, 120, 60, Gfx.ARC_COUNTER_CLOCKWISE, 285, 255);
    _oDC.setColor($.GSK_oSettings.iGeneralBackgroundColor, $.GSK_oSettings.iGeneralBackgroundColor);
    _oDC.drawArc(120, 120, 60, Gfx.ARC_CLOCKWISE, 285, 255);
    fValue = $.GSK_oSettings.iGeneralDisplayFilter >= 1 ? $.GSK_oProcessing.fRateOfTurn_filtered : $.GSK_oProcessing.fRateOfTurn;
    if(fValue != null and $.GSK_oProcessing.iAccuracy > Pos.QUALITY_NOT_AVAILABLE) {
      if(fValue > 0.0f) {
        //var iAngle = (fValue * 900.0f/Math.PI).toNumber();  // ... range 6 rpm <-> 36 °/s
        var iAngle = (fValue * 286.4788975654f).toNumber();
        if(iAngle != 0) {
          if(iAngle > 165) { iAngle = 165; }  // ... leave room for unit text
          _oDC.setColor(Gfx.COLOR_GREEN, Gfx.COLOR_GREEN);
          _oDC.drawArc(120, 120, 60, Gfx.ARC_CLOCKWISE, 90, 90-iAngle);
        }
      }
      else if(fValue < 0.0f) {
        //var iAngle = -(fValue * 900.0f/Math.PI).toNumber();  // ... range 6 rpm <-> 36 °/s
        var iAngle = -(fValue * 286.4788975654f).toNumber();
        if(iAngle != 0) {
          if(iAngle > 165) { iAngle = 165; }  // ... leave room for unit text
          _oDC.setColor(Gfx.COLOR_RED, Gfx.COLOR_RED);
          _oDC.drawArc(120, 120, 60, Gfx.ARC_COUNTER_CLOCKWISE, 90, 90+iAngle);
        }
      }
    }

    // ... text
    _oDC.setColor($.GSK_oSettings.iGeneralBackgroundColor, $.GSK_oSettings.iGeneralBackgroundColor);
    _oDC.fillCircle(120, 100, 90);

    // Draw non-position values
    var sValue;

    // ... battery
    _oDC.setColor($.GSK_oSettings.iGeneralBackgroundColor ? Gfx.COLOR_DK_GRAY : Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
    sValue = Lang.format("$1$%", [Sys.getSystemStats().battery.format("%.0f")]);
    _oDC.drawText(120, 128, self.oRezFontStatus, sValue, Gfx.TEXT_JUSTIFY_CENTER);

    // ... activity
    if($.GSK_Activity_oSession == null) {  // ... stand-by
      _oDC.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
      sValue = self.sValueActivityStandby;
    }
    else if($.GSK_Activity_oSession.isRecording()) {  // ... recording
      _oDC.setColor(Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT);
      sValue = self.sValueActivityRecording;
    }
    else {  // ... paused
      _oDC.setColor(Gfx.COLOR_YELLOW, Gfx.COLOR_TRANSPARENT);
      sValue = self.sValueActivityPaused;
    }
    _oDC.drawText(120, 55, self.oRezFontStatus, sValue, Gfx.TEXT_JUSTIFY_CENTER);

    // ... time
    var oTimeNow = Time.now();
    var oTimeInfo = $.GSK_oSettings.bUnitTimeUTC ? Gregorian.utcInfo(oTimeNow, Time.FORMAT_SHORT) : Gregorian.info(oTimeNow, Time.FORMAT_SHORT);
    sValue = Lang.format("$1$$2$$3$ $4$", [oTimeInfo.hour.format("%02d"), oTimeNow.value() % 2 ? "." : ":", oTimeInfo.min.format("%02d"), $.GSK_oSettings.sUnitTime]);
    _oDC.setColor($.GSK_oSettings.iGeneralBackgroundColor ? Gfx.COLOR_BLACK : Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
    _oDC.drawText(120, 142, Gfx.FONT_MEDIUM, sValue, Gfx.TEXT_JUSTIFY_CENTER);

    // Draw position values

    // ... heading
    fValue = $.GSK_oSettings.iGeneralDisplayFilter >= 2 ? $.GSK_oProcessing.fHeading_filtered : $.GSK_oProcessing.fHeading;
    if(fValue != null and $.GSK_oProcessing.iAccuracy > Pos.QUALITY_NOT_AVAILABLE) {
      //fValue = ((fValue * 180.0f/Math.PI).toNumber()) % 360;
      fValue = ((fValue * 57.2957795131f).toNumber()) % 360;
      sValue = fValue.format("%.0f");
    }
    else {
      sValue = $.GSK_NOVALUE_LEN3;
    }
    _oDC.drawText(120, 22, Gfx.FONT_MEDIUM, Lang.format("$1$°", [sValue]), Gfx.TEXT_JUSTIFY_CENTER);

    // ... rate of turn
    fValue = $.GSK_oSettings.iGeneralDisplayFilter >= 1 ? $.GSK_oProcessing.fRateOfTurn_filtered : $.GSK_oProcessing.fRateOfTurn;
    if(fValue != null and $.GSK_oProcessing.iAccuracy > Pos.QUALITY_NOT_AVAILABLE) {
      fValue *= $.GSK_oSettings.fUnitRateOfTurnCoefficient;
      if($.GSK_oSettings.iUnitRateOfTurn == 1) {
        sValue = fValue.format("%+.1f");
        if(fValue >= 0.05f) {
          _oDC.setColor($.GSK_oSettings.iGeneralBackgroundColor ? Gfx.COLOR_DK_GREEN : Gfx.COLOR_GREEN, Gfx.COLOR_TRANSPARENT);
        }
        else if(fValue <= -0.05f) {
          _oDC.setColor(Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT);
        }
      }
      else {
        sValue = fValue.format("%+.0f");
        if(fValue >= 0.5f) {
          _oDC.setColor($.GSK_oSettings.iGeneralBackgroundColor ? Gfx.COLOR_DK_GREEN : Gfx.COLOR_GREEN, Gfx.COLOR_TRANSPARENT);
        }
        else if(fValue <= -0.5f) {
          _oDC.setColor(Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT);
        }
      }
    }
    else {
      sValue = $.GSK_NOVALUE_LEN3;
    }
    _oDC.drawText(120, 63, self.oRezFontMeter, sValue, Gfx.TEXT_JUSTIFY_CENTER);
    _oDC.setColor($.GSK_oSettings.iGeneralBackgroundColor ? Gfx.COLOR_BLACK : Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
    _oDC.drawText(120, 200, Gfx.FONT_TINY, $.GSK_oSettings.sUnitRateOfTurn, Gfx.TEXT_JUSTIFY_CENTER);
  }
}

class GSK_ViewRateOfTurnDelegate extends GSK_ViewGlobalDelegate {

  function initialize() {
    GSK_ViewGlobalDelegate.initialize();
  }

  function onPreviousPage() {
    //Sys.println("DEBUG: GSK_ViewRateOfTurnDelegate.onPreviousPage()");
    Ui.switchToView(new GSK_ViewSafety(), new GSK_ViewSafetyDelegate(), Ui.SLIDE_IMMEDIATE);
    return true;
  }

  function onNextPage() {
    //Sys.println("DEBUG: GSK_ViewRateOfTurnDelegate.onNextPage()");
    Ui.switchToView(new GSK_ViewVariometer(), new GSK_ViewVariometerDelegate(), Ui.SLIDE_IMMEDIATE);
    return true;
  }

}
