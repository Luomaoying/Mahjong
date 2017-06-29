import VPlay 2.0
import QtQuick 2.0

Item {
    id: timeBar
    property double blood: height * 2 / 3
    property string color1: "#ffff00"
    property string color2: "#ffaa00"
    signal bloodFull
    signal bloodEmpty

    Behavior on blood {
        NumberAnimation {
            duration: 500
        }
    }
    onBloodChanged: {
        if (blood <= 0) {
            bloodEmpty()
        } else if (blood >= bar.height) {
            bloodFull()
        }

    }

    Rectangle {
        id: barBorder
        width: bar.width + 2
        height: bar.height + 4
        anchors.right: bar.right
        color: "white"
    }

    Rectangle {
        id: bar
        width: parent.width
        height: parent.height
        anchors.centerIn: parent
        color: "#cccccc"
    }
    Rectangle {
        id: timeBarLevel
        width: bar.width
        height: blood
        anchors.horizontalCenter: bar.horizontalCenter
        anchors.bottom: bar.bottom
        color: timeBar.color2
    }

    // juciy meter animation
    SequentialAnimation {
        id: timeBarAnimation
        running: true
        loops: Animation.Infinite
        PropertyAnimation {
            target: timeBarLevel
            property: "color"
            from: timeBar.color1
            to: timeBar.color2
            duration: 700
        }
        PropertyAnimation {
            target: timeBarLevel
            property: "color"
            duration: 700
            from: timeBar.color2
            to: timeBar.color1
        }
    }

}
