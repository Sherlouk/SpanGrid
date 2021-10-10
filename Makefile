ios:
	xcodebuild -scheme SpanGrid -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 8' test
macos:
	xcrun swift build --arch x86_64
	xcrun swift build --arch arm64
watchos:
	xcodebuild -scheme SpanGrid-watchOS -destination 'generic/platform=watchos' build
tvos:
	xcodebuild -scheme SpanGrid -destination 'generic/platform=tvos' build
catalyst:
	xcodebuild -scheme SpanGrid -sdk iphonesimulator -destination 'platform=macOS,arch=x86_64,variant=Mac Catalyst' build