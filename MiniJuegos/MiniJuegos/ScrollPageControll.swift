import UIKit

class   ScrollPageControll: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var contentWidth: CGFloat = 0.0
    let imageNames = ["First", "Second", "Third", "Fourth"]
    
    let topLabels = [
                     "First Top",
                     "Second Top",
                     "Third Top",
                     "Fourth Top"
    ]
    
    let bottomLabels = [
                     "First Bottom",
                     "Second Bottom",
                     "Third Bottom",
                     "Fourth Bottom"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        
        for i in 0 ..< imageNames.count {
            let image = UIImage(named: "\(imageNames[i])")
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFit
            imageView.frame = CGRect(x: 0, y: 0, width: view.frame.width - 50, height: 40)
            
            let topLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width - 50, height: 25))
            let bottomLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width - 50, height: 100))
            
            topLabel.numberOfLines = 2
            bottomLabel.numberOfLines = 2
            
            topLabel.text = topLabels[i]
            bottomLabel.text = bottomLabels[i]
            
            topLabel.textColor = .black
            bottomLabel.textColor = .black
            
            topLabel.textAlignment = .center
            bottomLabel.textAlignment = .center
            
            topLabel.adjustsFontSizeToFitWidth = true
            bottomLabel.adjustsFontSizeToFitWidth = true
            
            topLabel.minimumScaleFactor = 0.5
            bottomLabel.minimumScaleFactor = 0.5
            
            topLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            bottomLabel.font = UIFont.systemFont(ofSize: 16)
            
            scrollView.addSubview(imageView)
            scrollView.addSubview(topLabel)
            scrollView.addSubview(bottomLabel)
            
            let centerX = view.frame.midX + view.frame.width * CGFloat(i)
            let centerY = view.frame.height / 2
            let trueCenter = CGPoint(x: centerX, y: centerY)
            
            imageView.center = trueCenter
            topLabel.center = trueCenter
            bottomLabel.center = trueCenter
            
            let imageFromTopLabelSeparation: CGFloat = 35.0
            let topLabelFromBottomLabelSeparation: CGFloat = 105.0
            
            let shiftUp: CGFloat = 100.0
            
            imageView.center.y = imageView.center.y - shiftUp
            topLabel.center.y = topLabel.center.y + imageFromTopLabelSeparation - shiftUp
            bottomLabel.center.y = bottomLabel.center.y + topLabelFromBottomLabelSeparation - shiftUp
            
            contentWidth += view.frame.width
        }
        
        scrollView.contentSize = CGSize(width: contentWidth, height: scrollView.frame.height)
        
    }
    
    @IBAction func goBackToSubscriptionPage(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
    
    // MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        pageControl.currentPage = Int(round(scrollView.contentOffset.x / view.frame.width))
    }
}
