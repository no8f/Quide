import QtQuick
import QtQuick.Shapes
import QtQuick.Controls.Material

Shape {
    id: corner_shape

    enum Position {
        TopLeft,
        TopRight,
        BottomRight,
        BottomLeft
    }

    property int position: RoundCorner.Position.TopLeft

    readonly property int size: 25

    width: size
    height: size
    preferredRendererType: Shape.CurveRenderer

    ShapePath {
        id: corner_path
        strokeWidth: corner_arc.radiusX/1.9
        strokeColor: Material.background
        fillColor: "transparent"

        startX: 0
        startY: corner_shape.size

        PathAngleArc {
            id: corner_arc
            centerX: corner_shape.size/2
            centerY: corner_shape.size/2
            radiusX: 17
            radiusY: 17

            startAngle: {
                switch(corner_shape.position) {
                    case RoundCorner.Position.TopLeft:
                    return 180;
                    break;
                    case RoundCorner.Position.TopRight:
                    return 270;
                    break;
                    case RoundCorner.Position.BottomRight:
                    return 0;
                    break;
                    case RoundCorner.Position.BottomLeft:
                    return 90;
                }
            }
            sweepAngle: 90
        }
    }
}
