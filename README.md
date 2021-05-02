# ScrollableImage

Add zoom and scroll capabilites to Image

## Demo

![2021-05-02 18 28 12](https://user-images.githubusercontent.com/12258850/116829897-9d630380-ab74-11eb-9dbe-fd2fd22a858e.gif)

## Todo

- [ ] Figure out why the ScrollView isn't wraping the Image bounds
- [ ] Horizontal scroll sometimes doesn't work after zooming in
- [ ] Scrolling left cause Image to be offset and not re-centered
- [ ] Zoom out fast causes Image offset to the left, need to re-center
- [ ] Add ablity to hide grid
- [ ] Support for different aspect ratio changes on Image
- [ ] Add double tap gesture to zoom on Image

## Usage 

Add the package to Xcode `https://github.com/gtokman/ScrollableImage.git` and target the `main` branch, no officail release yet.


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


