import AVFoundation
import SwiftUI

/// A protocol that represents the model for the camera view.
///
/// The AVFoundation camera APIs require running on a physical device. The app defines the model as a protocol to make it
/// simple to swap out the real camera for a test camera when previewing SwiftUI views.
@MainActor
//protocol Camera: AnyObject, SendableMetatype {
protocol Camera: AnyObject {

	/// Provides the current status of the camera.
	var status: CameraStatus { get }

	/// The camera's current activity state, which can be photo capture, movie capture, or idle.
	var captureActivity: CaptureActivity { get }

	/// The source of video content for a camera preview.
	var previewSource: PreviewSource { get }

	/// Starts the camera capture pipeline.
	func start() async

	/// The capture mode, which can be photo or video.
	var captureMode: CaptureMode { get set }

	/// A Boolean value that indicates whether the camera is currently switching capture modes.
	var isSwitchingModes: Bool { get }

	/// A Boolean value that indicates whether the camera prefers showing a minimized set of UI controls.
	var prefersMinimizedUI: Bool { get }

	/// Switches between video devices available on the host system.
	func switchVideoDevices() async

	/// A Boolean value that indicates whether the camera is currently switching video devices.
	var isSwitchingVideoDevices: Bool { get }

	/// Performs a one-time automatic focus and exposure operation.
	func focusAndExpose(at point: CGPoint) async

	/// A Boolean value that indicates whether to capture Live Photos when capturing stills.
	var isLivePhotoEnabled: Bool { get set }

	/// A value that indicates how to balance the photo capture quality versus speed.
	var qualityPrioritization: QualityPrioritization { get set }

	/// Captures a photo and writes it to the user's photo library.
	func capturePhoto() async

	/// A Boolean value that indicates whether to show visual feedback when capture begins.
	var shouldFlashScreen: Bool { get }

	/// A Boolean that indicates whether the camera supports HDR video recording.
	var isHDRVideoSupported: Bool { get }

	/// A Boolean value that indicates whether camera enables HDR video recording.
	var isHDRVideoEnabled: Bool { get set }

	/// Starts or stops recording a movie, and writes it to the user's photo library when complete.
	func toggleRecording() async

	/// A thumbnail image for the most recent photo or video capture.
	var thumbnail: CGImage? { get }

	/// An error if the camera encountered a problem.
	var error: Error? { get }

	/// Synchronize the state of the camera with the persisted values.
	func syncState() async
}

// MARK: - Supporting types

/// An enumeration that describes the current status of the camera.
enum CameraStatus {
	/// The initial status upon creation.
	case unknown
	/// A status that indicates a person disallows access to the camera or microphone.
	case unauthorized
	/// A status that indicates the camera failed to start.
	case failed
	/// A status that indicates the camera is successfully running.
	case running
	/// A status that indicates higher-priority media processing is interrupting the camera.
	case interrupted
}

/// An enumeration that defines the activity states the capture service supports.
///
/// This type provides feedback to the UI regarding the active status of the `CaptureService` actor.
enum CaptureActivity {
	case idle
	/// A status that indicates the capture service is performing photo capture.
	case photoCapture(willCapture: Bool = false, isLivePhoto: Bool = false)
	/// A status that indicates the capture service is performing movie capture.
	case movieCapture(duration: TimeInterval = 0.0)

	var isLivePhoto: Bool {
		if case .photoCapture(_, let isLivePhoto) = self {
			return isLivePhoto
		}
		return false
	}

	var willCapture: Bool {
		if case .photoCapture(let willCapture, _) = self {
			return willCapture
		}
		return false
	}

	var currentTime: TimeInterval {
		if case .movieCapture(let duration) = self {
			return duration
		}
		return .zero
	}

	var isRecording: Bool {
		if case .movieCapture(_) = self {
			return true
		}
		return false
	}
}

/// An enumeration of the capture modes that the camera supports.
enum CaptureMode: String, Identifiable, CaseIterable, Codable {
	var id: Self { self }
	/// A mode that enables photo capture.
	case photo
	/// A mode that enables video capture.
	case video

	var systemName: String {
		switch self {
		case .photo:
			"camera.fill"
		case .video:
			"video.fill"
		}
	}
}

/// A structure that represents a captured photo.
struct Photo: Sendable {
	let data: Data
	let dataPreview: Data
	let isProxy: Bool
	let livePhotoMovieURL: URL?
}

/// A structure that contains the uniform type identifier and movie URL.
struct Movie: Sendable {
	/// The temporary location of the file on disk.
	let url: URL
}

struct PhotoFeatures {
	let isLivePhotoEnabled: Bool
	let qualityPrioritization: QualityPrioritization
}

/// A structure that represents the capture capabilities of `CaptureService` in
/// its current configuration.
struct CaptureCapabilities {

	let isLivePhotoCaptureSupported: Bool
	let isHDRSupported: Bool

	init(
		isLivePhotoCaptureSupported: Bool = false,
		isHDRSupported: Bool = false
	) {
		self.isLivePhotoCaptureSupported = isLivePhotoCaptureSupported
		self.isHDRSupported = isHDRSupported
	}

	static let unknown = CaptureCapabilities()
}

enum QualityPrioritization: Int, Identifiable, CaseIterable, CustomStringConvertible, Codable {
	var id: Self { self }
	case speed = 1
	case balanced
	case quality
	var description: String {
		switch self {
		case .speed:
			return "Speed"
		case .balanced:
			return "Balanced"
		case .quality:
			return "Quality"
		}
	}
}

enum CameraError: Error {
	case videoDeviceUnavailable
	case audioDeviceUnavailable
	case addInputFailed
	case addOutputFailed
	case setupFailed
	case deviceChangeFailed
}

protocol OutputService {
	associatedtype Output: AVCaptureOutput
	var output: Output { get }
	var captureActivity: CaptureActivity { get }
	var capabilities: CaptureCapabilities { get }
	func updateConfiguration(for device: AVCaptureDevice)
	func setVideoRotationAngle(_ angle: CGFloat)
}

extension OutputService {
	func setVideoRotationAngle(_ angle: CGFloat) {
		// Set the rotation angle on the output object's video connection.
		output.connection(with: .video)?.videoRotationAngle = angle
	}
	func updateConfiguration(for device: AVCaptureDevice) {}
}
