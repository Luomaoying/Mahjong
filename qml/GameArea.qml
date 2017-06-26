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
    property int maxTypes
    property var imageNumber: [10, 10, 12, 10, 12, 10, 10, 12, 10]
    property int clicks

    // array for handling game field
    property var field: []
    property var link: []
    property int linkIndex: 0

    // gameover signal
    signal gameOver

    // calculate field index
    function index(row, column) {
        return row * columns + column
    }

    // fill game field with blocks
    function initializeField() {
        // reset difficulty
        gameArea.clicks = 0
        gameArea.maxTypes = 9

        // clear field
        clearField()

        // fill field
        for (var i = 0; i < rows; i++) {
            for (var j = 0; j < columns; j++) {
                if (i === j || (rows - i) === (columns - j)) {
                    gameArea.field[index(i, j)] = null
                } else {
                    gameArea.field[index(i, j)] = createBlock(i, j)
                }
            }
        }
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
    function createBlock(row, column) {
        // configure block
        var entityProperties = {
            width: blockSize,
            height: blockSize,
            x: column * blockSize,
            y: row * blockSize,
            type: imageSet(),
            row// random type
            : row,
            column: column
        }

        // add block to game area
        var id = entityManager.createEntityFromUrlWithProperties(
                    Qt.resolvedUrl("Block.qml"), entityProperties)

        // link click signal from block to handler function
        var entity = entityManager.getEntityById(id)
        entity.clicked.connect(handleClick)

        return entity
    }

    function imageSet() {
        var types = Math.floor(Math.random() * gameArea.maxTypes)
        if (imageNumber[types] !== 0) {
            imageNumber[types]--
            return types
        } else {
            return imageSet()

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
        var fieldCopy = field.slice()

        // count and delete connected blocks
        link[linkIndex] = fieldCopy[index(row, column)]
        if (linkIndex === 0) {
            if (link.length === 2 && link[1] !== null) {
                if (link[1].type === type && (link[1].row !== row
                                              || link[1].column !== column)
                        && checkNoBarrier(link[1].row, link[1].column, row,
                                          column)) {
                    var block = gameArea.field[index(link[0].row,
                                                     link[0].column)]
                    gameArea.field[index(link[0].row, link[0].column)] = null
                    block.remove()
                    link[0] = null

                    block = gameArea.field[index(link[1].row, link[1].column)]
                    gameArea.field[index(link[1].row, link[1].column)] = null
                    block.remove()
                    link[1] = null
                } else
                    linkIndex = 1
            } else
                linkIndex = 1
        } else {
            if (link[0] !== null) {
                if (link[0].type === type && (link[0].row !== row
                                              || link[0].column !== column)
                        && checkNoBarrier(link[0].row, link[0].column, row,
                                          column)) {
                    block = gameArea.field[index(link[0].row, link[0].column)]
                    gameArea.field[index(link[0].row, link[0].column)] = null
                    block.remove()
                    link[0] = null

                    block = gameArea.field[index(link[1].row, link[1].column)]
                    gameArea.field[index(link[1].row, link[1].column)] = null
                    block.remove()
                    link[1] = null
                } else
                    linkIndex = 0
            } else
                linkIndex = 0
        }

        //  var blockCount = getNumberOfConnectedBlocks(fieldCopy, row,
        //                                                  column, type)
        //  if (blockCount >= 3) {
        //  removeConnectedBlocks(fieldCopy)
        // moveBlocksToBottom()

        // calculate and increase score
        // this will increase the added score for each block, e.g. four blocks will be 1+2+3+4 = 10 points
        // var score = blockCount * (blockCount + 1) / 2
        // scene.score += score

        // emit signal if game is over
        if (isGameOver())
            gameOver()

        // increase difficulty every 10 clicks until maxTypes == 5
        gameArea.clicks++
        if ((gameArea.maxTypes < 5) && (gameArea.clicks % 10 == 0))
            gameArea.maxTypes++
    }

    // recursively check a block and its neighbours
    // returns number of connected blocks
    function checkNoBarrier(row1, col1, row2, col2) {
        if (row1 === row2 || col1 === col2) {
            if (!zeroTurningPoint(row1, col1, row2, col2)) {
                return (threeTurningPoint(row1, col1, row2, col2))
            } else {
                return true
            }
        } else {
            if (!twoTurningPoint(row1, col1, row2, col2)) {
                return (threeTurningPoint(row1, col1, row2, col2))
            } else {
                return true
            }
        }
    }

    function twoTurningPoint(row1, col1, row2, col2) {

        if ((zeroTurningPoint(row1, col1, row1, col2)
             && zeroTurningPoint(row1, col2, row2,
                                 col2) && gameArea.field[index(row1, col2)]
             === null) || (zeroTurningPoint(row1, col1,
                                            row2, col1) && zeroTurningPoint(row2,
                                                                            col1, row2, col2)) && gameArea.field[index(row2, col1)] === null) {
            return true
        }
        return false
    }

    function threeTurningPoint(row1, col1, row2, col2) {
        for (var i = row1 + 1; i < rows && i >= 0
             && gameArea.field[index(i, col1)] === null; i++) {
            for (var a = row2 + 1; a < rows && a >= 0
                 && gameArea.field[index(a, col2)] === null; a++) {
                if (zeroTurningPoint(i, col1, a, col2))
                    return true
            }
            for (var b = row2 - 1; b < rows && b >= 0
                 && gameArea.field[index(b, col2)] === null; b--) {
                if (zeroTurningPoint(i, col1, b, col2))
                    return true
            }
            for (var c = col2 + 1; c < columns && c >= 0
                 && gameArea.field[index(row2, c)] === null; c++) {
                if (zeroTurningPoint(i, col1, row2, c))
                    return true
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
                if (zeroTurningPoint(i, col1, a, col2))
                    return true
            }
            for (b = row2 - 1; b < rows && b >= 0
                 && gameArea.field[index(b, col2)] === null; b--) {
                if (zeroTurningPoint(i, col1, b, col2))
                    return true
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
                if (zeroTurningPoint(row1, i, row2, c))
                    return true
            }
            for (d = col2 - 1; d < columns && d >= 0
                 && gameArea.field[index(row2, d)] === null; d--) {
                if (zeroTurningPoint(row1, i, row2, d))
                    return true
            }
        }

        for (i = col1 + 1; i < columns && i >= 0
             && gameArea.field[index(row1, i)] === null; i++) {
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
                if (zeroTurningPoint(row1, i, row2, c))
                    return true
            }
            for (d = col2 - 1; d < columns && d >= 0
                 && gameArea.field[index(row2, d)] === null; d--) {
                if (zeroTurningPoint(row1, i, row2, d))
                    return true
            }
        }

        return false
    }

    function zeroTurningPoint(row1, col1, row2, col2) {
        if (row1 === row2) {
            if (col1 < col2) {
                for (var i = col1 + 1; i < col2; i++) {
                    if (gameArea.field[index(row1, i)] !== null)
                        return false
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

        console.log("0000000000000000000000")
        return true
    }

    function getNumberOfConnectedBlocks(fieldCopy, row, column, type) {
        // stop recursion if out of bounds
        if (row >= rows || column >= columns || row < 0 || column < 0)
            return 0

        // get block
        var block = fieldCopy[index(row, column)]

        // stop if block was already checked
        if (block === null)
            return 0

        // stop if block has different type
        if (block.type !== type)
            return 0

        // block has the required type and was not checked before
        var count = 1

        // remove block from field copy so we can't check it again
        // also after we finished searching, every correct block we found will leave a null value at its
        // position in the field copy, which we then use to remove the blocks in the real field array
        fieldCopy[index(row, column)] = null

        // check all neighbours of current block and accumulate number of connected blocks
        // at this point the function calls itself with different parameters
        // this principle is called "recursion" in programming
        // each call will result in the function calling itself again until one of the
        // checks above immediately returns 0 (e.g. out of bounds, different block type, ...)
        count += getNumberOfConnectedBlocks(
                    fieldCopy, row + 1, column,
                    type) // add number of blocks to the right
        count += getNumberOfConnectedBlocks(fieldCopy, row, column + 1,
                                            type) // add number of blocks below
        count += getNumberOfConnectedBlocks(
                    fieldCopy, row - 1, column,
                    type) // add number of blocks to the left
        count += getNumberOfConnectedBlocks(fieldCopy, row, column - 1,
                                            type) // add number of bocks above

        // return number of connected blocks
        return count
    }

    // move remaining blocks to the bottom and fill up columns with new blocks
    function moveBlocksToBottom() {
        // check all columns for empty fields
        for (var col = 0; col < columns; col++) {

            // start at the bottom of the field
            for (var row = rows - 1; row >= 0; row--) {

                // find empty spot in grid
                if (gameArea.field[index(row, col)] === null) {

                    // find block to move down
                    var moveBlock = null
                    for (var moveRow = row - 1; moveRow >= 0; moveRow--) {
                        moveBlock = gameArea.field[index(moveRow, col)]

                        if (moveBlock !== null) {
                            gameArea.field[index(moveRow, col)] = null
                            gameArea.field[index(row, col)] = moveBlock
                            moveBlock.row = row
                            moveBlock.fallDown(row - moveRow)
                            break
                        }
                    }

                    // if no block found, fill whole column up with new blocks
                    if (moveBlock === null) {
                        var distance = row + 1

                        for (var newRow = row; newRow >= 0; newRow--) {
                            var newBlock = createBlock(newRow - distance, col)
                            gameArea.field[index(newRow, col)] = newBlock
                            newBlock.row = newRow
                            newBlock.fallDown(distance)
                        }

                        // column already filled up, no need to check higher rows again
                        break
                    }
                }
            } // end check rows starting from the bottom
        } // end check columns for empty fields
    }

    // check if game is over
    function isGameOver() {
        var gameOver = true

        // copy field to search for connected blocks without modifying the actual field
        var fieldCopy = field.slice()

        // search for connected blocks in field
        for (var row = 0; row < rows; row++) {
            for (var col = 0; col < columns; col++) {

                // test all blocks
                var block = fieldCopy[index(row, col)]
                if (block !== null) {
                    var blockCount = getNumberOfConnectedBlocks(fieldCopy, row,
                                                                col, block.type)

                    if (blockCount >= 3) {
                        gameOver = false
                        break
                    }
                }
            }
        }

        return gameOver
    }

    // returns true if all animations are finished and new blocks may be removed
    function isFieldReadyForNewBlockRemoval() {
        // check if top row has empty spots or blocks not fully within game area
        for (var col = 0; col < columns; col++) {
            var block = field[index(0, col)]
            if (block === null || block.y < 0)
                return false
        }

        // field is ready
        return true
    }
}
