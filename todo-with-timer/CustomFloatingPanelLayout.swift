import FloatingPanel
import UIKit

class CustomFloatingPanelLayout: FloatingPanelLayout {
    var positionOfFull: CGFloat {
        switch (UIScreen.main.nativeBounds.height) {
        case 1334:
            // iPhone 6,6s,7,8,SE2
            return 36
        case 2340:
            // iPhone 12mini,13mini
            return 78
        case 2208:
            // iPhone 6Plus,6sPlus,7Plus,8Plus
            return 90
        case 2436:
            // iPhone X,XS,11Pro
            return 90
        case 1792:
            // iPhone XR,11
            return 150
        case 2532:
            // iPhone 12,13,12Pro,13Pro
            return 130
        case 2688:
            // iPhone XSMax,11ProMax
            return 160
        case 2778:
            // iPhone 12ProMax,13ProMax
            return 186
        default:
            return 0
        }
    }
    let position: FloatingPanelPosition = .bottom
    let initialState: FloatingPanelState = .half
    var anchors: [FloatingPanelState: FloatingPanelLayoutAnchoring] {
        return [
            .full: FloatingPanelLayoutAnchor(absoluteInset: positionOfFull, edge: .top, referenceGuide: .safeArea),
            .half: FloatingPanelLayoutAnchor(fractionalInset: 0.5, edge: .bottom, referenceGuide: .safeArea),
            .tip: FloatingPanelLayoutAnchor(absoluteInset: 44.0, edge: .bottom, referenceGuide: .safeArea)
        ]
    }
    
    func backdropAlpha(for state: FloatingPanelState) -> CGFloat {
        switch state {
        case .full, .half:
            return 0.3
        default:
            return 0.0
        }
    }
}
