//
//  NewCollectionViewController.swift
//  Webant
//
//  Created by Bagrat Arutyunov on 29.05.2021.
//

import UIKit
import Alamofire
import Kingfisher

@available(iOS 12.1, *)
class NewCollectionViewController: UICollectionViewController {
    
    private var loadedFlag = false
    private var page = 1
    private var image: UIImage?
    private let refreshControl = UIRefreshControl()
    private var totalPage = 1
    private let bottomRefresh = UIActivityIndicatorView()
    private var isLoading = false
    
    @IBOutlet weak var noInternetView: UIView!
    @IBOutlet weak var noInternetImageView: UIImageView!
    @IBOutlet weak var noInternetLabel: UILabel!
    
    
    private var requestModel: RequestModel?
    private var photos: [DataModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setColectionView()
        DispatchQueue.main.async {
            self.loadData(page: self.page)
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView.reloadData()
    }
    
    // MARK: - Setup navigationbar
    
    private func setupNavigation() {
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.systemPink] 
    }
    
    
    // MARK: - CollectionView setting methods
    
    private func setColectionView() {
        refreshControl.addTarget(self, action:#selector(refreshData), for: UIControl.Event.valueChanged)
        collectionView.register(FooterView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                withReuseIdentifier: "MyFooterView")
        
        (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.footerReferenceSize = CGSize(width: collectionView.bounds.width, height: 50)
        collectionView.refreshControl = refreshControl
    }
    
    
    // MARK: - Loading methods
    
    @objc func refreshData() {
        collectionView.refreshControl?.beginRefreshing()
        page = 1
        loadedFlag = false
        photos.removeAll()
        DispatchQueue.main.async {
            self.loadData(page: self.page)
        }
        collectionView.refreshControl?.endRefreshing()
    }
    
    private func loadData(page: Int) {
        self.isLoading = true
        DispatchQueue.main.async {
            self.checkConnection()
        }
        DataLoader.shared.loadNewPhotos(page:page ,result: {[weak self] (model) in
            if model != nil{
                self?.requestModel = model
                self?.loadedFlag = true
                self?.photos.append(contentsOf: (model?.data)!)
                self?.totalPage = model?.countOfPages ?? 1
                self?.isLoading = false
                self?.collectionView.reloadData()
            } else {
                self?.photos.removeAll()
                self?.loadedFlag = false
                self?.isLoading = false
                DispatchQueue.main.async {
                    self?.checkConnection()
                }
            }
        })
    }
    
    private func checkConnection() {
        if !NetworkReachabilityManager()!.isReachable {
            photos.removeAll()
            bottomRefresh.stopAnimating()
            collectionView.refreshControl?.endRefreshing()
            noInternetView.isHidden = false
        } else {
            noInternetView.isHidden = true
        }
        collectionView.reloadData()
    }
    
    // MARK: - UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.reuseIdentifier, for: indexPath) as! ImageCollectionViewCell
        if loadedFlag{
            guard let imageName = photos[indexPath.row].image?.name
            else {
                return UICollectionViewCell()
            }
            DispatchQueue.main.async {
                cell.imageView.kf.indicatorType = .activity
                let resource = ImageResource(downloadURL: URL(string: "http://gallery.dev.webant.ru/media/\(imageName)")!, cacheKey: "http://gallery.dev.webant.ru/media/\(imageName)")
                cell.imageView.kf.setImage(with: resource)
                cell.imageView.contentMode = .scaleAspectFill
            }
        }
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView,
                                 viewForSupplementaryElementOfKind kind: String,
                                 at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter {
            if isLoading {
                let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "MyFooterView", for: indexPath)
                footer.addSubview(bottomRefresh)
                bottomRefresh.frame = CGRect(x: 0, y: 0, width: collectionView.bounds.width, height: 50)
                return footer
            } else {
                let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "MyFooterView", for: indexPath)
                return footer
            }
        }
        return UICollectionReusableView()
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if !isLoading {
            if indexPath.row == photos.count - 1 && page < totalPage {
                page += 1
                loadedFlag = false
                bottomRefresh.startAnimating()
                DispatchQueue.main.async {
                    self.loadData(page: self.page)
                }
            }
        }
        if page == totalPage {
            bottomRefresh.stopAnimating()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "DeteilController", sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DeteilController" {
            if let detailController = segue.destination as? DetailViewController,
               let row = (sender as? NSIndexPath)?.row {
                if self.photos.count >= row+1 {
                    guard let imageName = self.photos[row].image?.name
                    else {
                        return
                    }
                    let inputData = DetailControllerInput(imageRequestString: "http://gallery.dev.webant.ru/media/\(imageName)", titleLabelText: self.photos[row].name, textLabelText: self.photos[row].descr)
                    detailController.setupDataInController(inputData: inputData)
                } else {
                    let inputData = DetailControllerInput(titleLabelText: "", textLabelText: "OOPS! No internet connection")
                    detailController.setupDataInController(inputData: inputData)
                }
            }
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

@available(iOS 12.1, *)
extension NewCollectionViewController: UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat?
        if UIApplication.shared.statusBarOrientation.isPortrait {
            width =  (self.view.frame.size.width - 16*3) / 2
        }else {
            width =  (self.view.frame.size.width - 16*4) / 4
        }
        let size = CGSize(width: width! , height: (width!) * 13 / 17)
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int)->UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8)
    }
}

