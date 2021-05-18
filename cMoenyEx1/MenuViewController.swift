import UIKit

class MenuViewController: UIViewController, UICollectionViewDataSource,UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if aqiArray != nil {
            return self.aqiArray!.count
        }else{
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       if aqiArray != nil {
            let cell = aqiCollectionView.dequeueReusableCell(withReuseIdentifier: "aqiCell", for: indexPath) as! AqiCollectionViewCell
 
           let a = aqiArray![indexPath.row].title
           cell.btnTitle.setTitle(aqiArray![indexPath.row].title, for: .normal)
           cell.imgView.loadImageUsingCache(withUrl: aqiArray![indexPath.row].url!)
           // cell.imgView.loadImageUsingCache(withUrl: aqiArray![indexPath.row].hdurl!)
         return cell
       }else{
        let errorCell = aqiCollectionView.dequeueReusableCell(withReuseIdentifier: "errorCell", for: indexPath)
        
        return errorCell
        }
        
        
    }
    
    
    
    @IBOutlet weak var aqiCollectionView: UICollectionView!

    var timer: Timer!
    var refreshControl: UIRefreshControl!
    var aqiArray :[ExCmoney]?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        aqiCollectionView.dataSource = self
        aqiCollectionView.delegate = self
        
        //refresh
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(updateData), for: UIControl.Event.valueChanged)
        aqiCollectionView.addSubview(refreshControl)
//        aqiTabelView.addSubview(refreshControl)
        
        //MARK: - fetch data in the first time
        getData()
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    //timer refresh
    @objc func updateData() {
        DispatchQueue.main.async {
            self.getData()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1){
                self.refreshControl.endRefreshing()
            }
        }
    }
}

extension MenuViewController{
    func getData() {
        if let url = URL(string: AQI_URL!) {
            
            let task = URLSession.shared.dataTask(with: url)
            {(data, response, error) in
                
                let decoder = JSONDecoder() //透過 JSONDecoder 幫助我們解開 API 資訊
                
                //透過decoder 將我們自己定義的型別帶入，讓decoder 自動幫我們把資料配對進型別中
                if let data = data , let result = try? decoder.decode([ExCmoney].self, from: data){
                    
                    //取完資料後再將結果放進array中
                    
                    self.aqiArray = result
                    print (self.aqiArray?[0])
                    DispatchQueue.main.async {
                        //最後再重新讀取 tabelView 的資料一次
                        self.aqiCollectionView.reloadData()
                    }
                }
            }
            task.resume()
        }
    }
}

let imageCache = NSCache<NSString, UIImage>()
extension UIImageView {
    func loadImageUsingCache(withUrl urlString : String) {
        let url = URL(string: urlString)
        if url == nil {return}
        self.image = nil
        
        // check cached image
        if let cachedImage = imageCache.object(forKey: urlString as NSString)  {
            self.image = cachedImage
            return
        }
        
        let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView.init(style: .gray)
        addSubview(activityIndicator)
        activityIndicator.startAnimating()
        activityIndicator.center = self.center
        
        // if not, download image from url
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            if error != nil {
                print(error!)
                return
            }
            
            DispatchQueue.main.async {
                if let image = UIImage(data: data!) {
                    imageCache.setObject(image, forKey: urlString as NSString)
                    self.image = image
                    activityIndicator.removeFromSuperview()
                }
            }
            
        }).resume()
    }
}

