//
//  EventBannerTableViewCell.swift
//  KpopMusicCharts
//
//  Created by HanaHan on 2021/01/17.
//

import UIKit

class EventBannerTableViewCell: UITableViewCell {
    @IBOutlet weak var bannerCollectionView: UICollectionView!
    let bannerImages : [String] = ["header_banner1", "header_banner2", "header_banner3", "header_banner4", "header_banner5", "header_banner6"]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCollectionView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func setupCollectionView() {
        bannerCollectionView.dataSource = self
        bannerCollectionView.delegate = self
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.itemSize = CGSize(width: 400, height: 200)
        flowLayout.minimumLineSpacing = 5.0
        flowLayout.minimumInteritemSpacing = 10.0
        self.bannerCollectionView.collectionViewLayout = flowLayout
        self.bannerCollectionView.register(UINib.init(nibName: "BannerCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "BannerCollectionViewCell")
    }
}

extension EventBannerTableViewCell : UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        bannerImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BannerCollectionViewCell", for: indexPath as IndexPath) as? BannerCollectionViewCell else { return UICollectionViewCell() }
        let image = UIImage(named: "\(bannerImages[indexPath.row])")
        cell.bannerImage.image = image
        return cell
    }
}
