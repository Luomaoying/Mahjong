import VPlay 2.0
import QtQuick 2.0

GameWindow {
    id: gameWindow

    // You get free licenseKeys from https://v-play.net/licenseKey
    // With a licenseKey you can:
    //  * Publish your games & apps for the app stores
    //  * Remove the V-Play Splash Screen or set a custom one (available with the Pro Licenses)
    //  * Add plugins to monetize, analyze & improve your apps (available with the Pro Licenses)
    // licenseKey: "<generate one from https://v-play.net/licenseKey>"
    activeScene: scene

    // the size of the Window can be changed at runtime by pressing Ctrl (or Cmd on Mac) + the number keys 1-8
    // the content of the logical scene size (480x320 for landscape mode by default) gets scaled to the window size based on the scaleMode
    // you can set this size to any resolution you would like your project to start with, most of the times the one of your main target device
    // this resolution is for iPhone 4 & iPhone 4S
    screenWidth: 640
    screenHeight: 960

    // initialiaze game when window is fully loaded
    onSplashScreenFinished: scene.startWindowShow()

    // for dynamic creation of entities
    EntityManager {
        id: entityManager
        entityContainer: gameArea
    }

    // custom font loading of ttf fonts
    FontLoader {
        id: gameFont
        source: "../assets/fonts/HoneyLight.ttf"
    }

    Scene {
        id: scene

        // the "logical size" - the scene content is auto-scaled to match the GameWindow size
        width: 320
        height: 480

        // property to hold game score
        property int score
        property int variety: 0
        signal returnStart

        // background image
        BackgroundImage {
            id: juicybackground
            source: "../assets/JuicyBackground.png"
            anchors.centerIn: scene.gameWindowAnchorItem
        }
        GameSound {
            id: gamesound
        }

        Image {
            id: grid
            source: "../assets/Grid.png"
            width: 258
            height: 378
            anchors.horizontalCenter: scene.horizontalCenter
            anchors.bottom: scene.bottom
            anchors.bottomMargin: 92
        }
        Text {
            font.family: gameFont.name
            font.pixelSize: 23
            color: "yellow"
            text: "Aha..Mahjong"
            anchors.horizontalCenter: parent.horizontalCenter
            y: 400
        }

        Text {
            // set font
            font.family: gameFont.name
            font.pixelSize: 20
            color: "green"
            text: scene.score

            // set position
            anchors.horizontalCenter: parent.horizontalCenter
            y: 440
        }

        //        focus: true
        Keys.onPressed: {

            if (event.key === Qt.Key_Control) {
                event.accepted = true
                chancerAnimation.running = 0
                chance.enabled = false
                gameArea.removeChanceLink()
                chance.color = "white"
            }
        }

        Rectangle {
            id: chance
            width: 60
            height: 25
            enabled: false
            x: 0
            y: 425
            color: "white"

            Text {
                text: "Chance"
                font.family: aboutFont.name
                font.pixelSize: 12
                anchors.centerIn: parent
                color: "grey"
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    chancerAnimation.running = 0
                    chance.enabled = false
                    gameArea.removeChanceLink()
                    chance.color = "white"
                }
            }
            Keys.onPressed: {
                if (envent.key === Qt.Key_Control) {
                    chancerAnimation.running = 0
                    chance.enabled = false
                    gameArea.removeChanceLink()
                    chance.color = "white"
                }
            }
        }
        SequentialAnimation {
            id: chancerAnimation
            running: false
            loops: Animation.Infinite
            PropertyAnimation {
                target: chance
                property: "color"
                from: "yellow"
                to: "white"
                duration: 1000
            }
            PropertyAnimation {
                target: chance
                property: "color"
                duration: 1000
                from: "white"
                to: "yellow"
            }
        }

        FontLoader {
            id: aboutFont
            source: "../assets/fonts/HoneyLight.ttf"
        }

        Text {
            id: returnstart

            text: "go back"
            font.family: aboutFont.name
            font.pixelSize: 13
            x: 0
            y: 450
            color: "white"
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    scene.returnStart()
                }
            }

            SequentialAnimation on color {
                loops: Animation.Infinite
                PropertyAnimation {
                    to: "#878787"
                    duration: 500
                }
                PropertyAnimation {
                    to: "black"
                    duration: 500
                }
            }
        }

        onReturnStart: {
            scene.startWindowShow()
        }

        // game area holds game field with blocks
        GameArea {
            id: gameArea
            anchors.horizontalCenter: scene.horizontalCenter
            y: 20
            blockSize: 30
            onInitialize: reduceBloodTimer.start()
            onGameOver: {
                gameOverWindow.show()
                gameArea.enabled = false
                reduceBloodTimer.stop()
            }
            onChance: {
                chance.enabled = 1
                chancerAnimation.running = true
            }
            onPairingSuccess: {

                if (timeBar.blood + level * 3.5 < timeBar.height) {
                    timeBar.blood += level * 3.5
                } else {
                    timeBar.blood = timeBar.height
                }
            }
            onCalculatescore: {
                scene.score = grade.calculate(totalscore, levell)
                console.log(scene.score)
            }
        }

        Timer {
            id: reduceBloodTimer
            repeat: true
            interval: 900
            onTriggered: {
                timeBar.blood -= 7
            }
        }

        // Time bar
        TimeBar {
            id: timeBar
            anchors.verticalCenter: grid.verticalCenter
            anchors.right: grid.left
            width: 9
            height: gameArea.height * 2 / 3
            onBloodEmpty: {
                gameOverWindow.show()
                gameArea.enabled = false
                reduceBloodTimer.stop()
            }
        }
        GameOverWindow {
            id: gameOverWindow
            y: 120
            opacity: 0 // by default the window is hidden
            anchors.horizontalCenter: scene.horizontalCenter
            onNewGameClicked: {
                scene.startGame()
                gameOverWindow.hide()
            }
            onReturnStartMenue: {
                scene.startWindowShow()
            }
        }

        StartWindow {
            id: startwindow
            anchors.horizontalCenter: scene.horizontalCenter
            anchors.fill: parent
            onSimpleClicked: {
                gamesound.playMoveBlock()
                scene.variety = 0
                juicybackground.source = "../assets/JuicyBackground.png"
                scene.startGame()
            }
            onOrdinaryClicked: {
                gamesound.playMoveBlock()
                scene.variety = 1
                juicybackground.source = "../assets/森林.jpg"
                scene.startGame(scene.variety)
            }
            onHardClicked: {
                gamesound.playMoveBlock()
                scene.variety = 2
                juicybackground.source = "../assets/森林1.jpg"
                scene.startGame(scene.variety)
            }
            onAboutClicked: {
                aboutGame.show()
                startwindow.opacity = 0
            }
        }

        About {
            id: aboutGame
            anchors.fill: parent
            onHome: {
                scene.startWindowShow()
                aboutGame.hide()
            }
        }
        // initialize game
        function startGame() {
            gamesound.playStart1()

            chance.opacity = 1
            gameArea.enabled = true
            gameArea.opacity = 1
            console.log(scene.variety)
            gameArea.initializeField(scene.variety)
            console.log(scene.variety)
            scene.score = 0

            chancerAnimation.running = 0
            chance.enabled = false
            chance.color = "white"

            timeBar.blood = timeBar.height * 2 / 3
            startwindow.startWindowHide()
            grid.opacity = 1
            juicybackground.opacity = 1
            timeBar.opacity = 1
        }
        function startWindowShow() {
            gamesound.playStart()

            chance.opacity = 0
            startwindow.opacity = 1
            startwindow.enabled = 1
            gameArea.opacity = 0
            grid.opacity = 0
            juicybackground.opacity = 0
            timeBar.opacity = 0
        }
    }
}
