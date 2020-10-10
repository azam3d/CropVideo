
import AVFoundation
import Photos
import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let videoURL = Bundle.main.url(forResource: "newYorkFlip", withExtension: "mp4")!
        
        squareCropVideo(inputURL: videoURL) { outputURL in
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputURL!)
            }) { saved, error in
                saved ? print("Save successful") : print("Save failed")
            }
        }
    }

    private func squareCropVideo(inputURL: URL, completion: @escaping (_ outputURL : URL?) -> ()) {
        let videoAsset = AVAsset(url: inputURL)
        let clipVideoTrack = videoAsset.tracks(withMediaType: .video ).first! as AVAssetTrack
        
//        let transform1 = CGAffineTransform(translationX: clipVideoTrack.naturalSize.height, y: (clipVideoTrack.naturalSize.width - clipVideoTrack.naturalSize.height) / 2)
//        let transform2 = transform1.rotated(by: .pi / 2)
//        let finalTransform = transform2
        
        let instruction = VideoHelper.videoCompositionInstruction(clipVideoTrack, asset: videoAsset)
        instruction.setOpacity(0.0, at: videoAsset.duration)
//        instruction.setTransform(finalTransform, at: .zero)

        let mainInstruction = AVMutableVideoCompositionInstruction()
        mainInstruction.timeRange = CMTimeRangeMake(start: .zero, duration: videoAsset.duration)
        mainInstruction.layerInstructions = [instruction]
        
        let videoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = CGSize(width: clipVideoTrack.naturalSize.height, height: clipVideoTrack.naturalSize.height )
        videoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
        videoComposition.instructions = [mainInstruction]

        // Export
        let exportSession = AVAssetExportSession(asset: videoAsset, presetName: AVAssetExportPresetHighestQuality)!

        let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0] + "/crop_video.mp4"
        
        let outputFileURL = URL(fileURLWithPath: path)
        try? FileManager.default.removeItem(at: outputFileURL)
        
        exportSession.outputURL = outputFileURL
        exportSession.outputFileType = .mov
        exportSession.videoComposition = videoComposition

        exportSession.exportAsynchronously {
            if exportSession.status == .completed {
                print("Export completed\n")
                DispatchQueue.main.async(execute: {
                    completion(outputFileURL)
                })
                return
            } else if exportSession.status == .failed {
                print("Export failed - \(String(describing: exportSession.error!))\n")
            }

            completion(nil)
            return
        }
    }
    
}
