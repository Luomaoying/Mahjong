import QtQuick 2.0
import VPlay 2.0

Item {
    id: startWindow
    width: 232
    height: 160
    // hide when opacity = 0
    visible: opacity > 0

    // disable when opacity < 1
    enabled: opacity == 1

    signal simpleClicked
    signal ordinaryClicked
    signal hardClicked
    signal aboutClicked

    FontLoader {
        id: startFont
        source: "../assets/fonts/HoneyLight.ttf"
    }
    Image {
        id: startimage
        source: "../assets/time.jpg"
        anchors.fill: parent

        Text {
            // set font
            font.family: startFont.name
            font.pixelSize: 30
            color: "white"
            text: "小鬼果子"

            // set position
            anchors.horizontalCenter: parent.horizontalCenter
            y: 72

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    startWindow.simpleClicked()
                }
            }
        }
        Text {
            // set font
            font.family: startFont.name
            font.pixelSize: 30
            color: "white"
            text: "武林大会"

            // set position
            anchors.horizontalCenter: parent.horizontalCenter
            y: 110
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    startWindow.ordinaryClicked()
                }
            }
        }
        Text {
            // set font
            font.family: startFont.name
            font.pixelSize: 30
            color: "white"
            text: "染房的秘密"

            // set position
            anchors.horizontalCenter: parent.horizontalCenter
            y: 150
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    startWindow.hardClicked()
                }
            }
        }

        Text {
            // set font
            font.family: startFont.name
            font.pixelSize: 30
            color: "#1a1a1a"
            text: "About"

            // set position
            anchors.horizontalCenter: parent.horizontalCenter
            y: 200
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    startWindow.aboutClicked()
                }
            }

            // this animation sequence changes the color of text between red and orange infinitely
            SequentialAnimation on color {
                loops: Animation.Infinite
                PropertyAnimation {
                    to: "white"
                    duration: 1000 // 1 second for fade to orange
                }
                PropertyAnimation {
                    to: "blue"
                    duration: 1000 // 1 second for fade to red
                }
            }
        }
    }

    Behavior on opacity {
        NumberAnimation {
            duration: 400
        }
    }

    function startWindowHide() {
        startWindow.opacity = 0
        startWindow.enabled = 0
    }
}
