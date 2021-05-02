import SwiftUI

// MARK: - View

public extension View {
    func scrollViewIsScrolling(_ isScrolling: Binding<Bool>) -> some View {
        return ScrollViewZoomableImageRepresentable(isScrolling: isScrolling) { self }
    }
}

// MARK: - View Representable

public struct ScrollViewZoomableImageRepresentable<Content>: UIViewControllerRepresentable where Content: View {
    var isScrolling: Binding<Bool>
    let content: Content

    init(isScrolling: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) {
        self.isScrolling = isScrolling
        self.content = content()
    }

    public func makeUIViewController(context: Context) -> ScrollViewZoomableImage<Content> {
        ScrollViewZoomableImage(isScrolling: isScrolling, rootView: content)
    }

    public func updateUIViewController(_ uiViewController: ScrollViewZoomableImage<Content>, context: Context) {
        // update
    }
}

// MARK: - View Controller

public class ScrollViewZoomableImage<Content>: UIHostingController<Content>, UIScrollViewDelegate where Content: View {

    var isScrolling: Binding<Bool>
    var showed = false
    private var scrollView: UIScrollView?
    private var imageView: UIView?

    var vLines = [
        UIView(),
        UIView(),
        UIView(),
        UIView(),
    ]
    var hLines = [
        UIView(),
        UIView(),
        UIView(),
        UIView(),
    ]
    lazy var hStack = UIStackView(arrangedSubviews: hLines)
    lazy var vStack = UIStackView(arrangedSubviews: vLines)
    
    var showGrid: Bool {
        get {
            hLines.first?.isHidden ?? false
        }
        set {
            zip(hLines, vLines).forEach {
                $0.alpha = newValue ? 1 : 0
                $1.alpha = newValue ? 1 : 0
            }
        }
    }

    init(isScrolling: Binding<Bool>, showGrid: Bool = true, rootView: Content) {
        self.isScrolling = isScrolling
        super.init(rootView: rootView)
        self.showGrid = showGrid
    }
    
    @objc dynamic required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidAppear(_ animated: Bool) {
        if showed {
            return
        }
        showed = true

        scrollView = findView(in: view)
        imageView = scrollView?.subviews.first
        scrollView?.delegate = self
        scrollView?.contentInsetAdjustmentBehavior = .never
        scrollView?.showsVerticalScrollIndicator = false
        scrollView?.showsHorizontalScrollIndicator = false
        scrollView?.alwaysBounceVertical = true
        scrollView?.decelerationRate = .fast
        scrollView?.maximumZoomScale = 3
        scrollView?.layer.borderWidth = 1
        scrollView?.isDirectionalLockEnabled = false

        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        gesture.numberOfTapsRequired = 2
        imageView?.addGestureRecognizer(gesture)
        
        scrollView?.addObserver(self,
                                forKeyPath: #keyPath(UIScrollView.contentSize),
                                options: [.old, .new],
                                context: nil)

        setupGrid()
        setMinZoomScaleForImageSize(imageView?.bounds.size ?? .zero)

        super.viewDidAppear(animated)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        scrollView?
            .removeObserver(
                self, forKeyPath: #keyPath(UIScrollView.contentSize), context: nil)
    }
    
    public override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {

        if keyPath == #keyPath(UIScrollView.contentSize) {
            if let scrollView = self.scrollView {
                DispatchQueue.main.async {
                    self.vStack.frame = scrollView.bounds
                    self.hStack.frame = scrollView.bounds
                }
            }
        }

    }
    
    // MARK - Helpers
    
    private func setMinZoomScaleForImageSize(_ imageSize: CGSize) {
        let widthScale = view.frame.width / imageSize.width
        let heightScale = view.frame.height / imageSize.height
        let minScale = min(widthScale, heightScale)

        // Scale the image down to fit in the view
        scrollView?.minimumZoomScale = minScale
        scrollView?.zoomScale = minScale

        // Set the image frame size after scaling down
        let imageWidth = imageSize.width * minScale
        let imageHeight = imageSize.height * minScale
        let newImageFrame = CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight)
        imageView?.frame = newImageFrame

        if let imageView = imageView {
            centerImage(imageView: imageView)
        }
    }
    
    private func centerImage(imageView: UIView) {
        let imageViewSize = imageView.frame.size
        let scrollViewSize = scrollView?.frame.size ?? view.frame.size
        let verticalPadding = imageViewSize.height < scrollViewSize.height ? (scrollViewSize.height - imageViewSize.height) / 2 : 0
        let horizontalPadding = imageViewSize.width < scrollViewSize.width ? (scrollViewSize.width - imageViewSize.width) / 2 : 0
        
        scrollView?.contentInset = UIEdgeInsets(top: verticalPadding, left: horizontalPadding, bottom: verticalPadding, right: horizontalPadding)
    }

    @objc
    func handleDoubleTap(_ gestureRecognizer: UIGestureRecognizer) {
    }
    
    // MARK - Helpers

    func setupGrid() {
        vLines.enumerated().forEach { index, view in
            view.backgroundColor =
                (index == vLines.startIndex || index == vLines.count - 1)
                ? .clear
            : .white
            view.widthAnchor.constraint(equalToConstant: 0.5).isActive = true
            view.isUserInteractionEnabled = false
        }
        hLines.enumerated().forEach { index, view in
            view.backgroundColor =
                (index == hLines.startIndex || index == hLines.count - 1)
                ? .clear
            : .white
            view.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
            view.isUserInteractionEnabled = false
        }

        hStack.axis = .vertical
        hStack.distribution = .equalSpacing

        vStack.distribution = .equalSpacing

        scrollView?.addSubview(vStack)
        scrollView?.addSubview(hStack)

        vStack.frame = scrollView?.bounds ?? .zero
        hStack.frame = scrollView?.bounds ?? .zero

        showGrid = false
    }

    func findView<T: UIView>(in view: UIView?) -> T? {
        if view?.isKind(of: T.self) ?? false {
            return view as? T
        }

        for subview in view?.subviews ?? [] {
            if let sv = findView(in: subview) {
                return sv as? T
            }
        }

        return nil
    }

    // MARK - UIScrollViewDelegate

    public func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        showGrid = true
    }
    public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        showGrid = false
    }

    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isScrolling.wrappedValue = true
        showGrid = true
    }

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        isScrolling.wrappedValue = false
        showGrid = false
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        showGrid = false
    }

    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
}

// MARK - Test View

@available(iOS 14, *)
struct ScrollPreview: View {
    
    @State var isScrolling: Bool = false
    @State var rect: CGRect = .zero
    
    var image: Image {
        Image("feed-image", bundle: .module)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text("Image size \(rect.size.width), \(rect.size.height)")
                    Spacer()
                    Button(action: {}, label: {
                        Image(systemName: "square.grid.3x2")
                    })
                }.padding([.horizontal, .top])
                ScrollViewZoomableImageRepresentable(isScrolling: $isScrolling) {
                    ScrollView(.horizontal) {
                        image
                            .resizable()
                            .aspectRatio(4/5, contentMode: .fit)
                    }
                }
                .getRect(binding: $rect)
                HStack {
                    Button(action: {}, label: {
                        Text("Do something")
                    })
                }
                Spacer()
            }.navigationTitle(Text("Home"))
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK - Preview

@available(iOS 14, *)
struct ScrollViewThing_Preview: PreviewProvider {

    static var previews: some View {
        ScrollPreview()
    }
}

extension View {
    func getRect(binding: Binding<CGRect>) -> some View {
        self.background(RectGetter(rect: binding))
    }
}
