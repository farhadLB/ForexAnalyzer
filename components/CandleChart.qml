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


    onCandlesChanged: {
        if (candles.length > 0) {
            firstVisibleIndex = 0
            recalcPriceRange()
            canvas.requestPaint()
        }
    }

    function recalcPriceRange() {
        if (candles.length === 0) return

        var end = Math.min(firstVisibleIndex + visibleCount, candles.length)

        var min = 999999999
        var max = -999999999

        for (var i = firstVisibleIndex; i < end; ++i) {
            min = Math.min(min, candles[i].low)
            max = Math.max(max, candles[i].high)
        }

        visibleMinPrice = min
        visibleMaxPrice = max
    }

    Canvas {
        id: canvas
        anchors.fill: parent

        onPaint: {

            var ctx = getContext("2d")
            ctx.clearRect(0,0,width,height)

            if (candles.length === 0)
                return

            var leftMargin = 60
            var bottomMargin = 20

            var chartW = width - leftMargin
            var chartH = height - bottomMargin

            function priceToY(price) {
                return chartH - (price - visibleMinPrice)
                       / (visibleMaxPrice - visibleMinPrice)
                       * chartH
            }

            // Y axis
            ctx.strokeStyle = "#888"
            ctx.beginPath()
            ctx.moveTo(leftMargin,0)
            ctx.lineTo(leftMargin,chartH)
            ctx.stroke()

            ctx.fillStyle = "white"
            ctx.font = "10px sans-serif"

            var steps = 12
            for (var i=0;i<=steps;i++) {
                var p = visibleMinPrice +
                        (visibleMaxPrice-visibleMinPrice)*i/steps
                var y = priceToY(p)

                ctx.beginPath()
                ctx.moveTo(leftMargin-5,y)
                ctx.lineTo(leftMargin,y)
                ctx.stroke()

                ctx.fillText(p.toFixed(5),2,y+3)
            }

            // X axis
            ctx.beginPath()
            ctx.moveTo(leftMargin,chartH)
            ctx.lineTo(width,chartH)
            ctx.stroke()

            // visible candles
            var endIndex = Math.min(firstVisibleIndex + visibleCount,
                                    candles.length)

            var candlePixel = chartW / visibleCount

            for (var i = firstVisibleIndex; i < endIndex; ++i) {

                var c = candles[i]
                var localIndex = i - firstVisibleIndex
                var x = leftMargin + localIndex * candlePixel + candlePixel/2

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

            // time labels
            var labelCount = 10
            var stepIndex = Math.floor(visibleCount/labelCount)

            for (var i=0;i<=labelCount;i++) {

                var idx = firstVisibleIndex + i*stepIndex
                if (idx >= candles.length) break

                var c = candles[idx]

                var x = leftMargin +
                        (idx-firstVisibleIndex)*candlePixel +
                        candlePixel/2

                var d = new Date(c.time)
                var txt = (d.getMonth()+1)+"/"+d.getDate()

                ctx.beginPath()
                ctx.moveTo(x,chartH)
                ctx.lineTo(x,chartH+5)
                ctx.stroke()

                ctx.fillText(txt,x-15,chartH+15)
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
                var dx = mouse.x - dragStartX
                var candlesPerPixel = visibleCount / width
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

            // محاسبه مرکز zoom: ایندکس کندل زیر ماوس
            var leftMargin = 60
            var chartW = width - leftMargin
            var xRelative = wheel.x - leftMargin
            xRelative = Math.max(0, Math.min(chartW, xRelative))

            var candlePixel = chartW / visibleCount
            var mouseIndex = firstVisibleIndex + Math.floor(xRelative / candlePixel)

            // با zoom، firstVisibleIndex جدید را طوری تغییر می‌دهیم که mouseIndex ثابت بماند
            var newFirstIndex = mouseIndex - Math.floor((xRelative / chartW) * newVisibleCount)
            newFirstIndex = Math.max(0, Math.min(candles.length - newVisibleCount, newFirstIndex))

            visibleCount = Math.floor(newVisibleCount)
            firstVisibleIndex = newFirstIndex

            recalcPriceRange()
            canvas.requestPaint()
        }
    }
}
