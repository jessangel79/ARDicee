//
//  ViewController.swift
//  ARDicee
//
//  Created by Angelique Babin on 19/04/2021.
//

import UIKit
import SceneKit
import ARKit

final class ViewController: UIViewController {
    
    // MARK: - Outlets

    @IBOutlet private var sceneView: ARSCNView!
    
    // MARK: - Properties
    
    private var diceArray = [SCNNode]()
    
    // MARK: - Actions
    
    @IBAction func rollAgain(_ sender: UIBarButtonItem) {
        rollAll()
    }
    
    @IBAction func removeAllDices(_ sender: UIBarButtonItem) {
        if !diceArray.isEmpty {
            for dice in diceArray {
                dice.removeFromParentNode()
            }
        }
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        // Set the view's delegate
        sceneView.delegate = self
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
    
    /// Check compability of iPhone
    private func checkCompability() {
        print("Session is supported = \(ARConfiguration.isSupported)")
        print("Wolrd Tracking is supported = \(ARWorldTrackingConfiguration.isSupported)")
    }
    
    private func diceScn(hitResult: ARRaycastResult) { // SCNHitTestResult
        let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!
        guard let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) else { return }
        diceNode.position = SCNVector3(hitResult.worldTransform.columns.3.x,
                                       hitResult.worldTransform.columns.3.y + diceNode.boundingSphere.radius,
                                       hitResult.worldTransform.columns.3.z)
        diceArray.append(diceNode)
        sceneView.scene.rootNode.addChildNode(diceNode)
        roll(diceNode)
    }
    
    private func rollAll() {
        if !diceArray.isEmpty {
            for dice in diceArray {
                roll(dice)
            }
        }
    }
    
    private func roll(_ dice: SCNNode) {
        let randomX = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
        let randomZ = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
        dice.runAction(SCNAction.rotateBy(x: CGFloat(randomX * 5),
                                          y: 0,
                                          z: CGFloat(randomZ * 5),
                                          duration: 0.5))
    }

}

// MARK: - Extension ARSCNViewDelegate

extension ViewController: ARSCNViewDelegate {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: sceneView)
//            let resultsOld = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
//            let resultsOther = sceneView.hitTest(touchLocation, options: [SCNHitTestOption.searchMode: 1])
//            if !resultsOther.isEmpty {
//                print("touched the plane")
//            } else {
//                print("touched somewhere else")
//            }
            guard let query = sceneView.raycastQuery(from: touchLocation, allowing: .existingPlaneInfinite, alignment: .any) else {
                return
            }
            let results = sceneView.session.raycast(query)
            guard let hitTestResult = results.first else {
                print("No surface found")
                return
            }
            diceScn(hitResult: hitTestResult)
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
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        rollAll()
    }
}

// MARK: - Extension Tests

extension ViewController {
    
    /// test with ship
    private func baseScn() {
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!

        // Set the scene to the view
        sceneView.scene = scene
    }
    
    /// test with sphere
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
    
    /// test with cube
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
    
    /// test with basic dices
    private func diceScn() {
        let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!
        guard let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) else { return }
        diceNode.position = SCNVector3(0, 0, -0.1)
        sceneView.scene.rootNode.addChildNode(diceNode)
    }
}
