//
//  CollectionViewController.swift
//  Webant
//
//  Created by Bagrat Arutyunov on 29.05.2021.
//

import UIKit
import Alamofire
import Kingfisher
import RxSwift
import RxAlamofire

@available(iOS 12.1, *)
class CollectionViewController: UICollectionViewController {
    private var selectedVC = 0
    
    private let disposeBagNew = DisposeBag()
    private let disposeBagPop = DisposeBag()
    
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
    private var newPhotos: [DataModel] = []
    private var popularPhotos: [DataModel] = []
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if self.tabBarController?.selectedIndex == 0 {
            selectedVC = 0
        } else {
            if self.tabBarController?.selectedIndex == 1 {
                selectedVC = 1
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setColectionView()
        self.collectionView?.contentInsetAdjustmentBehavior = .always
        DispatchQueue.main.async {
            self.loadRx(page: 1)
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.collectionView.reloadSections(IndexSet(integer: 0))
    }
    
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        self.collectionView.contentInset.left = self.view.safeAreaInsets.left
        self.collectionView.contentInset.right = self.view.safeAreaInsets.right
    }
    
    // MARK: - Setup navigationbar
    
    private func setupNavigation() {
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.systemPink]
    }
    
    
    // MARK: - CollectionView setting methods
    
    private func setColectionView() {
        refreshControl.addTarget(self, action:#selector(refreshData), for: UIControl.Event.valueChanged)
        self.collectionView.register(FooterView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                withReuseIdentifier: "FooterView")
        
        (self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.footerReferenceSize = CGSize(width: self.collectionView.bounds.width, height: 50)
        self.collectionView.refreshControl = refreshControl
    }
    
    
    // MARK: - Loading methods
    
    @objc func refreshData() {
        self.collectionView.refreshControl?.beginRefreshing()
        page = 1
        loadedFlag = false
        switch selectedVC {
        case 0:
            newPhotos.removeAll()
        case 1:
            popularPhotos.removeAll()
        default:
            break
        }
        DispatchQueue.main.async {
            self.loadRx(page: self.page)
        }
        collectionView.refreshControl?.endRefreshing()
    }
    
    
    private func loadRx(page: Int) {
        self.isLoading = true
        DispatchQueue.main.async {
            self.checkConnection()
        }
        
        switch selectedVC {
        case 0:
            DataLoader.shared.loadNew(page: page, result: {[weak self] model in
            if model != nil {
                self?.requestModel = model
                self?.loadedFlag = true
                self?.newPhotos.append(contentsOf: (model?.data)!)
                self?.totalPage = model?.countOfPages ?? 1
                self?.isLoading = false
                self?.collectionView.reloadSections(IndexSet(integer: 0))
            } else {
                self?.newPhotos.removeAll()
                self?.loadedFlag = false
                self?.isLoading = false
            }
                
            })
        case 1:
            DataLoader.shared.loadPop(page: page, result: {[weak self] model in
            if model != nil {
                self?.requestModel = model
                self?.loadedFlag = true
                self?.popularPhotos.append(contentsOf: (model?.data)!)
                self?.totalPage = model?.countOfPages ?? 1
                self?.isLoading = false
                self?.collectionView.reloadSections(IndexSet(integer: 0))
            } else {
                self?.popularPhotos.removeAll()
                self?.loadedFlag = false
                self?.isLoading = false
            }
                
            })
        default:
            break
        }
        
    }
    
    private func checkConnection() {
        if !NetworkReachabilityManager()!.isReachable {
            newPhotos.removeAll()
            popularPhotos.removeAll()
            bottomRefresh.stopAnimating()
            collectionView.refreshControl?.endRefreshing()
            noInternetView.isHidden = false
        } else {
            noInternetView.isHidden = true
        }
        self.collectionView.reloadSections(IndexSet(integer: 0))
    }
    
    // MARK: - UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if selectedVC == 0 {
            return newPhotos.count
        } else {
            return popularPhotos.count
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var tempPhotos: [DataModel] = []
        
        switch selectedVC {
        case 0:
            tempPhotos = newPhotos
        case 1:
            tempPhotos = popularPhotos
        default:
            break
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.reuseIdentifier, for: indexPath) as! ImageCollectionViewCell
        if loadedFlag{
            guard let imageName = tempPhotos[indexPath.row].image?.name
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
                let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "FooterView", for: indexPath)
                footer.addSubview(bottomRefresh)
                bottomRefresh.frame = CGRect(x: 0, y: 0, width: collectionView.bounds.width, height: 50)
                return footer
            } else {
                let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "FooterView", for: indexPath)
                return footer
            }
        }
        return UICollectionReusableView()
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        var tempPhotos: [DataModel] = []
        switch selectedVC {
        case 0:
            tempPhotos = newPhotos
        case 1:
            tempPhotos = popularPhotos
        default:
            break
        }
        if !isLoading {
            if indexPath.row == tempPhotos.count - 1 && page < totalPage {
                page += 1
                loadedFlag = false
                bottomRefresh.startAnimating()
                DispatchQueue.main.async {
                    self.loadRx(page: self.page)
                }
            }
        }
        if page == totalPage {
            bottomRefresh.stopAnimating()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "DeteilController", sender: indexPath)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DeteilController" {
            var tempPhotos: [DataModel] = []
            switch selectedVC {
            case 0:
                tempPhotos = newPhotos
            case 1:
                tempPhotos = popularPhotos
            default:
                break
            }
            if let detailController = segue.destination as? DetailViewController,
               let row = (sender as? NSIndexPath)?.row {
                if tempPhotos.count >= row+1 {
                    guard let imageName = tempPhotos[row].image?.name
                    else {
                        return
                    }
                    let inputData = DetailControllerInput(imageRequestString: DataLoader.shared.photosUrl + imageName, titleLabelText: tempPhotos[row].name, textLabelText: tempPhotos[row].descr)
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
extension CollectionViewController: UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat?
        if UIApplication.shared.statusBarOrientation.isPortrait {
            width =  (self.view.frame.size.width - 12*3) / 2
        }else {
            width =  (self.view.frame.size.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right - 12*12) / 4
        }
        let size = CGSize(width: width! , height: (width!) * 13 / 17)
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int)->UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8)
    }
    
}

