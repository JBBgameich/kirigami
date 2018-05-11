/*
 *   Copyright 2015 Marco Martin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2 or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Library General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 2.4
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.0 as Controls
import org.kde.kirigami 2.4 as Kirigami

Kirigami.ScrollablePage {
    id: page
    Layout.fillWidth: true
    title: "Long List view"

    actions {
        main: Kirigami.Action {
            iconName: sheet.sheetOpen ? "dialog-cancel" : "document-edit"
            text: "Main Action Text"
            checkable: true
            onCheckedChanged: sheet.sheetOpen = checked;
        }
    }

    //Close the drawer with the back button
    onBackRequested: {
        if (sheet.sheetOpen) {
            event.accepted = true;
            sheet.close();
        }
    }

    supportsRefreshing: true
    onRefreshingChanged: {
        if (refreshing) {
            refreshRequestTimer.running = true;
        } else {
            showPassiveNotification("Example refreshing completed")
        }
    }

    background: Rectangle {
        color: Kirigami.Theme.backgroundColor
    }
    Kirigami.OverlaySheet {
        id: sheet
        onSheetOpenChanged: page.actions.main.checked = sheetOpen;
        parent: applicationWindow().overlay
        header: Kirigami.Heading {
            text: "Title"
        }
        footer: RowLayout {
            Controls.Label {
                text: "Footer:"
            }
            Controls.TextField {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignCenter
            }
        }
        ListView {
            model: 100
            implicitWidth: Kirigami.Units.gridUnit * 30
            delegate: Kirigami.BasicListItem {
                label: "Item in sheet" + modelData
            }
        }
    }

    Component {
        id: delegateComponent
        Kirigami.SwipeListItem {
            id: listItem
            contentItem: RowLayout {
MouseArea {
    drag {
        target: listItem
        axis: Drag.YAxis
    }
    Rectangle {
        anchors.fill: parent
        color: "red"
    }
    preventStealing: true
    Layout.minimumWidth: 20
    Layout.maximumWidth: 20
    Layout.minimumHeight: 20

    property int startY
    property int mouseDownY
    property Item originalParent
    
    property int currentIndex: index

    onPressed: {
        originalParent = listItem.parent;
        listItem.parent = page;
        listItem.y = originalParent.mapToItem(listItem.parent, listItem.x, listItem.y).y;
        listItem.z = 99;
        startY = listItem.y;
        mouseDownY = mouse.y;
    }
onParentChanged:print("EEE"+parent)
    onPositionChanged: {
        var newIndex = mainList.indexAt(1, mainList.contentItem.mapFromItem(listItem, 0, 0).y + mouseDownY);

        if (Math.abs(listItem.y - startY) > height && newIndex > -1 && newIndex != index) {
            print(index+" "+newIndex)
            listModel.move(index, newIndex, 1)
        }
    }onClicked: listModel.move(index, index-1, 1)
    onReleased: {
        listItem.z = 0;
        listItem.parent = originalParent;
        listItem.y = 0;
        
    }
}

                Controls.Label {
                    height: Math.max(implicitHeight, Kirigami.Units.iconSizes.smallMedium)
                    text: "Item " + model.title
                    color: listItem.checked || (listItem.pressed && !listItem.checked && !listItem.sectionDelegate) ? listItem.activeTextColor : listItem.textColor
                }
            }
            actions: [
                Kirigami.Action {
                    iconName: "document-decrypt"
                    text: "Action 1"
                    onTriggered: showPassiveNotification(model.text + " Action 1 clicked")
                },
                Kirigami.Action {
                    iconName: "mail-reply-sender"
                    text: "Action 2"
                    onTriggered: showPassiveNotification(model.text + " Action 2 clicked")
                }]
        }
    }
    ListView {
        id: mainList
        Timer {
            id: refreshRequestTimer
            interval: 3000
            onTriggered: page.refreshing = false
        }
        model: ListModel {
            id: listModel

            Component.onCompleted: {
                for (var i = 0; i < 200; ++i) {
                    listModel.append({"title": "Item " + i,
                        "actions": [{text: "Action 1", icon: "document-decrypt"},
                                    {text: "Action 2", icon: "mail-reply-sender"}]
                    })
                }
            }
        }
        moveDisplaced: Transition {
            NumberAnimation {
                property: "y"
                duration: Kirigami.Units.longDuration
            }
        }
        delegate: Kirigami.DelegateRecycler {
            width: parent ? parent.width : implicitWidth
            sourceComponent: delegateComponent
        }
    }
}
