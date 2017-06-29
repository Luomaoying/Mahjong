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
    onSplashScreenFinished: scene.startGame()

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

        // background image
        BackgroundImage {
            source: "../assets/JuicyBackground.png"
            anchors.centerIn: scene.gameWindowAnchorItem
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
            onPairingSuccess: {

                if (timeBar.blood + level * 3.5 < timeBar.height) {
                    timeBar.blood += level * 3.5
                } else {
                    timeBar.blood = timeBar.height
                }
            }
        }

        Timer {
            id: reduceBloodTimer
            repeat: true
            interval: 800
            onTriggered: {
                timeBar.blood -= 9
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
                timeBar.blood = timeBar.height * 2 / 3
            }
        }

        // initialize game
        function startGame() {
            gameOverWindow.hide()
            gameArea.enabled = true
            gameArea.initializeField()
            scene.score = 0
        }
    }
}
