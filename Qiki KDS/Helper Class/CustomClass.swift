//
//  CustomClass.swift
//  Qiki Cusine
//
//  Created by Nirmit Dagly on 25/11/21.
//

import Foundation
import UIKit

struct AppUtility {
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.orientationLock = orientation
        }
    }
    
    /// OPTIONAL Added method to adjust lock and rotate to the desired orientation
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation:UIInterfaceOrientation) {
        self.lockOrientation(orientation)
        
        UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
        UINavigationController.attemptRotationToDeviceOrientation()
    }
}

class CustomTextFieldDelegate: NSObject, UITextFieldDelegate {
    static var shared = CustomTextFieldDelegate()
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        //write code here...
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

class LeftAlignedCollectionViewFlowLayout: UICollectionViewFlowLayout {
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let sectionInsets = UIEdgeInsets(top: 0.0, left: 5.0, bottom: 0.0, right: 5.0)
        let attributes = super.layoutAttributesForElements(in: rect)
        
        var leftMargin = sectionInsets.left
        var maxY: CGFloat = -1.0
        attributes?.forEach { layoutAttribute in
            if layoutAttribute.frame.origin.y >= maxY {
                leftMargin = sectionInset.left
            }
            
            layoutAttribute.frame.origin.x = leftMargin
            
            leftMargin += layoutAttribute.frame.width + minimumInteritemSpacing
            maxY = max(layoutAttribute.frame.maxY, maxY)
        }
        
        return attributes
    }
}

open class TopAlignedCollectionViewFlowLayout: UICollectionViewFlowLayout {
    open override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let layoutAttributes = super.layoutAttributesForItem(at: indexPath)?.copy() as? UICollectionViewLayoutAttributes else { return nil }
        guard layoutAttributes.representedElementCategory == .cell else { return layoutAttributes }
        
        func layoutAttributesForRow() -> [UICollectionViewLayoutAttributes]? {
            guard let collectionView = collectionView else { return [layoutAttributes] }
            let contentWidth = collectionView.frame.size.width - sectionInset.left - sectionInset.right
            var rowFrame = layoutAttributes.frame
            rowFrame.origin.x = sectionInset.left
            rowFrame.size.width = contentWidth
            return super.layoutAttributesForElements(in: rowFrame)
        }
        
        let minYs = minimumYs(from: layoutAttributesForRow())
        guard let minY = minYs[layoutAttributes.indexPath] else { return layoutAttributes }
        layoutAttributes.frame = layoutAttributes.frame.offsetBy(dx: 0, dy: minY - layoutAttributes.frame.origin.y)
        return layoutAttributes
    }
    
    open override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElements(in: rect)?
            .map { $0.copy() } as? [UICollectionViewLayoutAttributes]
        
        let minimumYs = minimumYs(from: attributes)
        attributes?.forEach {
            guard $0.representedElementCategory == .cell else { return }
            guard let minimumY = minimumYs[$0.indexPath] else { return }
            $0.frame = $0.frame.offsetBy(dx: 0, dy: minimumY - $0.frame.origin.y)
        }
        return attributes
    }
    
    /// Returns the minimum Y values based for each index path.
    private func minimumYs(from layoutAttributes: [UICollectionViewLayoutAttributes]?) -> [IndexPath: CGFloat] {
        layoutAttributes?
            .reduce([CGFloat: (CGFloat, [UICollectionViewLayoutAttributes])]()) {
                guard $1.representedElementCategory == .cell else { return $0 }
                return $0.merging([ceil($1.center.y): ($1.frame.origin.y, [$1])]) {
                    ($0.0 < $1.0 ? $0.0 : $1.0, $0.1 + $1.1)
                }
            }
            .values.reduce(into: [IndexPath: CGFloat]()) { result, line in
                line.1.forEach { result[$0.indexPath] = line.0 }
            } ?? [:]
    }
}

class Logs {
    class func writeLog(onDate date: String, andDescription error: String) {
        let logData = "\n[\(date)] " + "and Description: \(error)"
        
        var textLog = TextLog()
        textLog.write(LogFileNames.logs.rawValue + "+" + logData)
    }
}
