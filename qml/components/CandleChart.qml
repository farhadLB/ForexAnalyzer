import QtQuick

Item {
    id: root

    property var candles: []

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

    onCandlesChanged: {
        if (candles.length > 0) {
            firstVisibleIndex = 0
            recalcPriceRange()
            canvas.requestPaint()
        }
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

            function timeToIndex(time)
            {
                for(var i=0;i<candles.length;i++){
                    if(candles[i].time >= time)
                        return i
                }
                return candles.length-1
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
            var lines = chartObjects.trendlines()
            ctx.strokeStyle = "yellow"
            ctx.lineWidth = 2

            for(var i=0;i<lines.length;i++)
            {
                var t = lines[i]

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
            ctx.strokeStyle = "#00ffaa"
            ctx.setLineDash([6,4])

            for(var i=0;i<levels.length;i++){
                var price = levels[i].price

                if(price < visibleMinPrice || price > visibleMaxPrice) continue

                var y = priceToY(price)
                ctx.beginPath()
                ctx.moveTo(leftMargin, y)
                ctx.lineTo(width, y)
                ctx.stroke()
            }

            ctx.setLineDash([])

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
            ctx.fillStyle = "#0b0b17"
            ctx.fillRect(0, 0, root.leftMargin, chartH)
            ctx.fillStyle = "#0b0b17"
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
                ctx.fillText(txt,x-20,chartH+13)
            }

            // Y labels
            var steps = 12
            ctx.font = "10px sans-serif"
            for (var i=0;i<=steps;i++)
            {
                var p = visibleMinPrice +
                        (visibleMaxPrice-visibleMinPrice)*i/steps

                var y = priceToY(p)
                var txt = p.toFixed(5)

                // ---- tick ----
                ctx.strokeStyle = "#888"
                ctx.beginPath()
                ctx.moveTo(leftMargin-5,y)
                ctx.lineTo(leftMargin,y)
                ctx.stroke()

                // ---- text ----
                ctx.fillStyle = "white"
                ctx.fillText(txt, 2, y+3)
            }
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
