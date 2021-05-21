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
           cell.txtTitle.text = aqiArray![indexPath.row].title!
           //
           cell.imgView.loadImageUsingCache(withUrl: aqiArray![indexPath.row].url!)
           
        return cell
       }else{
        let errorCell = aqiCollectionView.dequeueReusableCell(withReuseIdentifier: "errorCell", for: indexPath)
        return errorCell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedRow = indexPath.row
        if aqiArray != nil {
            self.performSegue(withIdentifier: "userSelectSegue", sender: self)
        }
    }
    
    @IBOutlet weak var aqiCollectionView: UICollectionView!
    var selectedRow = 0
    var timer: Timer!
    var refreshControl: UIRefreshControl!
    var aqiArray :[ExCmoney]?
    
    //set 4 rows flowlayout
    let columnLayout = ColumnFlowLayout(
        cellsPerRow: 4,
        minimumInteritemSpacing: 1,
        minimumLineSpacing: 1,
        sectionInset: UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
    )
    
    override func viewWillAppear(_ animated: Bool) {
        //MARK: - fetch data in the first time
        if aqiArray == nil{
        getData()
        aqiCollectionView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set delgates
        aqiCollectionView.dataSource = self
        aqiCollectionView.delegate = self
        //set 4 rows
        aqiCollectionView?.collectionViewLayout = columnLayout
        aqiCollectionView?.contentInsetAdjustmentBehavior = .always
        //refresh
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(updateData), for: UIControl.Event.valueChanged)
        aqiCollectionView.addSubview(refreshControl)
        
        //MARK: - fetch data in the first time
        getData()
        
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
	
   
        if (segue.identifier == "userSelectSegue") {
            let nextVC =  segue.destination as! DetailViewController
            nextVC.passDate = self.aqiArray?[selectedRow].date
            nextVC.passHdurl = self.aqiArray?[selectedRow].hdurl
            nextVC.passTitle = self.aqiArray?[selectedRow].title
            nextVC.passDescription = self.aqiArray?[selectedRow].descriptionField
        }
        
    }
 

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
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = true // default is true
        // Springs and struts
        activityIndicator.center = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        activityIndicator.autoresizingMask = [
            .flexibleLeftMargin,
            .flexibleRightMargin,
            .flexibleTopMargin,
            .flexibleBottomMargin
        ]
        
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

