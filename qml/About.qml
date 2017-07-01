import QtQuick 2.0

Item {
    id: about
    opacity: 0
    enabled: false
    signal home
    FontLoader {
        id: aboutFont
        source: "../assets/fonts/HoneyLight.ttf"
    }

    FontLoader {
        id: aboutFont1
        source: "../assets/fonts/ani.ttf"
    }

    Rectangle {
        id: aboutimage
        color: "#2F4F4F"
        anchors.fill: parent
    }

    Text {
        id: aboutText
        font.family: aboutFont1.name
        text: "game rules:
The game has three difficulty choices,
the number of bricks to distinguish.
The mouse click on the two bricks quickly,
how many points will increase the
complexity of the two blocks as the criteria,
next to the same blood.
"
        font.pixelSize: 15
        color: "#CAFF70"
        anchors.fill: parent
        x: 20
        y: 300
    }
    Text {
        id: returnstart

        text: "home"
        font.family: aboutFont.name
        font.pixelSize: 25
        x: 10
        y: 400
        color: "white"
        MouseArea {
            anchors.fill: parent
            onClicked: {
                home()
            }
        }

        SequentialAnimation on color {
            loops: Animation.Infinite
            PropertyAnimation {
                to: "white"
                duration: 1000 // 1 second for fade to orange
            }
            PropertyAnimation {
                to: "#218868"
                duration: 1000 // 1 second for fade to red
            }
        }
    }
    function show() {
        about.opacity = 1
        about.enabled = 1
    }
    function hide() {
        about.opacity = 0
        about.enabled = false
    }
}
