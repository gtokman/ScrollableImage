[![Swift Package Manager Compatible](https://img.shields.io/badge/spm-compatible-brightgreen.svg)](https://swift.org/package-manager)
![Swift 5.0](https://img.shields.io/badge/Swift-5.0-orange.svg)

# ScrollableImage

Add zoom and scroll capabilites to Image

## Demo

![2021-05-02 19 51 19](https://user-images.githubusercontent.com/12258850/116831870-fd12dc00-ab7f-11eb-9045-66d1b4ffa8e5.gif)

## Todo

- [ ] Figure out why the ScrollView isn't wraping the Image bounds
- [ ] Horizontal scroll sometimes doesn't work after zooming in
- [ ] Scrolling left cause Image to be offset and not re-centered
- [ ] Zoom out fast causes Image offset to the left, need to re-center
- [ ] Add ablity to hide grid
- [ ] Support for different aspect ratio changes on Image
- [ ] Add double tap gesture to zoom on Image
- [ ] Make parms to ScrollableImage optional

## Usage 

Add the package to Xcode `https://github.com/gtokman/ScrollableImage.git` and target the `main` branch, no officail release yet.


```swift
var body: some View {
  ScrollableImage(isScrolling: $isScrolling, offset: $offset) {
      ScrollView(.horizontal) {
          Image("name")
              .resizable()
              .aspectRatio(4/5, contentMode: .fit)
              .getRect(binding: $rect)
      }
   }
}
```

## Contribute 

Contributions are warmly welcomed! Feel free to reference the todos above or file an issue.

1. Clone repo, double click the `Package.swift` to open the project
2. Navigate to sources directory, theres a test image dir, helper dir, and file for the scrollable image code.
3. The preview works in the [ScrollableImage.swift](Sources/ScrollableImage/ScrollableImage.swift) if you want to see your changes live.
5. Open a PR 🚀

## Contact

[Twitter](https://twitter.com/f6ary)

## Liscense

MIT


