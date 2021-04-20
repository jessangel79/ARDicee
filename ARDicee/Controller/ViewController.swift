//
//  ViewController.swift
//  ARDicee
//
//  Created by Angelique Babin on 19/04/2021.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController {
    
    // MARK: - Outlets

    @IBOutlet var sceneView: ARSCNView!
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        // Set the view's delegate
        sceneView.delegate = self
        
//        baseScn()
//        cubeScn()
//        sphereScn()
        
//        diceScn()
        
        sceneView.autoenablesDefaultLighting = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
//        checkCompability()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // MARK: - Methods
    
    private func checkCompability() {
        print("Session is supported = \(ARConfiguration.isSupported)")
        print("Wolrd Tracking is supported = \(ARWorldTrackingConfiguration.isSupported)")
    }
    
    private func diceScn() {
        let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!
        guard let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) else { return }
        diceNode.position = SCNVector3(0, 0, -0.1)
        sceneView.scene.rootNode.addChildNode(diceNode)
        
    }
    
    private func baseScn() {
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!

        // Set the scene to the view
        sceneView.scene = scene
    }
    
    private func sphereScn() {
        let sphere = SCNSphere(radius: 0.2)
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "art.scnassets/moon.jpg")
        sphere.materials = [material]
        
        let node = SCNNode()
        node.position = SCNVector3(0, 0.1, -0.5)
        node.geometry = sphere
        sceneView.scene.rootNode.addChildNode(node)
    }
    
    private func cubeScn() {
        let cube = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.01)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        cube.materials = [material]
        
        let node = SCNNode()
        node.position = SCNVector3(0, 0.1, -0.5)
        node.geometry = cube
        sceneView.scene.rootNode.addChildNode(node)
    }
}

// MARK: - Extension ARSCNViewDelegate

extension ViewController: ARSCNViewDelegate {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: sceneView)
//            let resultsOld = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            let results = sceneView.hitTest(touchLocation, options: [SCNHitTestOption.searchMode: 1])
            if !results.isEmpty {
                print("touched the plane")
            } else {
                print("touched somewhere else")
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if anchor is ARPlaneAnchor {
//            print("Plane detected")
            guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
            let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
            
            let planeNode = SCNNode()
            planeNode.position = SCNVector3(planeAnchor.center.x, 0, planeAnchor.center.z)
            planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
            
            let gridMaterial = SCNMaterial()
            gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
            plane.materials = [gridMaterial]
            planeNode.geometry = plane
            node.addChildNode(planeNode)
            
        } else {
            return
        }
    }
}
