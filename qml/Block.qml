import VPlay 2.0
import QtQuick 2.0

EntityBase {
    id: block
    entityType: "block"

    // each block knows its type and its position on the field
    property int type
    property int row
    property int column
    property int chances: 0

    // emit a signal when block is clicked
    signal clicked(int row, int column, int type)

    onChancesChanged: {
        if (chances === 1)
            chance.opacity = 1
        chance1.opacity = 1
    }

    // show different images for block types
    Image {
        id: image
        anchors.fill: parent
        source: {
            if (type == 0)
                return "../assets/小鬼果子/Apple.png"
            else if (type == 1)
                return "../assets/小鬼果子/Banana.png"
            else if (type == 2)
                return "../assets/小鬼果子/Orange.png"
            else if (type == 3)
                return "../assets/小鬼果子/Pear.png"
            else if (type == 4)
                return "../assets/小鬼果子/BlueBerry.png"
            else if (type == 5)
                return "../assets/小鬼果子/octopi_black.png"
            else if (type == 6)
                return "../assets/小鬼果子/octopi_green.png"
            else if (type == 7)
                return "../assets/小鬼果子/octopi_yellow.png"
            else if (type == 8)
                return "../assets/小鬼果子/Coconut.png"
            else if (type == 9)
                return "../assets/小鬼果子/Lemon.png"
            else if (type == 10)
                return "../assets/小鬼果子/octopi_red.png"
            else if (type == 11)
                return "../assets/小鬼果子/WaterMelon.png"
            else if (type == 12)
                return "../assets/武术/1.jpg"
            else if (type == 13)
                return "../assets/武术/2.jpg"
            else if (type == 14)
                return "../assets/武术/3.jpg"
            else if (type == 15)
                return "../assets/武术/4.jpg"
            else if (type == 16)
                return "../assets/武术/5.jpg"
            else if (type == 17)
                return "../assets/武术/6.jpg"
            else if (type == 18)
                return "../assets/武术/7.jpg"
            else if (type == 19)
                return "../assets/武术/8.jpg"
            else if (type == 20)
                return "../assets/武术/9.jpg"
            else if (type == 21)
                return "../assets/武术/10.jpg"
            else if (type == 22)
                return "../assets/武术/11.jpg"
            else if (type == 23)
                return "../assets/武术/12.jpg"
            else if (type == 24)
                return "../assets/色彩/1.jpg"
            else if (type == 25)
                return "../assets/色彩/2.jpg"
            else if (type == 26)
                return "../assets/色彩/3.jpg"
            else if (type == 27)
                return "../assets/色彩/4.jpg"
            else if (type == 28)
                return "../assets/色彩/5.jpg"
            else if (type == 29)
                return "../assets/色彩/6.jpg"
            else if (type == 30)
                return "../assets/色彩/7.jpg"
            else if (type == 31)
                return "../assets/色彩/8.jpg"
            else if (type == 32)
                return "../assets/色彩/9.jpg"
            else if (type == 33)
                return "../assets/色彩/10.jpg"
            else if (type == 34)
                return "../assets/色彩/11.jpg"
            else if (type == 35)
                return "../assets/色彩/12.jpg"
        }

        Rectangle {
            id: chance
            opacity: 0
            width: parent.width
            height: parent.height / 12
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            color: "white"
        }
        SequentialAnimation {
            id: chancerAnimation
            running: true
            loops: Animation.Infinite
            PropertyAnimation {
                target: chance
                property: "color"
                from: "blue"
                to: "white"
                duration: 1000
            }
            PropertyAnimation {
                target: chance
                property: "color"
                duration: 1000
                from: "white"
                to: "blue"
            }
        }

        Rectangle {
            id: chance1
            opacity: 0
            width: parent.width / 12
            height: parent.height

            color: "white"
        }
        SequentialAnimation {
            id: chancerAnimation1
            running: true
            loops: Animation.Infinite
            PropertyAnimation {
                target: chance1
                property: "color"
                from: "blue"
                to: "white"
                duration: 1000
            }
            PropertyAnimation {
                target: chance1
                property: "color"
                duration: 1000
                from: "white"
                to: "blue"
            }
        }
    }
    // handle click event on blocks (trigger clicked signal)
    MouseArea {
        anchors.fill: parent
        onClicked: parent.clicked(row, column, type)
    }

    Item {
        id: particleItem
        width: parent.width
        height: parent.height
        x: parent.width / 2
        y: parent.height / 2

        ParticleVPlay {
            id: sparkleParticle
            fileName: "./particles/FruitySparkle.json"
        }
        opacity: 0
        visible: opacity > 0
        enabled: opacity > 0
    }

    // fade out block before removal
    NumberAnimation {
        id: fadeOutAnimation
        target: block
        property: "opacity"
        duration: 200
        from: 1.0
        to: 0

        // remove block after fade out is finished
        onStopped: {
            sparkleParticle.stop()
            //stopDraw()
            entityManager.removeEntityById(block.entityId)
        }
    }

    // animation to let blocks fall down
    NumberAnimation {
        id: fallDownAnimation
        target: block
        property: "y"
    }

    // timer to wait for other blocks to fade out
    Timer {
        id: fallDownTimer
        interval: fadeOutAnimation.duration
        repeat: false
        running: false
        onTriggered: {
            fallDownAnimation.start()
        }
    }

    // start fade out / removal of block
    function remove() {
        particleItem.opacity = 1
        sparkleParticle.start()
        fadeOutAnimation.start()
        gamesound.playFruitClear()
    }

    // trigger fall down of block
    function fallDown(distance) {
        // complete previous fall before starting a new one
        fallDownAnimation.complete()

        // move with 100 ms per block
        // e.g. moving down 2 blocks takes 200 ms
        fallDownAnimation.duration = 100 * distance
        fallDownAnimation.to = block.y + distance * block.height

        // wait for removal of other blocks before falling down
        fallDownTimer.start()
    }
}
