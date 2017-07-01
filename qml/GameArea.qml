import VPlay 2.0
import QtQuick 2.0

Item {
    id: gameArea

    // shall be a multiple of the blockSize
    // the game field is 8 columns by 12 rows big
    width: blockSize * 8
    height: blockSize * 12

    // properties for game area configuration
    property double blockSize
    property int rows: Math.floor(height / blockSize)
    property int columns: Math.floor(width / blockSize)

    // properties for increasing game difficulty
    property int maxTypes: 12
    property int types
    property var imageNumber: [7, 7, 8, 7, 7, 8, 7, 7, 7, 7, 7, 7]

    // array for handling game field
    property var field: []
    property var link: [99, 99]
    property int linkIndex: 0
    property int linelevel: 0
    property var point: []
    property var lucky: []
    property var chanceLink: []

    // gameover signal
    signal gameOver
    signal pairingSuccess(int level)
    signal initialize
    signal chance
    signal calculatescore(int totalscore, int levell)

    Rectangle {
        id: rectangle
        color: "yellow"
        opacity: 0
    }
    Rectangle {
        id: rectangle2
        color: "yellow"
        opacity: 0
    }
    Rectangle {
        id: rectangle3
        color: "yellow"
        opacity: 0
    }

    Timer {
        id: timer
        interval: 350
        running: true
        repeat: true
        onTriggered: {
            rectangle.opacity = 0
            rectangle2.opacity = 0
            rectangle3.opacity = 0
        }
    }

    // calculate field index
    function index(row, column) {
        return row * columns + column
    }

    // fill game field with blocks
    function initializeField(varietyy) {
        // reset difficulty
        gameArea.types = 12
        gameArea.imageNumber = [7, 7, 8, 7, 7, 8, 7, 7, 7, 7, 7, 7]

        gameArea.lucky = [Math.floor(Math.random(
                                         ) * gameArea.rows * gameArea.columns), Math.floor(Math.random() * gameArea.rows * gameArea.columns), Math.floor(Math.random() * gameArea.rows * gameArea.columns)]
        // clear field
        clearField()

        // fill field
        for (var i = 0; i < rows; i++) {
            for (var j = 0; j < columns; j++) {
                if (i === j || (rows - i) === (columns - j)) {
                    gameArea.field[index(i, j)] = null
                } else {
                    gameArea.field[index(i, j)] = createBlock(i, j, varietyy)
                }
            }
        }
        initialize()
    }

    // clear game field
    function clearField() {
        // remove entities
        for (var i = 0; i < gameArea.field.length; i++) {
            var block = gameArea.field[i]
            if (block !== null) {
                entityManager.removeEntityById(block.entityId)
            }
        }
        gameArea.field = []
    }

    // create a new block at specific position
    function createBlock(row, column, varietyyy) {
        // configure block
        var entityProperties = {
            width: blockSize,
            height: blockSize,
            x: column * blockSize,
            y: row * blockSize,
            type: imageSet(varietyyy),
            row// random type
            : row,
            column: column,
            chances: islucky(row, column)
        }

        // add block to game area
        var id = entityManager.createEntityFromUrlWithProperties(
                    Qt.resolvedUrl("Block.qml"), entityProperties)

        // link click signal from block to handler function
        var entity = entityManager.getEntityById(id)
        entity.clicked.connect(handleClick)

        return entity
    }

    function islucky(row, column) {
        for (var i = 0; i !== 3; i++) {
            if (lucky[i] === index(row, column))
                return 1
        }
        return 0
    }

    function imageSet(varietyyyy) {
        var types = varietyyyy * maxTypes + Math.floor(Math.random(
                                                           ) * gameArea.types)
        if (imageNumber[types - varietyyyy * maxTypes] !== 0) {
            imageNumber[types - varietyyyy * maxTypes]--
            return types
        } else {
            return imageSet(varietyyyy)

            //            for (var i = types + 1; i !== maxTypes; i++) {
            //                if (imageNumber[i] !== 0) {
            //                    imageNumber[i]--
            //                    return i
            //                }
            //            }
            //            for (i = types - 1; i !== 0; i--) {
            //                if (imageNumber[i] !== 0) {
            //                    imageNumber[i]--
            //                    return i
            //                }
            //            }
        }
    }

    // handle user clicks
    function handleClick(row, column, type) {

        var fieldCopy = gameArea.field.slice()
        link[linkIndex] = index(row, column)
        if (linkIndex === 0) {
            if (link[1] !== 99) {
                if (fieldCopy[link[1]].type === type
                        && (fieldCopy[link[1]].row !== row
                            || fieldCopy[link[1]].column !== column)
                        && checkNoBarrier(fieldCopy[link[1]].row,
                                          fieldCopy[link[1]].column, row,
                                          column)) {
                    if (linelevel !== 0) {
                        timer.restart()
                        if (linelevel === 1) {
                            drawline1(point[0], point[1], point[2], point[3])
                            rectangle2.opacity = 0
                            rectangle3.opacity = 0
                        } else if (linelevel === 2) {
                            drawline1(point[0], point[1], point[2], point[3])
                            drawline2(point[4], point[5], point[2], point[3])
                            rectangle3.opacity = 0
                        } else {
                            drawline1(point[0], point[1], point[2], point[3])
                            drawline2(point[4], point[5], point[2], point[3])
                            drawline3(point[4], point[5], point[6], point[7])
                        }

                        //                        scene.score += 350 * linelevel
                        calculatescore(scene.score, linelevel)
                        pairingSuccess(linelevel)

                        if (fieldCopy[link[0]].chances === 1
                                || fieldCopy[link[1]].chances === 1)
                            chance()
                        var block = gameArea.field[link[0]]
                        gameArea.field[link[0]] = null
                        block.remove()
                        link[0] = 99

                        block = gameArea.field[link[1]]
                        gameArea.field[link[1]] = null
                        block.remove()
                        link[1] = 99
                    } else
                        linkIndex = 1
                } else
                    linkIndex = 1
            } else
                linkIndex = 1
        } else {
            if (link[0] !== 99) {
                if (fieldCopy[link[0]].type === type
                        && (fieldCopy[link[0]].row !== row
                            || fieldCopy[link[0]].column !== column)
                        && checkNoBarrier(fieldCopy[link[0]].row,
                                          fieldCopy[link[0]].column, row,
                                          column)) {
                    if (linelevel !== 0) {
                        timer.restart()
                        if (linelevel === 1) {
                            drawline1(point[0], point[1], point[2], point[3])
                            rectangle2.opacity = 0
                            rectangle3.opacity = 0
                        } else if (linelevel === 2) {
                            drawline1(point[0], point[1], point[2], point[3])
                            drawline2(point[4], point[5], point[2], point[3])
                            rectangle3.opacity = 0
                        } else {
                            drawline1(point[0], point[1], point[2], point[3])
                            drawline2(point[4], point[5], point[2], point[3])
                            drawline3(point[4], point[5], point[6], point[7])
                        }
                        // scene.score += 350 * linelevel
                        gameArea.calculatescore(scene.score, linelevel)
                        pairingSuccess(linelevel)

                        if (fieldCopy[link[0]].chances === 1
                                || fieldCopy[link[1]].chances === 1)
                            chance()
                        block = gameArea.field[link[0]]
                        gameArea.field[link[0]] = null
                        block.remove()
                        link[0] = 99

                        block = gameArea.field[link[1]]
                        gameArea.field[link[1]] = null
                        block.remove()
                        link[1] = 99
                    } else
                        linkIndex = 0
                } else
                    linkIndex = 0
            } else
                linkIndex = 0
        }

        // emit signal if game is over
        if (isGameOver())
            gameOver()
    }
    // check two blocks whether they can link
    function checkNoBarrier(row1, col1, row2, col2) {
        if (row1 === row2 || col1 === col2) {
            if (!zeroTurningPoint(row1, col1, row2, col2)) {
                if (threeTurningPoint(row1, col1, row2, col2)) {
                    linelevel = 3
                    return true
                }
            } else {

                linelevel = 1
                point = [row1, col1, row2, col2]
                return true
            }
        } else {
            if (!twoTurningPoint(row1, col1, row2, col2)) {
                if (threeTurningPoint(row1, col1, row2, col2)) {
                    linelevel = 3
                    return true
                }
            } else {
                linelevel = 2
                return true
            }
        }
        linelevel = 0
        return false
    }
    function drawline1(row1, col1, row2, col2) {
        if ((row1 === row2) || (col1 === col2)) {
            if ((row1 === row2) && (col1 !== col2)) {
                if (col1 < col2) {
                    rectangle.width = (col2 - col1) * blockSize
                    rectangle.height = 1
                    rectangle.opacity = 1
                    rectangle.x = col1 * blockSize + blockSize / 2
                    rectangle.y = row1 * blockSize + blockSize / 2
                } else {
                    rectangle.width = (col1 - col2) * blockSize
                    rectangle.height = 1
                    rectangle.opacity = 1
                    rectangle.x = col2 * blockSize + blockSize / 2
                    rectangle.y = row2 * blockSize + blockSize / 2
                }
            }
            if ((row1 !== row2) && (col1 === col2)) {
                if (row1 < row2) {
                    rectangle.width = 1
                    rectangle.height = (row2 - row1) * blockSize
                    rectangle.opacity = 1
                    rectangle.x = col1 * blockSize + blockSize / 2
                    rectangle.y = row1 * blockSize + blockSize / 2
                } else {
                    rectangle.width = 1
                    rectangle.height = (row1 - row2) * blockSize
                    rectangle.opacity = 1
                    rectangle.x = col2 * blockSize + blockSize / 2
                    rectangle.y = row2 * blockSize + blockSize / 2
                }
            }
        }
    }

    function drawline2(row1, col1, row2, col2) {
        if ((row1 === row2) || (col1 === col2)) {
            if ((row1 === row2) && (col1 !== col2)) {
                if (col1 < col2) {
                    rectangle2.width = (col2 - col1) * blockSize
                    rectangle2.height = 1
                    rectangle2.opacity = 1
                    rectangle2.x = col1 * blockSize + blockSize / 2
                    rectangle2.y = row1 * blockSize + blockSize / 2
                } else {
                    rectangle2.width = (col1 - col2) * blockSize
                    rectangle2.height = 1
                    rectangle2.opacity = 1
                    rectangle2.x = col2 * blockSize + blockSize / 2
                    rectangle2.y = row2 * blockSize + blockSize / 2
                }
            }
            if ((row1 !== row2) && (col1 === col2)) {
                if (row1 < row2) {
                    rectangle2.width = 1
                    rectangle2.height = (row2 - row1) * blockSize
                    rectangle2.opacity = 1
                    rectangle2.x = col1 * blockSize + blockSize / 2
                    rectangle2.y = row1 * blockSize + blockSize / 2
                } else {
                    rectangle2.width = 1
                    rectangle2.height = (row1 - row2) * blockSize
                    rectangle2.opacity = 1
                    rectangle2.x = col2 * blockSize + blockSize / 2
                    rectangle2.y = row2 * blockSize + blockSize / 2
                }
            }
        }
    }
    function drawline3(row1, col1, row2, col2) {
        if ((row1 === row2) || (col1 === col2)) {
            if ((row1 === row2) && (col1 !== col2)) {
                if (col1 < col2) {
                    rectangle3.width = (col2 - col1) * blockSize
                    rectangle3.height = 1
                    rectangle3.opacity = 1
                    rectangle3.x = col1 * blockSize + blockSize / 2
                    rectangle3.y = row1 * blockSize + blockSize / 2
                } else {
                    rectangle3.width = (col1 - col2) * blockSize
                    rectangle3.height = 1
                    rectangle3.opacity = 1
                    rectangle3.x = col2 * blockSize + blockSize / 2
                    rectangle3.y = row2 * blockSize + blockSize / 2
                }
            }
            if ((row1 !== row2) && (col1 === col2)) {
                if (row1 < row2) {
                    rectangle3.width = 1
                    rectangle3.height = (row2 - row1) * blockSize
                    rectangle3.opacity = 1
                    rectangle3.x = col1 * blockSize + blockSize / 2
                    rectangle3.y = row1 * blockSize + blockSize / 2
                } else {
                    rectangle3.width = 1
                    rectangle3.height = (row1 - row2) * blockSize
                    rectangle3.opacity = 1
                    rectangle3.x = col2 * blockSize + blockSize / 2
                    rectangle3.y = row2 * blockSize + blockSize / 2
                }
            }
        }
    }

    //with two turning point
    function twoTurningPoint(row1, col1, row2, col2) {

        if (((zeroTurningPoint(row1, col1, row1, col2))
             && (zeroTurningPoint(row1, col2, row2,
                                  col2)) && (gameArea.field[index(
                                                                row1, col2)] === null))) {
            point = [row1, col1, row1, col2, row2, col2]
            return true
        } else if (((zeroTurningPoint(row1, col1, row2, col1))
                    && (zeroTurningPoint(row2, col1, row2,
                                         col2)) && (gameArea.field[index(
                                                                       row2, col1)] === null))) {
            point = [row1, col1, row2, col1, row2, col2]
            return true
        }

        return false
    }

    //with three turning point
    function threeTurningPoint(row1, col1, row2, col2) {
        for (var i = row1 + 1; i < rows && i >= 0
             && gameArea.field[index(i, col1)] === null; i++) {
            for (var a = row2 + 1; a < rows && a >= 0
                 && gameArea.field[index(a, col2)] === null; a++) {
                if (zeroTurningPoint(i, col1, a, col2)) {
                    point = [row1, col1, i, col1, a, col2, row2, col2]
                    return true
                }
            }
            for (var b = row2 - 1; b < rows && b >= 0
                 && gameArea.field[index(b, col2)] === null; b--) {
                if (zeroTurningPoint(i, col1, b, col2)) {
                    point = [row1, col1, i, col1, b, col2, row2, col2]
                    return true
                }
            }
            for (var c = col2 + 1; c < columns && c >= 0
                 && gameArea.field[index(row2, c)] === null; c++) {
                if (zeroTurningPoint(i, col1, row2, c)) {
                    return true
                }
            }
            for (var d = col2 - 1; d < columns && d >= 0
                 && gameArea.field[index(row2, d)] === null; d--) {
                if (zeroTurningPoint(i, col1, row2, d))
                    return true
            }
        }

        for (i = row1 - 1; i < rows && i >= 0
             && gameArea.field[index(i, col1)] === null; i--) {
            for (a = row2 + 1; a < rows && a >= 0
                 && gameArea.field[index(a, col2)] === null; a++) {
                if (zeroTurningPoint(i, col1, a, col2)) {
                    point = [row1, col1, i, col1, a, col2, row2, col2]
                    return true
                }
            }
            for (b = row2 - 1; b < rows && b >= 0
                 && gameArea.field[index(b, col2)] === null; b--) {
                if (zeroTurningPoint(i, col1, b, col2)) {
                    point = [row1, col1, i, col1, b, col2, row2, col2]
                    return true
                }
            }
            for (c = col2 + 1; c < columns && c >= 0
                 && gameArea.field[index(row2, c)] === null; c++) {
                if (zeroTurningPoint(i, col1, row2, c))
                    return true
            }
            for (d = col2 - 1; d < columns && d >= 0
                 && gameArea.field[index(row2, d)] === null; d--) {
                if (zeroTurningPoint(i, col1, row2, d))
                    return true
            }
        }

        for (i = col1 - 1; i < columns && i >= 0
             && gameArea.field[index(row1, i)] === null; i--) {
            for (a = row2 + 1; a < rows && a >= 0
                 && gameArea.field[index(a, col2)] === null; a++) {
                if (zeroTurningPoint(row1, i, a, col2))
                    return true
            }
            for (b = row2 - 1; b < rows && b >= 0
                 && gameArea.field[index(b, col2)] === null; b--) {
                if (zeroTurningPoint(row1, i, b, col2))
                    return true
            }
            for (c = col2 + 1; c < columns && c >= 0
                 && gameArea.field[index(row2, c)] === null; c++) {
                if (zeroTurningPoint(row1, i, row2, c)) {
                    point = [row1, col1, row1, i, row2, c, row2, col2]
                    return true
                }
            }
            for (d = col2 - 1; d < columns && d >= 0
                 && gameArea.field[index(row2, d)] === null; d--) {
                if (zeroTurningPoint(row1, i, row2, d)) {
                    point = [row1, col1, row1, i, row2, d, row2, col2]
                    return true
                }
            }
        }

        for (i = col1 + 1; i < columns && i >= 0
             && gameArea.field[index(row1, i)] === null; i++) {
            for (a = row2 + 1; a < rows && a >= 0
                 && gameArea.field[index(a, col2)] === null; a++) {
                if (zeroTurningPoint(row1, i, a, col2)) {
                    return true
                }
            }
            for (b = row2 - 1; b < rows && b >= 0
                 && gameArea.field[index(b, col2)] === null; b--) {
                if (zeroTurningPoint(row1, i, b, col2))
                    return true
            }
            for (c = col2 + 1; c < columns && c >= 0
                 && gameArea.field[index(row2, c)] === null; c++) {
                if (zeroTurningPoint(row1, i, row2, c)) {
                    point = [row1, col1, row1, i, row2, c, row2, col2]
                    return true
                }
            }
            for (d = col2 - 1; d < columns && d >= 0
                 && gameArea.field[index(row2, d)] === null; d--) {
                if (zeroTurningPoint(row1, i, row2, d)) {
                    point = [row1, col1, row1, i, row2, d, row2, col2]
                    return true
                }
            }
        }

        return false
    }

    //no turnning point
    function zeroTurningPoint(row1, col1, row2, col2) {
        if (row1 === row2) {
            if (col1 < col2) {
                for (var i = col1 + 1; i < col2; i++) {
                    if (gameArea.field[index(row1, i)] !== null) {
                        return false
                    }
                }
            } else {
                for (var n = col2 + 1; n < col1; n++) {
                    if (gameArea.field[index(row1, n)] !== null)
                        return false
                }
            }
        } else if (col1 === col2) {
            if (row1 < row2) {
                for (var j = row1 + 1; j < row2; j++) {
                    if (gameArea.field[index(j, col1)] !== null)
                        return false
                }
            } else {
                for (var m = row2 + 1; m < row1; m++) {
                    if (gameArea.field[index(m, col1)] !== null)
                        return false
                }
            }
        } else {
            return false
        }

        return true
    }

    // check if game is over
    function isGameOver() {
        var fieldCopy = gameArea.field.slice()
        for (var row = 0; row < rows; row++) {
            for (var col = 0; col < columns; col++) {
                if (fieldCopy[index(row, col)] !== null) {
                    console.log(row, col)
                    for (var row1 = row; row1 < rows; row1++) {
                        for (var col1 = col + 1; col1 < columns; col1++) {
                            if (fieldCopy[index(row1, col1)] !== null
                                    && (fieldCopy[index(row, col)].type
                                        === fieldCopy[index(row1,
                                                            col1)].type)) {
                                if (checkNoBarrier(row, col, row1, col1)) {
                                    chanceLink = [row, col, row1, col1]
                                    return false
                                }
                            }
                        }
                    }
                }
            }
        }

        return true
    }

    function removeChanceLink() {
        var block = gameArea.field[index(chanceLink[0], chanceLink[1])]
        gameArea.field[index(chanceLink[0], chanceLink[1])] = null
        block.remove()
        block = gameArea.field[index(chanceLink[2], chanceLink[3])]
        gameArea.field[index(chanceLink[2], chanceLink[3])] = null
        block.remove()
        if (linelevel === 1) {
            drawline1(point[0], point[1], point[2], point[3])
            rectangle2.opacity = 0
            rectangle3.opacity = 0
        } else if (linelevel === 2) {
            drawline1(point[0], point[1], point[2], point[3])
            drawline2(point[4], point[5], point[2], point[3])
            rectangle3.opacity = 0
        } else {
            drawline1(point[0], point[1], point[2], point[3])
            drawline2(point[4], point[5], point[2], point[3])
            drawline3(point[4], point[5], point[6], point[7])
        }
    }
}
