

import UIKit
import AVFoundation
import Vision
import Firebase

class CO2EmissionViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    let db = Firestore.firestore()
    var color = "green"
    
    let carbonFootprintLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont(name: "Rockwell", size: 16)
        label.textColor = .black
        label.backgroundColor = .white
        label.alpha = 1.0
        label.numberOfLines = 0  // Allows the label to have multiple lines
        label.text = "Carbon Footprint"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let alternativesLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont(name: "Rockwell", size: 16)
        label.textColor = .black
        label.backgroundColor = .white
        label.alpha = 1.0
        label.numberOfLines = 0  // Allows the label to have multiple lines
        label.text = "Alternatives"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    
    let detectedObjectLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 24)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    // Capture
    var bufferSize: CGSize = .zero
    var inferenceTime: CFTimeInterval  = 0;
    private let session = AVCaptureSession()
    
    // UI/Layers
    @IBOutlet weak var previewView: UIView!
    var rootLayer: CALayer! = nil
    private var previewLayer: AVCaptureVideoPreviewLayer! = nil
    private var detectionLayer: CALayer! = nil
    private var inferenceTimeLayer: CALayer! = nil
    private var inferenceTimeBounds: CGRect! = nil
    
    // Vision
    private var requests = [VNRequest]()
    
    // Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCapture()
        setupOutput()
        setupLayers()
        try? setupVision()
        session.startRunning()
        // Add detected object label to the view
            self.view.addSubview(detectedObjectLabel)
            
            // Setup constraints
            NSLayoutConstraint.activate([
                detectedObjectLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 20),
                detectedObjectLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            ])
        // Add carbonFootprintLabel to the view
                self.view.addSubview(carbonFootprintLabel)

                // Setup constraints for carbonFootprintLabel
                NSLayoutConstraint.activate([
                    carbonFootprintLabel.topAnchor.constraint(equalTo: detectedObjectLabel.bottomAnchor, constant: 20),
                    carbonFootprintLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 20),
                    carbonFootprintLabel.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -20)
                ])
        
        
        self.view.addSubview(alternativesLabel)

        NSLayoutConstraint.activate([
            alternativesLabel.topAnchor.constraint(equalTo: carbonFootprintLabel.bottomAnchor, constant: 20),
            alternativesLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 20),
            alternativesLabel.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -20)
        ])


    }
    func boundingBoxColor(for objectName: String) -> CGColor {
        if objectName.lowercased() == "laptop" {
            return UIColor.yellow.cgColor
        } else {
            return UIColor.green.cgColor
        }
    }

    func setupCapture() {
        var deviceInput: AVCaptureDeviceInput!
        let videoDevice = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back).devices.first
        do {
            deviceInput = try AVCaptureDeviceInput(device: videoDevice!)
        } catch {
            print("Could not create video device input: \(error)")
            return
        }
        
        session.beginConfiguration()
        session.sessionPreset = .vga640x480
        
        guard session.canAddInput(deviceInput) else {
            print("Could not add video device input to the session")
            session.commitConfiguration()
            return
        }
        session.addInput(deviceInput)
        
        do {
            try  videoDevice!.lockForConfiguration()
            let dimensions = CMVideoFormatDescriptionGetDimensions((videoDevice?.activeFormat.formatDescription)!)
            bufferSize.width = CGFloat(dimensions.width)
            bufferSize.height = CGFloat(dimensions.height)
            videoDevice!.unlockForConfiguration()
        } catch {
            print(error)
        }
        session.commitConfiguration()
    }
    func fetchCarbonFootprint(objectName: String, completion: @escaping (String?) -> Void) {
        let db = Firestore.firestore()
        let co2emissionsCollection = db.collection("co2emissions")

        // Fetch the document where "Name" is equivalent to objectName
        co2emissionsCollection.whereField("Name", isEqualTo: objectName).getDocuments { (snapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
                completion(nil)
                return
            }

            // Since "Name" should ideally be unique, we take the first match
            if let document = snapshot?.documents.first {
                if let carbonFootprint = document.data()["Carbon Footprint"] as? String {
                    completion(carbonFootprint)
                } else {
                    print("Error: Carbon Footprint not found or not a string!")
                    completion(nil)
                }
            } else {
                print("Error: No document found with the given objectName!")
                completion(nil)
            }
        }
    }
    func fetchAlternatives(objectName: String, completion: @escaping (String?) -> Void) {
        let db = Firestore.firestore()
        let co2emissionsCollection = db.collection("co2emissions")

        // Fetch the document where "Name" is equivalent to objectName
        co2emissionsCollection.whereField("Name", isEqualTo: objectName).getDocuments { (snapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
                completion(nil)
                return
            }

            // Since "Name" should ideally be unique, we take the first match
            if let document = snapshot?.documents.first {
                if let alternatives = document.data()["Alternatives"] as? String {
                    completion(alternatives)
                } else {
                    print("Error: Alternatives not found or not a string!")
                    completion(nil)
                }
            } else {
                print("Error: No document found with the given objectName!")
                completion(nil)
            }
        }
    }
    func fetchColor(objectName: String, completion: @escaping (String?) -> Void) {
        let db = Firestore.firestore()
        let co2emissionsCollection = db.collection("co2emissions")

        // Fetch the document where "Name" is equivalent to objectName
        co2emissionsCollection.whereField("Name", isEqualTo: objectName).getDocuments { (snapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
                completion(nil)
                return
            }

            // Since "Name" should ideally be unique, we take the first match
            if let document = snapshot?.documents.first {
                if let alternatives = document.data()["color"] as? String {
                    completion(alternatives)
                } else {
                    print("Error: Color not found or not a string!")
                    completion(nil)
                }
            } else {
                print("Error: No document found with the given objectName!")
                completion(nil)
            }
        }
    }

    func setupOutput() {
        let videoDataOutput = AVCaptureVideoDataOutput()
        let videoDataOutputQueue = DispatchQueue(label: "VideoDataOutput", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
        
        if session.canAddOutput(videoDataOutput) {
            session.addOutput(videoDataOutput)
            videoDataOutput.alwaysDiscardsLateVideoFrames = true
            videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
            videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        } else {
            print("Could not add video data output to the session")
            session.commitConfiguration()
            return
        }
    }
    
    func setupLayers() {
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        rootLayer = previewView.layer
        previewLayer.frame = rootLayer.bounds
        rootLayer.addSublayer(previewLayer)
        
        inferenceTimeBounds = CGRect(x: rootLayer.frame.midX-75, y: rootLayer.frame.maxY-70, width: 150, height: 17)
        
//        inferenceTimeLayer = createRectLayer(inferenceTimeBounds, [1,1,1,1])
        inferenceTimeLayer = createRectLayer(inferenceTimeBounds, withColor: UIColor(red: 1, green: 1, blue: 1, alpha: 1))

        inferenceTimeLayer.cornerRadius = 7
        rootLayer.addSublayer(inferenceTimeLayer)
        
        detectionLayer = CALayer()
        detectionLayer.bounds = CGRect(x: 0.0,
                                         y: 0.0,
                                         width: bufferSize.width,
                                         height: bufferSize.height)
        detectionLayer.position = CGPoint(x: rootLayer.bounds.midX, y: rootLayer.bounds.midY)
        rootLayer.addSublayer(detectionLayer)
        
        let xScale: CGFloat = rootLayer.bounds.size.width / bufferSize.height
        let yScale: CGFloat = rootLayer.bounds.size.height / bufferSize.width
        
        let scale = fmax(xScale, yScale)
    
        // rotate the layer into screen orientation and scale and mirror
        detectionLayer.setAffineTransform(CGAffineTransform(rotationAngle: CGFloat(.pi / 2.0)).scaledBy(x: scale, y: -scale))
        // center the layer
        detectionLayer.position = CGPoint(x: rootLayer.bounds.midX, y: rootLayer.bounds.midY)
    }
    
    func setupVision() throws {
        guard let modelURL = Bundle.main.url(forResource: "yolov5n", withExtension: "mlmodelc") else {
            throw NSError(domain: "ViewController", code: -1, userInfo: [NSLocalizedDescriptionKey: "Model file is missing"])
        }
        
        do {
            let visionModel = try VNCoreMLModel(for: MLModel(contentsOf: modelURL))
            let objectRecognition = VNCoreMLRequest(model: visionModel, completionHandler: { (request, error) in
                DispatchQueue.main.async(execute: {
                    if let results = request.results {
                        self.drawResults(results)
                    }
                })
            })
            self.requests = [objectRecognition]
        } catch let error as NSError {
            print("Model loading went wrong: \(error)")
        }
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .right, options: [:])
        do {
            // returns true when complete https://developer.apple.com/documentation/vision/vnimagerequesthandler/2880297-perform
            let start = CACurrentMediaTime()
            try imageRequestHandler.perform(self.requests)
            inferenceTime = (CACurrentMediaTime() - start)

        } catch {
            print(error)
        }
    }
    func drawResults(_ results: [Any]) {
        for observation in results where observation is VNRecognizedObjectObservation {
            guard let objectObservation = observation as? VNRecognizedObjectObservation else {
                continue
            }

            // Detection with highest confidence
            let topLabelObservation = objectObservation.labels[0]
            //...
            // Update the label's text with the object's name
            self.detectedObjectLabel.text = "CO2 Analysis: \(topLabelObservation.identifier.capitalized)"
            //...
            print("topLabelObservation: \(topLabelObservation)")
            
            let objectName = "\(topLabelObservation.identifier)"
            
            print("objectName: \(objectName)")
            
            fetchCarbonFootprint(objectName: objectName) { (carbonFootprint) in
                if let carbonFootprint = carbonFootprint {
                    self.carbonFootprintLabel.text = "💨 \(carbonFootprint)"
                } else {
                    self.carbonFootprintLabel.text = "Couldn't fetch the Carbon Footprint!"
                }
            }
            fetchAlternatives(objectName: objectName) { (alternatives) in
                if let alternatives = alternatives {
                    self.alternativesLabel.text = "💚 \(alternatives)"
                } else {
                    self.alternativesLabel.text = "Couldn't fetch the Carbon Footprint!"
                }
            }
            fetchColor(objectName: objectName) { (fetchedColor) in
                if let fetchedColor = fetchedColor {
                    self.color = fetchedColor
                } else {
                    print("Couldn't fetch the color!")
                }
            }

        }
        
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        detectionLayer.sublayers = nil // Clear previous detections from detectionLayer
        inferenceTimeLayer.sublayers = nil
        for observation in results where observation is VNRecognizedObjectObservation {
            guard let objectObservation = observation as? VNRecognizedObjectObservation else {
                continue
            }
            
            // Detection with highest confidence
            let topLabelObservation = objectObservation.labels[0]
            
            // Rotate the bounding box into screen orientation
            let boundingBox = CGRect(origin: CGPoint(x:1.0-objectObservation.boundingBox.origin.y-objectObservation.boundingBox.size.height, y:objectObservation.boundingBox.origin.x), size: CGSize(width:objectObservation.boundingBox.size.height,height:objectObservation.boundingBox.size.width))
            
            let objectBounds = VNImageRectForNormalizedRect(boundingBox, Int(bufferSize.width), Int(bufferSize.height))
            
            var customColor: UIColor = .white
            
            
            //if u want random colors use this code and pass in the second arg as "customColor"
//            if let colorComponents = colors[topLabelObservation.identifier], colorComponents.count == 4 {
//                customColor = UIColor(red: colorComponents[0], green: colorComponents[1], blue: colorComponents[2], alpha: colorComponents[3])
//                // Use customColor wherever you need a UIColor
//            }
            
            


            switch color {
                case "green":
                    customColor = UIColor.green.withAlphaComponent(0.3)  // 50% opacity
                case "red":
                    customColor = UIColor.red.withAlphaComponent(0.3)    // 50% opacity
                case "yellow":
                    customColor = UIColor.yellow.withAlphaComponent(0.3) // 50% opacity
                default:
                    customColor = UIColor.clear // or some other default color
            }

            let shapeLayer = createRectLayer(objectBounds, withColor: customColor)


            let formattedString = NSMutableAttributedString(string: String(format: "\(topLabelObservation.identifier)\n %.1f%% ", topLabelObservation.confidence*100).capitalized)
            
            let textLayer = createDetectionTextLayer(objectBounds, formattedString)
            shapeLayer.addSublayer(textLayer)
            detectionLayer.addSublayer(shapeLayer)
        }
        
        let formattedInferenceTimeString = NSMutableAttributedString(string: String(format: "Inference time: %.1f ms ", inferenceTime*1000))
        
        let inferenceTimeTextLayer = createInferenceTimeTextLayer(inferenceTimeBounds, formattedInferenceTimeString)

        inferenceTimeLayer.addSublayer(inferenceTimeTextLayer)
        
        CATransaction.commit()
    }
        
    // Clean up capture setup
    func teardownAVCapture() {
        previewLayer.removeFromSuperlayer()
        previewLayer = nil
    }
    
}

