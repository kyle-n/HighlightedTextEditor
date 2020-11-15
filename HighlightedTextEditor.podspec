Pod::Spec.new do |spec|

  spec.name = 'HighlightedTextEditor'
  spec.version = '1.4.2'
  spec.summary = 'A SwiftUI view for dynamically highlighting user input'

  spec.description = <<-DESC
      HighlightedTextEditor is a simple, powerful SwiftUI text editor for iOS and macOS with live syntax highlighting. Highlight what's important as your users type.
    DESC

  spec.homepage = 'https://github.com/kyle-n/HighlightedTextEditor'
  spec.license = 'MIT'
  spec.author = { 'Kyle Nazario' => 'kylebnazario+hlte@gmail.com'}
  spec.source = { :git => 'https://github.com/kyle-n/HighlightedTextEditor.git', :tag => "#{spec.version}" }

  spec.source_files  = 'Sources', 'Sources/**/*.{swift}'
  spec.swift_versions = '5.3.1'
  spec.platforms = { :ios => '13.0', :osx => '10.15' }

end
