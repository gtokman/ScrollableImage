# ScrollableImage

Add zoom and scroll capabilites to Image



## Todo

- [ ] Figure out why the ScrollView isn't wraping the Image bounds
- [ ] Horizontal scroll sometimes doesn't work after zooming in
- [ ] Scrolling left cause Image to be offset and not re-centered
- [ ] Zoom out fast causes Image offset to the left, need to re-center
- [ ] Add ablity to hide grid
- [ ] Support for different aspect ratio changes on Image

## Usage 

```swift
var body: some View {
  ScrollViewImage(isScrolling: $isScrolling) {
      ScrollView(.horizontal) {
          Imge("my-image")
              .resizable()
              .aspectRatio(4/5, contentMode: .fit)
      }
  }
}
```


