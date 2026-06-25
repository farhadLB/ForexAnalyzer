import QtQuick
import QtQuick.Controls
import ForexAnalyzer 1.0

Item {
    id: root

    property var candles: []
    property var rawCandles: []

    // visible range
    property int firstVisibleIndex: 0
    property int visibleCount: 250

    property real visibleMinPrice: 0
    property real visibleMaxPrice: 1

    property real dragStartX: 0
    property int  dragStartIndex: 0

    property real wheelFactor: 1.4   // ضریب زوم
    property int minVisibleCount: 10
    property int maxVisibleCount: 750

    property real mouseX: 0
    property real mouseY: 0
    property bool mouseInside: false

    property real crossX: 0
    property real crossY: 0
    property bool crossVisible: true

    property real basePaddingPercent: 0.55     // padding حالت zoom-out
    property real minPaddingPercent: 0.13      // حداقل padding در zoom-in

    property int rightOffsetCandles: 0   // تعداد کندل فضای خالی انتها

    property real leftMargin: 60
    property real topMargin: 10

    property bool tlineExtended: false
    property bool positionVisible: false

    property int currentTimeframe: 0
    property int currentPositionIndex: 0

    property bool isLoading: false


    Connections {
        target: chartObjects
        function onObjectsChanged() {
            canvas.requestPaint()
        }
    }

    Connections {
        target: trendlineDetector
        function onTrendlinesFound() {
            canvas.requestPaint()
        }
    }

    function onTlineExtendedChanged() {
        canvas.requestPaint()
    }

    onPositionVisibleChanged: {
        currentPositionIndex = 0

        if (positionVisible) {
            var positions = chartObjects.positions()
            if (positions.length === 0) {
                canvas.requestPaint()
                return
            }

            var positionTf = Aggregator.getTimeframe(positions[0].Timeframe)
            var newCandles = Aggregator.aggregate(root.rawCandles, positionTf)
            Aggregator.setTimeframe(positions[0].Timeframe)
            root.candles = newCandles
        } else {
            canvas.requestPaint()
        }
    }

    onCandlesChanged: {
        if (candles.length > 0) {
            firstVisibleIndex = 0
            recalcPriceRange()
            canvas.requestPaint()
        }
    }

    function nextPosition() {
        var positions = chartObjects.positions()
        var leftCandlesCount = 30                    // number of candles gap in the left of position
        if (positions.length === 0) return
        currentPositionIndex = (currentPositionIndex + 1) % positions.length
        if(positions[currentPositionIndex].LevelIdx > leftCandlesCount ) {
            firstVisibleIndex = positions[currentPositionIndex].LevelIdx - leftCandlesCount
        }
        else{
            firstVisibleIndex = positions[currentPositionIndex].LevelIdx
        }        recalcPriceRange()
        canvas.requestPaint()
    }

    function prevPosition() {
        var positions = chartObjects.positions()
        var leftCandlesCount = 30                    // number of candles gap in the left of position
        if (positions.length === 0) return
        currentPositionIndex = (currentPositionIndex - 1 + positions.length) % positions.length
        if(positions[currentPositionIndex].LevelIdx > leftCandlesCount ) {
            firstVisibleIndex = positions[currentPositionIndex].LevelIdx - leftCandlesCount
        }
        else{
            firstVisibleIndex = positions[currentPositionIndex].LevelIdx
        }

        recalcPriceRange()
        canvas.requestPaint()
    }

    function recalcPriceRange() {
        if (candles.length === 0) return

        var start = firstVisibleIndex
        var end   = Math.min(candles.length, start + visibleCount)

        var minP = 1e20
        var maxP = -1e20

        for (var i = start; i < end; ++i) {
            var c = candles[i]
            if (c.low < minP)  minP = c.low
            if (c.high > maxP) maxP = c.high
        }

        var range = maxP - minP
        if (range <= 0) range = 1

        // ---- padding وابسته به zoom ----
        var zoomRatio = visibleCount / candles.length
        var dynamicPaddingPercent =
                minPaddingPercent +
                (basePaddingPercent - minPaddingPercent) * zoomRatio

        var padding = range * dynamicPaddingPercent

        visibleMinPrice = minP - padding
        visibleMaxPrice = maxP + padding
    }

    function formatTimeForTimeframe(d, tf)
    {
        function pad(v){ return ("0"+v).slice(-2) }

        var days  = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
        var months= ["Jan","Feb","Mar","Apr","May","Jun",
                     "Jul","Aug","Sep","Oct","Nov","Dec"]

        // ---- minute timeframes ----
        if(tf === 0 ||
                tf === 1 ||
                tf === 2)
        {
            var yy = d.getFullYear().toString().slice(-2)

            return days[d.getDay()] + " " +
                    pad(d.getDate()) + " " +
                    months[d.getMonth()] + " " +
                    yy + " " +
                    pad(d.getHours()) + ":" +
                    pad(d.getMinutes())
        }

        // ---- H1 / H4 ----
        if(tf === 3 ||
                tf === 4)
        {
            var yy = d.getFullYear().toString().slice(-2)

            return days[d.getDay()] + " " +
                    pad(d.getDate()) + " " +
                    months[d.getMonth()] + " " +
                    yy + " " +
                    pad(d.getHours()) + ":00"
        }

        // ---- D1 ----
        if(tf === 5)
        {
            var yy = d.getFullYear().toString().slice(-2)

            return days[d.getDay()] + " " +
                    pad(d.getDate()) + " " +
                    months[d.getMonth()] + " " +
                    yy
        }

        return ""
    }

    Canvas {
        id: canvas
        anchors.fill: parent

        onPaint: {

            var ctx = getContext("2d")
            ctx.clearRect(0,0,width,height)

            if (candles.length === 0)
                return

            var bottomMargin = 20

            var chartW = width - root.leftMargin
            var chartH = height - bottomMargin

            function priceToY(price) {
                var range = visibleMaxPrice - visibleMinPrice
                if(range <= 0) range = 1
                return root.topMargin + chartH - ((price - visibleMinPrice)/range)*chartH
            }

            function indexToX(index)
            {
                var totalVisible = visibleCount + rightOffsetCandles
                var candleW = chartW / totalVisible
                return root.leftMargin + (index - firstVisibleIndex) * candleW + candleW * 0.5
            }

            // function timeToIndex(time)
            // {
            //     for(var i=0;i<candles.length;i++){
            //         if(candles[i].time >= time)
            //             return i
            //     }
            //     return candles.length-1
            // }

            function timeToIndex(time) {
                var lo = 0
                var hi = candles.length - 1
                while (lo < hi) {
                    var mid = (lo + hi) >> 1
                    if (candles[mid].time < time)
                        lo = mid + 1
                    else
                        hi = mid
                }
                return lo
            }

            function yToPrice(y){
                var range = visibleMaxPrice - visibleMinPrice
                if(range <= 0) range = 1
                return visibleMinPrice +
                        (1 - (y - root.topMargin)/chartH) * range
            }

            function xToIndex(x){
                var totalVisible = visibleCount + rightOffsetCandles
                var candlePixel = chartW / totalVisible
                return firstVisibleIndex +
                        Math.floor((x - root.leftMargin)/candlePixel)
            }

            // visible candles
            var endIndex = Math.min(firstVisibleIndex + visibleCount,
                                    candles.length)

            var totalVisible = visibleCount + rightOffsetCandles
            var candlePixel = chartW / totalVisible

            for (var i = firstVisibleIndex; i < endIndex; ++i) {

                var c = candles[i]
                var localIndex = i - firstVisibleIndex
                var x = root.leftMargin + localIndex * candlePixel + candlePixel/2

                var yOpen  = priceToY(c.open)
                var yClose = priceToY(c.close)
                var yHigh  = priceToY(c.high)
                var yLow   = priceToY(c.low)

                var bull = c.close >= c.open
                ctx.strokeStyle = bull ? "#00aa55" : "#cc3333"
                ctx.fillStyle = ctx.strokeStyle

                ctx.beginPath()
                ctx.moveTo(x,yHigh)
                ctx.lineTo(x,yLow)
                ctx.stroke()

                var bodyTop = Math.min(yOpen,yClose)
                var bodyHeight = Math.abs(yClose-yOpen)
                if (bodyHeight < 1) bodyHeight = 1

                ctx.fillRect(
                            x - candlePixel*0.35,
                            bodyTop,
                            candlePixel*0.7,
                            bodyHeight
                            )
            }

            // crosshair
            if (crossVisible) {
                ctx.strokeStyle = "white"
                ctx.setLineDash([4,4])

                // vertical
                ctx.beginPath()
                ctx.moveTo(crossX, 0)
                ctx.lineTo(crossX, chartH)
                ctx.stroke()

                // horizontal
                ctx.beginPath()
                ctx.moveTo(leftMargin, crossY)
                ctx.lineTo(width, crossY)
                ctx.stroke()

                ctx.setLineDash([])
            }

            //Trendlines
            var lines = chartObjects.allTrendlines()
            ctx.lineWidth = 2

            for(var i=0;i<lines.length;i++)
            {
                var t = lines[i]
                var tf = t.timeframe
                if(tf === "1m"){
                    ctx.strokeStyle = "skyblue"
                }
                else if(tf === "5m"){
                    ctx.strokeStyle = "orange"
                }
                else if(tf === "15m"){
                    ctx.strokeStyle = "blue"
                }
                else
                    ctx.strokeStyle = "yellow"

                var sIdx = timeToIndex(t.startTime)
                var eIdx = timeToIndex(t.endTime)

                var x1 = indexToX(sIdx)
                var y1 = priceToY(t.startPrice)

                if(!tlineExtended)
                {
                    var x2 = indexToX(eIdx)
                    var y2 = priceToY(t.endPrice)
                }
                else
                {
                    var lastIndex = firstVisibleIndex + visibleCount + rightOffsetCandles

                    var slope =
                            (t.endPrice - t.startPrice) /
                            (eIdx - sIdx)

                    var extendedPrice =
                            t.startPrice +
                            slope * (lastIndex - sIdx)

                    var x2 = indexToX(lastIndex)
                    var y2 = priceToY(extendedPrice)
                }

                ctx.beginPath()
                ctx.moveTo(x1,y1)
                ctx.lineTo(x2,y2)
                ctx.stroke()
            }

            //Horizantal Static Levels
            var levels = chartObjects.allLevels()
            ctx.setLineDash([6,4])

            for(var i=0;i<levels.length;i++){
                var price = levels[i].price
                ctx.strokeStyle = levels[i].isResistance ? "#00ffaa" : "red"

                if(price < visibleMinPrice || price > visibleMaxPrice) continue

                var y = priceToY(price)
                ctx.beginPath()
                ctx.moveTo(leftMargin, y)
                ctx.lineTo(width, y)
                ctx.stroke()
            }

            ctx.setLineDash([])

            //Horizantal Level Break Dots
            for(var i=0; i< levels.length; i++){
                var candleIdx = timeToIndex(levels[i].breakTime)
                var breakX    = indexToX(candleIdx)
                if(candleIdx > 0){
                    var breakPrice = candles[candleIdx].close
                }
                else{
                    var breakPrice = 0
                }

                var breakY = priceToY(breakPrice)
                ctx.beginPath()
                ctx.arc(breakX, breakY, 5, 0, 2 * Math.PI)
                ctx.fillStyle = "orange"
                ctx.fill()
            }

            // Positions
            if (positionVisible)
            {
                var positions  = chartObjects.positions()
                var pos        = positions[currentPositionIndex]
                var fromTf     = Aggregator.getTimeframe(pos.Timeframe)
                var newLevelIdx= Aggregator.indexAggregate(pos.LevelIdx, fromTf, currentTimeframe)
                var newEntryIdx= Aggregator.indexAggregate(pos.EntryIdx, fromTf, currentTimeframe)
                var newEndIdx  = Aggregator.indexAggregate(pos.EndIdx, fromTf, currentTimeframe)
                var entryX2    = indexToX(pos.LevelIdx)
                var entryY2    = priceToY(pos.LevelPrice)
                var entryX     = indexToX(newEntryIdx.index)
                // var entryX2    = indexToX(pos.LevelIdx)
                // var entryY2    = pos.isBullish ? priceToY(root.candles[pos.LevelIdx].high) : priceToY(root.candles[pos.LevelIdx].low)
                // var endX       = indexToX(pos.EndIdx)
                var endX       = indexToX(newEndIdx.index)
                var entryY     = priceToY(pos.EntryPointPrice)
                var stopY      = priceToY(pos.StopLossPrice)
                var profitY    = priceToY(pos.TakeProfitPrice)
                var rectX      = Math.min(entryX, endX)
                var rectW      = Math.abs(endX - entryX)

                // entry price dash line
                ctx.setLineDash([6,4])
                ctx.strokeStyle = positions[currentPositionIndex].isBullish ? "#00ffaa" : "red"
                ctx.beginPath()
                ctx.moveTo(entryX2, entryY2)
                ctx.lineTo(width, entryY2)
                ctx.stroke()

                // entry price circle
                ctx.beginPath()
                ctx.arc(entryX, entryY, 5, 0, 2 * Math.PI)
                ctx.fillStyle = "orange"
                ctx.fill()

                // profit zone (green, above entry line — lower Y = higher price)
                ctx.fillStyle  = "rgba(0, 180, 100, 0.18)"
                ctx.fillRect(rectX, profitY, rectW, entryY - profitY)

                // loss zone (red, below entry line)
                ctx.fillStyle  = "rgba(220, 50, 50, 0.18)"
                ctx.fillRect(rectX, entryY, rectW, stopY - entryY)

                // entry line
                ctx.strokeStyle = "rgba(255, 255, 255, 0.85)"
                ctx.lineWidth   = 1
                ctx.setLineDash([])
                ctx.beginPath()
                ctx.moveTo(rectX, entryY)
                ctx.lineTo(rectX + rectW, entryY)
                ctx.stroke()

                // take profit line
                ctx.strokeStyle = "#00cc66"
                ctx.lineWidth   = 1
                ctx.beginPath()
                ctx.moveTo(rectX, profitY)
                ctx.lineTo(rectX + rectW, profitY)
                ctx.stroke()

                // stop loss line
                ctx.strokeStyle = "#dd3333"
                ctx.lineWidth   = 1
                ctx.beginPath()
                ctx.moveTo(rectX, stopY)
                ctx.lineTo(rectX + rectW, stopY)
                ctx.stroke()

                // positions info text
                ctx.fillStyle = "white"
                ctx.font = "15px sans-serif bold"
                ctx.textAlign = "end"
                ctx.fillText("Position Id: ", leftMargin + 50, 50)
                ctx.fillText(currentPositionIndex + 1, leftMargin + 200, 50)
                ctx.fillText("Entry Index: ", leftMargin + 50, 80)
                ctx.fillText(pos.EntryIdx, leftMargin + 200, 80)
                ctx.fillText("Stop Loss Price: ", leftMargin + 50, 110)
                ctx.fillText(pos.StopLossPrice, leftMargin + 200, 110)
                ctx.fillText("Take Profit Price: ", leftMargin + 50, 140)
                ctx.fillText(pos.TakeProfitPrice.toFixed(3), leftMargin + 200, 140)
                ctx.fillText("Position Result: ", leftMargin + 50, 170)
                if(pos.isWin){
                    ctx.fillStyle = "#00aa55"
                    ctx.font = "15px sans-serif bold"
                    ctx.fillText("Success", leftMargin + 200, 170)
                }
                else{
                    ctx.fillStyle = "#cc3333"
                    ctx.font = "15px sans-serif bold"
                    ctx.fillText("fail", leftMargin + 200, 170)
                }

            }

            // Y axis
            ctx.strokeStyle = "#888"
            ctx.beginPath()
            ctx.moveTo(leftMargin,0)
            ctx.lineTo(leftMargin,chartH)
            ctx.stroke()

            ctx.fillStyle = "white"
            ctx.font = "10px sans-serif"

            // X axis
            ctx.beginPath()
            ctx.moveTo(leftMargin,chartH)
            ctx.lineTo(width,chartH)
            ctx.stroke()

            // axis backgrounds
            ctx.fillStyle = "#111827"
            ctx.fillRect(0, 0, root.leftMargin, chartH)
            ctx.fillStyle = "#111827"
            ctx.fillRect(0, chartH, width, height - chartH)

            // time labels
            var labelCount = 10
            var stepIndex = Math.floor(visibleCount/labelCount)

            for (var i=0;i<=labelCount;i++)
            {
                var idx = firstVisibleIndex + i*stepIndex
                if (idx >= candles.length) break

                var c = candles[idx]

                var x = root.leftMargin +
                        (idx-firstVisibleIndex)*candlePixel +
                        candlePixel/2

                var d = new Date(c.time)
                var txt = (d.getHours()) + ":" + d.getMinutes()

                // ---- tick ----
                ctx.strokeStyle = "#888"
                ctx.beginPath()
                ctx.moveTo(x,chartH)
                ctx.lineTo(x,chartH+5)
                ctx.stroke()

                // ---- text ----
                ctx.fillStyle = "white"
                ctx.textAlign = "start"
                ctx.fillText(txt,x + 5,chartH+13)
            }

            // Y labels
            var steps = 12
            ctx.font = "10px sans-serif"
            for (var i=0;i<=steps;i++)
            {
                var p = visibleMinPrice +
                        (visibleMaxPrice-visibleMinPrice)*i/steps

                var y = priceToY(p)
                var txt = p.toFixed(3)

                // ---- tick ----
                ctx.strokeStyle = "#888"
                ctx.beginPath()
                ctx.moveTo(leftMargin-5,y)
                ctx.lineTo(leftMargin,y)
                ctx.stroke()

                // ---- text ----
                ctx.fillStyle = "white"
                ctx.fillText(txt, root.leftMargin - 8, y+3)
            }

            if (crossVisible)
            {
                // ---- price label (Y axis) ----
                var price = yToPrice(crossY)
                var priceTxt = price.toFixed(3)

                var labelH = 18
                var labelW = root.leftMargin - 2

                var py = Math.max(0,
                                  Math.min(chartH - labelH,
                                           crossY - labelH/2))

                ctx.fillStyle = "red"
                ctx.fillRect(0, py, labelW, labelH)

                ctx.fillStyle = "white"
                ctx.fillText(priceTxt, root.leftMargin - 6, py + 12)


                // ---- time label (X axis) ----
                var idx = xToIndex(crossX)
                if(idx >= 0 && idx < candles.length)
                {
                    var d = new Date(candles[idx].time)
                    var txt = root.formatTimeForTimeframe(d, root.currentTimeframe)

                    var labelW2 = 100
                    var tx = Math.max(root.leftMargin,
                                      Math.min(width-labelW2,
                                               crossX-labelW2/2))

                    ctx.fillStyle = "#202030"
                    ctx.fillRect(tx, chartH, labelW2, 18)

                    ctx.fillStyle = "white"
                    ctx.fillText(txt, tx+labelW2 - 6, chartH+12)
                }

                // --- current candle index ---
                ctx.font = "15px sans-serif bold"
                ctx.textAlign = "end"
                ctx.fillText("Candle  Index: ", leftMargin + 50, 200)
                ctx.fillText(xToIndex(crossX), leftMargin + 200, 200)
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#80111827"
        visible: root.isLoading
        z: 10

        BusyIndicator {
            anchors.centerIn: parent
            running: root.isLoading
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: crossVisible ? Qt.CrossCursor : Qt.ArrowCursor

        onPressed: function(mouse) {
            dragStartX = mouse.x
            dragStartIndex = firstVisibleIndex
        }

        onPositionChanged: function(mouse) {
            // drag
            if (pressed) {

                var chartW = width - root.leftMargin
                var totalVisible = visibleCount + rightOffsetCandles
                var candlesPerPixel = totalVisible / chartW

                var dx = mouse.x - dragStartX
                var shift = Math.round(-dx * candlesPerPixel)

                var newIndex = dragStartIndex + shift
                newIndex = Math.max(0, Math.min(candles.length - visibleCount, newIndex))

                if (newIndex !== firstVisibleIndex) {
                    firstVisibleIndex = newIndex
                    recalcPriceRange()
                    canvas.requestPaint()
                }
            }

            // crosshair
            crossX = mouse.x
            crossY = mouse.y
            canvas.requestPaint()
        }
    }

    WheelHandler {
        target: parent
        onWheel: function(wheel) {

            if (candles.length === 0) return

            // مقدار zoom جدید
            var newVisibleCount = visibleCount

            if (wheel.angleDelta.y > 0) { // چرخ به بالا → zoom in
                newVisibleCount = Math.max(minVisibleCount, visibleCount / wheelFactor)
            } else { // چرخ به پایین → zoom out
                newVisibleCount = Math.min(maxVisibleCount, visibleCount * wheelFactor)
            }

            var chartW = width - root.leftMargin
            var xRelative = wheel.x - root.leftMargin
            xRelative = Math.max(0, Math.min(chartW, xRelative))

            var totalVisible = visibleCount + rightOffsetCandles
            var candlePixel = chartW / totalVisible

            var mouseIndex = firstVisibleIndex + Math.floor(xRelative / candlePixel)

            var newFirstIndex =
                    mouseIndex -
                    Math.floor((xRelative / chartW) * totalVisible)

            newFirstIndex = Math.max(0,
                                     Math.min(candles.length - newVisibleCount,
                                              newFirstIndex))


            visibleCount = Math.floor(newVisibleCount)
            firstVisibleIndex = newFirstIndex

            recalcPriceRange()
            canvas.requestPaint()
        }
    }
}
