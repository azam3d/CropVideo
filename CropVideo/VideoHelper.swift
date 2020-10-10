
import AVFoundation
import MobileCoreServices
import UIKit

class VideoHelper {
  
    static func orientation(from transform: CGAffineTransform) -> (orientation: UIImage.Orientation, isPortrait: Bool) {
        var assetOrientation = UIImage.Orientation.up
        var isPortrait = false

        if transform.a == 0 && transform.b == 1.0 && transform.c == -1.0 && transform.d == 0 {
            assetOrientation = .right
            isPortrait = true
        } else if transform.a == 0 && transform.b == -1.0 && transform.c == 1.0 && transform.d == 0 {
            assetOrientation = .left
            isPortrait = true
        } else if transform.a == 1.0 && transform.b == 0 && transform.c == 0 && transform.d == 1.0 {
            assetOrientation = .up
        } else if transform.a == -1.0 && transform.b == 0 && transform.c == 0 && transform.d == -1.0 {
            assetOrientation = .down
        }
        return (assetOrientation, isPortrait)
    }
  
    static func videoCompositionInstruction(_ track: AVAssetTrack, asset: AVAsset)  -> AVMutableVideoCompositionLayerInstruction {
        let instruction = AVMutableVideoCompositionLayerInstruction(assetTrack: track)
        let assetTrack = asset.tracks(withMediaType: .video)[0]

        let transform = assetTrack.preferredTransform

        let assetWidth = assetTrack.naturalSize.width
        let assetHeight = assetTrack.naturalSize.height

        let scaleToFitRatio = assetHeight / assetWidth
        
        let translate = CGAffineTransform(translationX: (assetTrack.naturalSize.width - assetTrack.naturalSize.height) / 2, y: 0.0)
        let scaleFactor = translate.concatenating(CGAffineTransform(scaleX: scaleToFitRatio, y: scaleToFitRatio))
        instruction.setTransform(transform.concatenating(scaleFactor), at: .zero)
        return instruction
    }

}
