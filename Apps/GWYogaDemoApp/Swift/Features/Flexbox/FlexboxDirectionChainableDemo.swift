import UIKit
import GWYoga
import GWYogaKit

class FlexboxDirectionChainableDemo: UIViewController {

    

    
    
    let thisview = UIView();
    let subView = UIView()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        view.style{
            $0.width(.points(Float(view.bounds.width)))
            $0.height(.points(Float(view.bounds.height)))
        }
       
        
        
        thisview.backgroundColor = UIColor.red;
        thisview
            .style
            .width(100%)
            .height(100%)
        view.addChild(thisview)
        view.performYogaLayout()
        thisview.performYogaLayout()
        
        subView.backgroundColor = .yellow
        subView.style.width(50%).height(50%)
        thisview.addChild(subView)
        thisview.performYogaLayout()
        
    }

    

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
          super.viewWillTransition(to: size, with: coordinator)
        print("viewWillTransition size=\(size) bounds=\(view.bounds)")
        view.style
              .width(.points(Float(size.width)))
              .height(.points(Float(size.height)))
        coordinator.animate(alongsideTransition: nil) { _ in
            print("completion bounds=\(self.view.bounds)")
                  self.view.performYogaLayout()
            print("after layout thisview.frame=\(self.thisview.frame) subView.frame=\(self.subView.frame)")
              }
      }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        
    }
}
