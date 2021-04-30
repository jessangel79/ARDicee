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

    @IBOutlet var sceneView: ARSCNView!
    
    // MARK: - Properties
    
    private var diceArray = [SCNNode]()
    
    // MARK: - Actions
    
    @IBAction private func rollAgain(_ sender: UIBarButtonItem) {
        rollAll()
    }
    
    @IBAction private func removeAllDices(_ sender: UIBarButtonItem) {
        if !diceArray.isEmpty {
            for dice in diceArray {
                dice.removeFromParentNode()
            }
        }
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
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
    
    private func addDice(atLocation location: ARRaycastResult) {
        guard let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn") else { return }
        guard let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) else { return }
        diceNode.position = SCNVector3(location.worldTransform.columns.3.x,
                                       location.worldTransform.columns.3.y + diceNode.boundingSphere.radius,
                                       location.worldTransform.columns.3.z)
        diceArray.append(diceNode)
        sceneView.scene.rootNode.addChildNode(diceNode)
        roll(diceNode)
    }
    
    private func roll(_ dice: SCNNode) {
        let randomX = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
        let randomZ = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
        dice.runAction(SCNAction.rotateBy(x: CGFloat(randomX * 5),
                                          y: 0,
                                          z: CGFloat(randomZ * 5),
                                          duration: 0.5))
    }
    
    private func rollAll() {
        if !diceArray.isEmpty {
            for dice in diceArray {
                roll(dice)
            }
        }
    }
    
//    private func getValueOfDice() {
//        var sortableDiceValues = [(value: Int, yPosition: CGFloat)]()
//
//    }
}

// MARK: - Extension ARSCNViewDelegateMethods

extension ViewController: ARSCNViewDelegate {

    // MARK: - Plane Rendering Methods

    private func createGrid(_ planeAnchor: ARPlaneAnchor, _ planeNode: SCNNode) {
        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        let gridMaterial = SCNMaterial()
        gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
//        gridMaterial.diffuse.contents = UIColor.clear
        gridMaterial.transparency = 0
        plane.materials = [gridMaterial]
        planeNode.geometry = plane
    }

    private func createPlane(withPlaneAnchor planeAnchor: ARPlaneAnchor) -> SCNNode {
        let planeNode = SCNNode()
        planeNode.position = SCNVector3(planeAnchor.center.x, 0, planeAnchor.center.z)
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
        createGrid(planeAnchor, planeNode)
        return planeNode
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        if let touch = touches.first {
        if let touchLocation = touches.first?.location(in: sceneView) {
            guard let query = sceneView.raycastQuery(from: touchLocation,
                                                     allowing: .existingPlaneInfinite,
                                                     alignment: .any) else { return }
            let results = sceneView.session.raycast(query)
            guard let hitTestResult = results.first else {
                print("No surface found")
                return
            }
            addDice(atLocation: hitTestResult)
        }
    }

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        let planeNode = createPlane(withPlaneAnchor: planeAnchor)
        node.addChildNode(planeNode)
    }

    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        rollAll()
    }
}
