import VPlay 2.0
import QtQuick 2.0
import QtMultimedia 5.0

Item {
    id: gameSound

    // game sound effects
    //    Audio {
    //        id: moveBlock
    //        source: "../../assets/sound/NFF-switchy.wav"
    //    }

    //    Audio {
    //        id: moveBlockBack
    //        source: "../assets/sound/NFF-switchy-02.wav"
    //    }
    Audio {
        id: fruitClear
        source: "../assets/NFF-fruit-collected.wav"
    }

    //    Audio {
    //        id: overloadClear
    //        source: "../../assets/sound/NFF-fruit-appearance.wav"
    //    }

    //    Audio {
    //        id: upgrade
    //        source: "../../assets/sound/NFF-upgrade.wav"
    //    }

    // text (overlay) audios
    Audio {
        id: overloadSound
        autoPlay: false
        source: "../assets/JuicyOverload.wav"
    }

    Audio {
        id: fruitySound
        autoPlay: false
        source: "../assets/Fruity.wav"
    }

    Audio {
        id: sweetSound
        autoPlay: false
        source: "../assets/Sweet.wav"
    }

    Audio {
        id: refreshingSound
        autoPlay: false
        source: "../assets/Refreshing.wav"
    }

    Audio {
        id: yummySound
        autoPlay: false
        source: "../assets/Yummy.wav"
    }

    Audio {
        id: deliciousSound
        autoPlay: false
        source: "../assets/Delicious.wav"
    }

    Audio {
        id: smoothSound
        autoPlay: false
        source: "../assets/Smooth.wav"
    }

    // functions to play sounds
    //    function playMoveBlock() {
    //        moveBlock.stop()
    //        moveBlock.play()
    //    }
    //    function playMoveBlockBack() {
    //        moveBlock.stop()
    //        moveBlockBack.play()
    //    }
    function playFruitClear() {
        fruitClear.stop()
        fruitClear.play()
    }
    //    function playOverloadClear() {
    //        overloadClear.stop()
    //        overloadClear.play()
    //    }
    //    function playUpgrade() {
    //        upgrade.stop()
    //        upgrade.play()
    //    }
    function playFruitySound() {
        fruitySound.stop()
        fruitySound.play()
    }
    function playSweetSound() {
        sweetSound.stop()
        sweetSound.play()
    }
    function playRefreshingSound() {
        refreshingSound.stop()
        refreshingSound.play()
    }
    function playOverloadSound() {
        overloadSound.stop()
        overloadSound.play()
    }
    function playYummySound() {
        yummySound.stop()
        yummySound.play()
    }
    function playDeliciousSound() {
        deliciousSound.stop()
        deliciousSound.play()
    }
    function playSmoothSound() {
        smoothSound.stop()
        smoothSound.play()
    }
}
