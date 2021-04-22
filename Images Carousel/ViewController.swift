//
//  ViewController.swift
//  Images Carousel
//
//  Created by Dina Reda on 4/22/21.
//

import UIKit

class ViewController: UIViewController,UIScrollViewDelegate {
    
    @IBOutlet weak var imageSliderContainer: UIView!
    
    @IBOutlet weak var searchListBar: UISearchBar!
    @IBOutlet weak var ImagesTableView: UITableView!
    var sliderIndex = 0
    var sliderImagesArr = [Array<Any>]()
   
    var SearchBarValue:String!
    var searchActive : Bool = false
    var allData = [String:Array<Any>]()
    var filteredData = [String:Array<Any>]()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        searchListBar.showsCancelButton = false
        searchListBar.delegate = self
        ImagesTableView.register(UINib(nibName: "ImageTableViewCell", bundle: nil), forCellReuseIdentifier: "ImageTableViewCell")
       

       sliderImagesArr =  self.GetPlistArrValues(PlistID: "Info", Key: "images")
        let imageItems = sliderImagesArr[sliderIndex][1] as! Array<Any>
        let lableItems = sliderImagesArr[sliderIndex][2] as! Array<Any>
        allData["images"] = imageItems
        allData["labels"] = lableItems
        ImagesTableView.dataSource = self
        ImagesTableView.delegate = self
        let screenSize: CGRect = UIScreen.main.bounds

                
                // create the UISCrollView
        //let width = imageSliderContainer.window?.widthAnchor as! Int
        //let hight = imageSliderContainer.window?.heightAnchor as! Int
        let tipsScrollerView = UIScrollView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: 300))
        tipsScrollerView.delegate = self
                tipsScrollerView.contentInsetAdjustmentBehavior = .never
                tipsScrollerView.bounces = false
                // if needed, hide the indicator
                tipsScrollerView.showsHorizontalScrollIndicator = false
                tipsScrollerView.showsVerticalScrollIndicator = false
                
                // enable paginated scrolling
                tipsScrollerView.isPagingEnabled = true
              
               
                // loops on [UIImage]
                for i in 0..<sliderImagesArr.count {
        //            // calcuate the horizontal offset
                   let offset = i == 0 ? 0 : (CGFloat(i) * tipsScrollerView.frame.width)
        //            // create a UIImageView
                  
                    let AppTipsView = (Bundle.main.loadNibNamed("ImageView", owner: self, options: nil))?[0] as! ImageViewController
                    AppTipsView.frame = CGRect(x: offset, y: 0, width: tipsScrollerView.frame.width, height: tipsScrollerView.frame.height)
                    

                   
                    AppTipsView.imageItem_img.image = UIImage(named: sliderImagesArr[i][0] as! String)
                    AppTipsView.imageItem_img.contentMode = .scaleAspectFill
                    AppTipsView.imageItem_img.clipsToBounds = false
    
                    // add the UIImageView to the UIScrollView
                    tipsScrollerView.addSubview(AppTipsView)
                }
        
                // set the contentSize
                tipsScrollerView.contentSize = CGSize(width: CGFloat(sliderImagesArr.count) * tipsScrollerView.frame.width, height: tipsScrollerView.frame.height)
                imageSliderContainer.addSubview(tipsScrollerView)
        //
    }
    
    func GetPlistArrValues(PlistID : String , Key : String ) -> [Array<Any>]
        {
        var Result  = [Array<Any>] ()
                if let path = Bundle.main.path(forResource: PlistID, ofType: "plist") {
                    let dictRoot = NSDictionary(contentsOfFile: path)
                    if let dict = dictRoot {
                        debugPrint(dict[Key] )
                        Result = dict[Key] as! [Array<Any>]
                    }
                }
            return Result;
        }
    
    
}




extension ViewController:UIGestureRecognizerDelegate{
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return true
      }

      func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
      }




      func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if sliderIndex < sliderImagesArr.count{
        let page = Double(scrollView.contentOffset.x / scrollView.frame.size.width);
        sliderIndex = Int(round(page))
        ImagesTableView.reloadData()
        }else{
            sliderIndex = 0
        }
        let imageItems = sliderImagesArr[sliderIndex][1] as! Array<Any>
        let lableItems = sliderImagesArr[sliderIndex][2] as! Array<Any>
        allData["images"] = imageItems
        allData["labels"] = lableItems
      }
    
}

extension ViewController:UISearchBarDelegate{
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchActive = true
        }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
            searchActive = false
        }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            searchActive = false;

            searchBar.text = nil
            searchBar.resignFirstResponder()
            ImagesTableView.resignFirstResponder()
            self.searchListBar.showsCancelButton = false
            ImagesTableView.reloadData()
        }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            searchActive = false
        }

    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
                    return true
        }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == nil || searchText == "" {

            self.searchActive = false
            view.endEditing(true)
            self.ImagesTableView.reloadData()

           } else {
            
            self.searchActive = true;
            self.searchListBar.showsCancelButton = true

            filteredData.removeAll()
            filteredData["images"] = allData["images"] as! Array<Any>
            filteredData["labels"] = (self.allData["labels"] as! Array<Any>).filter({($0 as! String).lowercased().contains(searchText.lowercased())})
                self.ImagesTableView.reloadData()

        }
}

}

extension ViewController : UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(searchActive){
            guard let items = filteredData["labels"] as? Array<Any> else {
                return 0
            }
            
            return items.count
        }
        let items = allData["labels"] as! Array<Any>
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ImageTableViewCell", for: indexPath) as! ImageTableViewCell
        var imageItems = Array<Any>()
        var labelItems = Array<Any>()
        if(searchActive){
            imageItems = filteredData["images"]!
            labelItems = filteredData["labels"]!
        }else{
            imageItems = allData["images"]!
            labelItems = allData["labels"]!
        }
        
        cell.imageItem.image = UIImage(named: imageItems[indexPath.row] as! String)
        cell.labelItme.text = labelItems[indexPath.row] as? String
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
}
