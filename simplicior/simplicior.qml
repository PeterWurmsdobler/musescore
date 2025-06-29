//=============================================================================
//  MuseScore
//  Music Composition & Notation
//
//  The simplicior plugin that allows simplification of a score.
//
//  Copyright (c) 2025 Peter Wurmsdobler
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License version 2
//  as published by the Free Software Foundation and appearing in
//  the file LICENCE.GPL
//=============================================================================

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Window

import MuseScore 3.0
import Muse.Ui
import Muse.UiComponents

import "./src/key.js" as Key
import "./src/note.js" as Note
import "./src/helpers.js" as Helpers
import "./src/clef_optimisation.js" as ClefOptimisation

MuseScore {
    id: mainWindow
    version: "0.0.1"
    description: qsTr("A collection of measures to simplify traditional notation.")
    pluginType: "dialog"
    requiresScore: true
    title: qsTr("Simplicior Notation")
    thumbnailName: "simplicior.png"
    categoryCode: "Simplified notation"

    // Compute dimension based on content
    width: mainGrid.implicitWidth + extraLeft + extraRight
    height: mainGrid.implicitHeight + extraTop + extraBottom

    property int extraMargin: mainGrid.anchors.margins ? mainGrid.anchors.margins : 0
    property int extraTop: mainGrid.anchors.topMargin ? mainGrid.anchors.topMargin : extraMargin
    property int extraBottom: mainGrid.anchors.bottomMargin ? mainGrid.anchors.bottomMargin : extraMargin
    property int extraLeft: mainGrid.anchors.leftMargin ? mainGrid.anchors.leftMargin : extraMargin
    property int extraRight: mainGrid.anchors.rightMargin ? mainGrid.anchors.rightMargin : extraMargin

    // Simplicior properties
    property bool trebleClefOnly: true
    property real trebleClefTransitionFactor: 5.0
    property bool colourCodedNonNaturals: true
    property color flatColour: "red"
    property color sharpColour: "blue"
    property bool shapeCodedNonNaturals: true
    property string flatShape: "▲"
    property string sharpShape: "▼"
    property bool uniqueNonNaturals: false
    property string uniqueShape: "▬"
    property bool enforceEnharmonic: true
    property bool atonalSignature: true
    property bool noAccidentalSymbols: true

    function doApply() {
        console.log("Hello Simplicior");
        if (atonalSignature) {
            Key.setAtonalKeySignature();
        }
        if (trebleClefOnly) {
            var pitchesTally = ClefOptimisation.collectPitchesTally();
            var assignedClefsMap = ClefOptimisation.processPitchesTally(pitchesTally, trebleClefTransitionFactor);
            ClefOptimisation.applyAssignedClefs(assignedClefsMap);
        }
        var _flatColour = colourCodedNonNaturals ? flatColour : null;
        var _sharpColour = colourCodedNonNaturals ? sharpColour : null;
        var _flatShape = shapeCodedNonNaturals ? flatShape : (uniqueNonNaturals ? uniqueShape : null);
        var _sharpShape = shapeCodedNonNaturals ? sharpShape : (uniqueNonNaturals ? uniqueShape : null);
        var _flatOffset = uniqueNonNaturals ? 0.25 : 0;
        var _sharpOffset = uniqueNonNaturals ? -0.25 : 0;
        const config = new Note.NoteConfig(_flatColour, _sharpColour, _flatShape, _sharpShape, _flatOffset, _sharpOffset, enforceEnharmonic, noAccidentalSymbols);
        Helpers.applyToNotesInSelection(Note.processNote, config);
    }

    GridLayout {
        id: mainGrid
        columns: 2 // Two columns
        rowSpacing: 5 // Space between rows
        columnSpacing: 5 // Space between columns

        GroupBox {
            id: trebleClefOnlyGroup
            Layout.row: 0
            Layout.column: 0
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 5
            Layout.alignment: Qt.AlignTop | Qt.AlignLeft

            label: CheckBox {
                id: trebleClefOnlyCheck
                checked: trebleClefOnly
                text: qsTr("Treble Clef Only")
                onClicked: {
                    trebleClefOnly = !trebleClefOnly;
                }
            }

            ColumnLayout {
                anchors.fill: parent
                enabled: trebleClefOnly
                Text {
                    text: qsTr("Cost of transitions")
                }
                RowLayout {
                    spacing: 5
                    Text {
                        text: qsTr("0")
                    }
                    Slider {
                        id: trebleClefSlider
                        from: 0
                        to: 10
                        value: trebleClefTransitionFactor
                        stepSize: 0.1
                        onValueChanged: {
                            console.log("Slider value:", value);
                        }
                    }
                    Text {
                        text: qsTr("10")
                    }
                }
            }
        } // trebleClefOnlyGroup

        GroupBox {
            id: keyManagementGroup
            title: " " + qsTr("Keys & Notes") + " "
            Layout.row: 1
            Layout.column: 0
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 5
            Layout.alignment: Qt.AlignTop | Qt.AlignLeft

            ColumnLayout {
                CheckBox {
                    id: enforceEnharmonicCheck
                    checked: enforceEnharmonic
                    text: qsTr("Enforce Enharmonics")
                    onClicked: {
                        enforceEnharmonic = !enforceEnharmonic;
                    }
                }
                CheckBox {
                    id: atonalSignatureCheck
                    checked: atonalSignature
                    text: qsTr("Atonal Key Signature")
                    onClicked: {
                        atonalSignature = !atonalSignature;
                    }
                }
            }
        } // keyManagementGroup

        GroupBox {
            id: accidentalSymbolGroup
            title: " " + qsTr("Symbols") + " "
            Layout.row: 2
            Layout.column: 0
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 5
            Layout.alignment: Qt.AlignTop | Qt.AlignLeft

            ColumnLayout {
                CheckBox {
                    id: noAccidentalSymbolsCheck
                    checked: noAccidentalSymbols
                    text: qsTr("No flat/sharp symbols")
                    onClicked: {
                        noAccidentalSymbols = !noAccidentalSymbols;
                    }
                }
            }
        } // accidentalSymbolGroup

        GroupBox {
            id: colourCodedGroup
            Layout.row: 0
            Layout.column: 1
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 5
            Layout.alignment: Qt.AlignTop | Qt.AlignLeft

            label: CheckBox {
                id: colourCodedNonNaturalsCheck
                checked: colourCodedNonNaturals
                text: qsTr("Colour Coded Non-Naturals")
                onClicked: {
                    colourCodedNonNaturals = !colourCodedNonNaturals;
                    noAccidentalSymbolsCheck.enabled = colourCodedNonNaturals || shapeCodedNonNaturals || uniqueNonNaturals;
                    noAccidentalSymbols = noAccidentalSymbolsCheck.enabled && noAccidentalSymbols;
                }
            }

            ColumnLayout {
                anchors.fill: parent
                enabled: colourCodedNonNaturals
                ColourSelection {
                    id: colourSelectionFlat
                    title: qsTr("Flats:")
                    colour: flatColour
                    onColourChanged: {
                        flatColour = colour;
                    }
                }
                ColourSelection {
                    id: colourSelectionSharp
                    title: qsTr("Sharps:")
                    colour: sharpColour
                    onColourChanged: {
                        sharpColour = colour;
                    }
                }
            }
        } // colourCodedGroup

        GroupBox {
            id: shapeEncodedGroup
            Layout.row: 1
            Layout.column: 1
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 5
            Layout.alignment: Qt.AlignTop | Qt.AlignLeft

            label: CheckBox {
                id: shapeCodedNonNaturalsCheck
                checked: shapeCodedNonNaturals
                text: qsTr("Shape Coded Non-Naturals")
                onClicked: {
                    shapeCodedNonNaturals = !shapeCodedNonNaturals;
                    noAccidentalSymbolsCheck.enabled = colourCodedNonNaturals || shapeCodedNonNaturals || uniqueNonNaturals;
                    noAccidentalSymbols = noAccidentalSymbolsCheck.enabled && noAccidentalSymbols;
                    if (shapeCodedNonNaturals) {
                        uniqueNonNaturals = false; // Disable uniqueNonNaturals if this is enabled
                    }
                }
            }

            ColumnLayout {
                anchors.fill: parent
                enabled: shapeCodedNonNaturals
                ShapeSelection {
                    id: shapeSelectionFlat
                    title: qsTr("Flats:")
                    shape: flatShape
                    shapes: ["▲", "▼"] // List of asymetric shapes
                    onShapeChanged: {
                        flatShape = shape;
                    }
                }
                ShapeSelection {
                    id: shapeSelectionSharp
                    title: qsTr("Sharps:")
                    shape: sharpShape
                    shapes: ["▲", "▼"] // List of asymetric shapes
                    onShapeChanged: {
                        sharpShape = shape;
                    }
                }
            }
        }

        GroupBox {
            id: uniqueNonNaturalsGroup
            Layout.row: 2
            Layout.column: 1
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 5
            Layout.alignment: Qt.AlignTop | Qt.AlignLeft

            label: CheckBox {
                id: uniqueNonNaturalsCheck
                checked: uniqueNonNaturals
                text: qsTr("Unique non-natural shapes")
                onClicked: {
                    uniqueNonNaturals = !uniqueNonNaturals;
                    noAccidentalSymbolsCheck.enabled = colourCodedNonNaturals || shapeCodedNonNaturals || uniqueNonNaturals;
                    noAccidentalSymbols = noAccidentalSymbolsCheck.enabled && noAccidentalSymbols;
                    if (uniqueNonNaturals) {
                        shapeCodedNonNaturals = false; // Disable shapeCodedNonNaturals if this is enabled
                    }
                }
            }

            ColumnLayout {
                anchors.fill: parent
                enabled: uniqueNonNaturals
                ShapeSelection {
                    id: shapeSelectionUnique
                    title: qsTr("Sharps & Flats:")
                    shape: uniqueShape
                    shapes: ["◆", "▬"] // List of symetric shapes
                    onShapeChanged: {
                        uniqueShape = shape;
                    }
                }
            }
        }

        FlatButton {
            id: applyButton
            Layout.row: 3
            Layout.column: 0
            Layout.columnSpan: 2 // Span across both columns
            Layout.fillWidth: true
            Layout.margins: 5
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter

            text: qsTr("Apply")
            toolTipTitle: qsTr("Apply simplification")
            onClicked: doApply()
        }
    }
    Settings {
        id: settings
        category: "PluginSimplicior"
        property alias trebleClefOnly: mainWindow.trebleClefOnly
        property alias trebleClefTransitionFactor: mainWindow.trebleClefTransitionFactor
        property alias colourCodedNonNaturals: mainWindow.colourCodedNonNaturals
        property alias flatColour: mainWindow.flatColour
        property alias sharpColour: mainWindow.sharpColour
        property alias shapeCodedNonNaturals: mainWindow.shapeCodedNonNaturals
        property alias flatShape: mainWindow.flatShape
        property alias sharpShape: mainWindow.sharpShape
        property alias uniqueNonNaturals: mainWindow.uniqueNonNaturals
        property alias uniqueShape: mainWindow.uniqueShape
        property alias enforceEnharmonic: mainWindow.enforceEnharmonic
        property alias noAccidentalSymbols: mainWindow.noAccidentalSymbols
        property alias atonalSignature: mainWindow.atonalSignature
    }

    // Palette for nice color management
    SystemPalette {
        id: sysActivePalette
        colorGroup: SystemPalette.Active
    }
    SystemPalette {
        id: sysDisabledPalette
        colorGroup: SystemPalette.Disabled
    }
}
