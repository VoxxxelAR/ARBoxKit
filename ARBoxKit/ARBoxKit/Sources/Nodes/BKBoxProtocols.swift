//
//  BKBoxProtocols.swift
//  ARBoxKit
//
//  Created by Vadym Sidorov on 9/26/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import SceneKit
import ARKit

public enum BKBoxState {
    case normal
    case highlighted(face: [BKBoxFace], alpha: CGFloat)
    case hidden
    
    var id: Int {
        switch self {
        case .normal: return 0
        case .highlighted: return 1
        case .hidden: return 2
        }
    }
}

public enum BKBoxFace: Int {
    case front = 0, right, back, left, top, bottom
    
    static var all: [BKBoxFace] {
        return [front, right, back, left, top, bottom]
    }
}

public protocol BoxDisplayable: class {
    var boxGeometry: SCNBox { get }
    var currentState: BKBoxState { get set }
}

extension BoxDisplayable where Self: SCNNode {
    public var boxGeometry: SCNBox {
        guard let boxGeometry = geometry as? SCNBox else {
            fatalError("Geometry must be of SCNBox type.")
        }
        
        return boxGeometry
    }
}

extension BoxDisplayable where Self: SCNNode {
    
    func updateMaterials(for faces: [BKBoxFace], changes: (SCNMaterial) -> Void) {
        let materials = faces.flatMap { self.boxMaterial(for: $0) }
        
        materials.forEach { (material) in
            changes(material)
        }
    }
    
    func updateTransparency(for faces: [BKBoxFace], value: CGFloat,  _ animated: Bool, _ completion: (() -> Void)?) {
        let changes: () -> Void = {
            self.updateMaterials(for: faces) { (material) in
                material.transparency = value
            }
        }
        
        if !animated {
            changes()
            completion?()
        } else {
            SCNTransaction.animate(with: 0.3, timingFunction: .easeIn, changes, completion)
        }
    }
    
    func updateState(newState: BKBoxState, _ animated: Bool, _ completion: (() -> Void)?) {
        if currentState.id == newState.id { return }
        
        switch newState {
        case .normal:
            setNormalState(animated, completion)
        case .highlighted(let faces, let alpha):
            setHighlightedState(faces: faces, alpha: alpha, animated, completion)
        case .hidden:
            setHiddenState(animated, completion)
        }
        
        currentState = newState
    }
    
    func setNormalState(_ animated: Bool, _ completion: (() -> Void)?) {
        updateTransparency(for: BKBoxFace.all, value: 1, animated, completion)
    }
    
    func setHighlightedState(faces: [BKBoxFace], alpha: CGFloat, _ animated: Bool, _ completion: (() -> Void)?) {
        updateTransparency(for: faces, value: alpha, animated, completion)
    }
    
    func setHiddenState(_ animated: Bool, _ completion: (() -> Void)?) {
        updateTransparency(for: BKBoxFace.all, value: 0, animated, completion)
    }
}

extension BoxDisplayable {
    
    func setupGeometry() {
        let top = SCNMaterial()
        let bottom = SCNMaterial()
        let left = SCNMaterial()
        let right = SCNMaterial()
        let front = SCNMaterial()
        let back = SCNMaterial()
        
        boxGeometry.materials = [front, right, back, left, top, bottom]
    }
    
    public func applyColors() {
        //MARK: - For debug use
        let colors: [UIColor] = [.green, //front
            .red, //right
            .blue, //back
            .yellow, //left
            .purple, //top
            .gray] //bottom
        
        BKBoxFace.all.forEach { (face) in
            let material = boxMaterial(for: face)
            let color = colors[face.rawValue]
            
            material.diffuse.contents = color
            material.locksAmbientWithDiffuse = true
        }
    }
    
    public func boxMaterial(for face: BKBoxFace) -> SCNMaterial {
        return boxGeometry.materials[face.rawValue]
    }
}

