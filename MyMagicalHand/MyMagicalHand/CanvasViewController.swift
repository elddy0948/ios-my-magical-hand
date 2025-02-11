import CoreML
import UIKit
import Vision

class CanvasViewController: UIViewController {
    //MARK: - Views
    private let backgroundView: UIVisualEffectView = {
        let visualEffectView = UIVisualEffectView()
        visualEffectView.effect = UIBlurEffect(style: .dark)
        return visualEffectView
    }()
    private(set) var canvasView = CanvasView()
    private let buttonHorizontalStackView = MagicalHandStackView(axis: .horizontal, distribution: .equalSpacing, spacing: 0)
    private(set) var showResultButton = ActionButton(title: "결과보기", titleColor: .systemYellow)
    private(set) var clearButton = ActionButton(title: "지우기", titleColor: .white)
    private let labelVerticalStackView = MagicalHandStackView(axis: .vertical, distribution: .fillProportionally, spacing: 16)
    private(set) var looksLikeLabel = ResultLabel(font: UIFont.preferredFont(forTextStyle: .title1))
    private(set) var percentLabel = ResultLabel(font: UIFont.preferredFont(forTextStyle: .body))
    
    lazy var classificationRequest: VNCoreMLRequest = {
        do {
            let drawImage = ShapDetectorKeras()
            let visionModel = try VNCoreMLModel(for: drawImage.model)
            let request = VNCoreMLRequest(model: visionModel, completionHandler: { request, error in
                self.processObservations(for: request, error: error)
            })
            request.imageCropAndScaleOption = .centerCrop
            return request
        } catch {
            fatalError("\(error)")
        }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackgroundView()
        configureCanvasView()
        configureStackViews()
        hideLabels()
        addButtonActions()
    }
    
    private func addButtonActions() {
        showResultButton.addTarget(self, action: #selector(didTapShowResultButton), for: .touchUpInside)
        clearButton.addTarget(self, action: #selector(didTapClearButton(_:)), for: .touchUpInside)
    }
    
    private func hideLabels() {
        looksLikeLabel.isHidden = true
        percentLabel.isHidden = true
    }
    
    //MARK: - Actions
    @objc private func didTapShowResultButton(_ sender: UIButton) {
        let image = canvasView.exportImageFromView()
        classify(image: image)
        looksLikeLabel.isHidden = false
        percentLabel.isHidden = false
    }
    
    @objc private func didTapClearButton(_ sender: UIButton) {
        canvasView.erase()
        hideLabels()
    }
}

//MARK: - Configure Views
extension CanvasViewController {
    private func configureBackgroundView() {
        view.addSubview(backgroundView)
        backgroundView.frame = view.bounds
    }
    
    private func configureCanvasView() {
        let padding: CGFloat = 16
        let width = view.frame.width - (padding * 2)
        
        view.addSubview(canvasView)
        NSLayoutConstraint.activate([
            canvasView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            canvasView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            canvasView.widthAnchor.constraint(equalToConstant: width),
            canvasView.heightAnchor.constraint(equalToConstant: width)
        ])
    }
    
    private func configureStackViews() {
        let padding: CGFloat = 16
        
        view.addSubview(buttonHorizontalStackView)
        view.addSubview(labelVerticalStackView)
        
        buttonHorizontalStackView.addArrangedSubview(showResultButton)
        buttonHorizontalStackView.addArrangedSubview(clearButton)
        labelVerticalStackView.addArrangedSubview(looksLikeLabel)
        labelVerticalStackView.addArrangedSubview(percentLabel)
        
        NSLayoutConstraint.activate([
            buttonHorizontalStackView.topAnchor.constraint(equalTo: canvasView.bottomAnchor, constant: padding),
            buttonHorizontalStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            buttonHorizontalStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            buttonHorizontalStackView.heightAnchor.constraint(equalToConstant: 40),
            labelVerticalStackView.topAnchor.constraint(equalTo: buttonHorizontalStackView.bottomAnchor, constant: padding),
            labelVerticalStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            labelVerticalStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
        ])
    }
}

//MARK: - CoreML Classify
extension CanvasViewController {
    private func classify(image: UIImage) {
        guard let ciImage = CIImage(image: image) else {
            print("Unable to create Image")
            return
        }
        let orientation = CGImagePropertyOrientation(image.imageOrientation)
        DispatchQueue.global(qos: .userInitiated).async {
            let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
            do {
                try handler.perform([self.classificationRequest])
            } catch {
                print("Failed to perform classification: \(error)")
            }
        }
    }
    
    func processObservations(for request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            if let results = request.results as? [VNClassificationObservation] {
                if results.isEmpty {
                    self.looksLikeLabel.text = "nothing found"
                } else if results[0].confidence < 0.8 {
                    self.looksLikeLabel.text = "not sure"
                } else {
                    self.looksLikeLabel.text = results[0].identifier
                    self.percentLabel.text = String(format: "%.1f%%", results[0].confidence * 100)
                }
            } else if let error = error {
                self.looksLikeLabel.text = "error: \(error.localizedDescription)"
            } else {
                self.looksLikeLabel.text = "???"
            }
        }
    }
}
