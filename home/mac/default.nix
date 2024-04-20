{
  lib,
  pkgs,
  ...
}: let
  isDarwin = pkgs.stdenv.isDarwin;
in
  lib.mkIf isDarwin {
    home.file."Library/Application Support/Rectangle/RectangleConfig.json".text = ''
      {
        "bundleId" : "com.knollsoft.Rectangle",
        "defaults" : {
          "allowAnyShortcut" : {
            "bool" : true
          },
          "almostMaximizeHeight" : {
            "float" : 0
          },
          "almostMaximizeWidth" : {
            "float" : 0
          },
          "alternateDefaultShortcuts" : {
            "bool" : false
          },
          "altThirdCycle" : {
            "int" : 0
          },
          "alwaysAccountForStage" : {
            "int" : 0
          },
          "applyGapsToMaximize" : {
            "int" : 0
          },
          "applyGapsToMaximizeHeight" : {
            "int" : 0
          },
          "attemptMatchOnNextPrevDisplay" : {
            "int" : 0
          },
          "autoMaximize" : {
            "int" : 0
          },
          "cascadeAllDeltaSize" : {
            "float" : 30
          },
          "centeredDirectionalMove" : {
            "int" : 0
          },
          "centerHalfCycles" : {
            "int" : 0
          },
          "cornerSnapAreaSize" : {
            "float" : 20
          },
          "curtainChangeSize" : {
            "int" : 0
          },
          "disabledApps" : {

          },
          "doubleClickTitleBar" : {
            "int" : 0
          },
          "doubleClickTitleBarIgnoredApps" : {

          },
          "doubleClickTitleBarRestore" : {
            "int" : 0
          },
          "dragFromStage" : {
            "int" : 0
          },
          "enhancedUI" : {
            "int" : 1
          },
          "footprintAlpha" : {
            "float" : 0.3
          },
          "footprintAnimationDurationMultiplier" : {
            "float" : 0
          },
          "footprintBorderWidth" : {
            "float" : 2
          },
          "footprintColor" : {

          },
          "footprintFade" : {
            "int" : 0
          },
          "fullIgnoreBundleIds" : {

          },
          "gapSize" : {
            "float" : 0
          },
          "hideMenubarIcon" : {
            "bool" : false
          },
          "ignoreDragSnapToo" : {
            "int" : 0
          },
          "ignoredSnapAreas" : {
            "int" : 0
          },
          "landscapeSnapAreas" : {

          },
          "launchOnLogin" : {
            "bool" : false
          },
          "minimumWindowHeight" : {
            "float" : 0
          },
          "minimumWindowWidth" : {
            "float" : 0
          },
          "missionControlDragging" : {
            "int" : 0
          },
          "missionControlDraggingAllowedOffscreenDistance" : {
            "float" : 25
          },
          "missionControlDraggingDisallowedDuration" : {
            "int" : 250
          },
          "moveCursor" : {
            "int" : 0
          },
          "moveCursorAcrossDisplays" : {
            "int" : 0
          },
          "notifiedOfProblemApps" : {
            "bool" : false
          },
          "obtainWindowOnClick" : {
            "int" : 0
          },
          "portraitSnapAreas" : {

          },
          "relaunchOpensMenu" : {
            "bool" : false
          },
          "resizeOnDirectionalMove" : {
            "bool" : false
          },
          "screenEdgeGapBottom" : {
            "float" : 0
          },
          "screenEdgeGapLeft" : {
            "float" : 0
          },
          "screenEdgeGapRight" : {
            "float" : 0
          },
          "screenEdgeGapsOnMainScreenOnly" : {
            "bool" : false
          },
          "screenEdgeGapTop" : {
            "float" : 0
          },
          "shortEdgeSnapAreaSize" : {
            "float" : 145
          },
          "showAllActionsInMenu" : {
            "int" : 0
          },
          "sixthsSnapArea" : {
            "int" : 0
          },
          "sizeOffset" : {
            "float" : 0
          },
          "snapEdgeMarginBottom" : {
            "float" : 5
          },
          "snapEdgeMarginLeft" : {
            "float" : 5
          },
          "snapEdgeMarginRight" : {
            "float" : 5
          },
          "snapEdgeMarginTop" : {
            "float" : 5
          },
          "snapModifiers" : {
            "int" : 0
          },
          "specifiedHeight" : {
            "float" : 1050
          },
          "specifiedWidth" : {
            "float" : 1680
          },
          "stageSize" : {
            "float" : 190
          },
          "subsequentExecutionMode" : {
            "int" : 0
          },
          "SUEnableAutomaticChecks" : {
            "bool" : false
          },
          "systemWideMouseDown" : {
            "int" : 0
          },
          "systemWideMouseDownApps" : {

          },
          "todo" : {
            "int" : 0
          },
          "todoApplication" : {

          },
          "todoMode" : {
            "bool" : false
          },
          "todoSidebarSide" : {
            "int" : 1
          },
          "todoSidebarWidth" : {
            "float" : 400
          },
          "traverseSingleScreen" : {
            "int" : 0
          },
          "unsnapRestore" : {
            "int" : 0
          },
          "windowSnapping" : {
            "int" : 0
          }
        },
        "shortcuts" : {
          "bottomHalf" : {
            "keyCode" : 125,
            "modifierFlags" : 1572864
          },
          "bottomLeft" : {
            "keyCode" : 123,
            "modifierFlags" : 1441792
          },
          "bottomRight" : {
            "keyCode" : 124,
            "modifierFlags" : 1441792
          },
          "center" : {
            "keyCode" : 8,
            "modifierFlags" : 1572864
          },
          "larger" : {
            "keyCode" : 124,
            "modifierFlags" : 917504
          },
          "leftHalf" : {
            "keyCode" : 123,
            "modifierFlags" : 1572864
          },
          "maximize" : {
            "keyCode" : 3,
            "modifierFlags" : 1572864
          },
          "maximizeHeight" : {
            "keyCode" : 126,
            "modifierFlags" : 917504
          },
          "nextDisplay" : {
            "keyCode" : 124,
            "modifierFlags" : 1835008
          },
          "previousDisplay" : {
            "keyCode" : 123,
            "modifierFlags" : 1835008
          },
          "reflowTodo" : {
            "keyCode" : 45,
            "modifierFlags" : 786432
          },
          "restore" : {
            "keyCode" : 51,
            "modifierFlags" : 786432
          },
          "rightHalf" : {
            "keyCode" : 124,
            "modifierFlags" : 1572864
          },
          "smaller" : {
            "keyCode" : 123,
            "modifierFlags" : 917504
          },
          "toggleTodo" : {
            "keyCode" : 11,
            "modifierFlags" : 786432
          },
          "topHalf" : {
            "keyCode" : 126,
            "modifierFlags" : 1572864
          },
          "topLeft" : {
            "keyCode" : 123,
            "modifierFlags" : 1310720
          },
          "topRight" : {
            "keyCode" : 124,
            "modifierFlags" : 1310720
          }
        },
        "version" : "82"
      }
    '';
  }
