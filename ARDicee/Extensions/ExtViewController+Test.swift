//
//  ExtViewController+Test.swift
//  ARDicee
//
//  Created by Angelique Babin on 28/04/2021.
//

import UIKit
import SceneKit
import ARKit

// MARK: - Extension Tests

extension ViewController {
    
    /// test with ship
    private func addBaseScn() {
        // Create a new scene
        guard let scene = SCNScene(named: "art.scnassets/ship.scn") else { return }

        // Set the scene to the view
        sceneView.scene = scene
    }
    
    /// test with sphere
    private func addSphereScn() {
        let sphere = SCNSphere(radius: 0.2)
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "art.scnassets/moon.jpg")
        sphere.materials = [material]
        
//        let node = SCNNode()
//        node.geometry = sphere // 2 lines equal to => let node = SCNNode(geometry: sphere)
        let node = SCNNode(geometry: sphere)
        node.position = SCNVector3(0, 0.1, -0.5)
        sceneView.scene.rootNode.addChildNode(node)
    }
    
    /// test with cube
    private func addCubeScn() {
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
    private func addDiceScn() {
        guard let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn") else { return }
        guard let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) else { return }
        diceNode.position = SCNVector3(0, 0, -0.1)
        sceneView.scene.rootNode.addChildNode(diceNode)
    }
}
