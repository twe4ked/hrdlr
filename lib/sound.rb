class Sound
  def self.play(sound)
    if RUBY_PLATFORM =~ /darwin/
      system "afplay assets/sounds/#{sound}.m4a &"
    end
  end
end
