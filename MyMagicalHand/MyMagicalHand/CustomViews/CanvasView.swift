import UIKit

final class CanvasView: UIView {
    
    struct Path {
        var points: [CGPoint] = []
    }
    
    private(set) var paths: [Path] = []
    private var numberOfPath = 0
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    
    //MARK: - Private
    private func configure() {
        backgroundColor = .systemBackground
        translatesAutoresizingMaskIntoConstraints = false
    }
}

//MARK: - Drawing things
extension CanvasView {
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let bezierPath = UIBezierPath()
        bezierPath.lineCapStyle = .round
        bezierPath.lineWidth = 5
        
        paths.forEach { path in
            for index in 0..<path.points.count {
                if index == 0 {
                    bezierPath.move(to: path.points[index])
                } else {
                    bezierPath.addLine(to: path.points[index])
                }
            }
        }
        
        bezierPath.stroke()
    }

    func erase() {
        paths.removeAll()
        numberOfPath = 0
        setNeedsDisplay()
    }
}

//MARK: - Touch Event
extension CanvasView {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //Starting new Path
        paths.append(Path())
        setNeedsDisplay()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self) else {
            return
        }
        paths[numberOfPath].points.append(point)
        setNeedsDisplay()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        numberOfPath += 1
    }
}
