class ModelNidusPreview: ModelNidus {
	init(audio: ModelAudio = ModelAudioPreview()) {
		super.init()
		self.audio = audio
	}
}
