//
//  ViewController.swift
//  KpopMusicCharts
//
//  Created by Mac on 2020/12/24.
//

import UIKit
import Firebase
import FirebaseFirestore

class MelonViewController: UIViewController {
    @IBOutlet weak var melonTableView: UITableView!
    var songs :[Song] = []
    let searchController = UISearchController(searchResultsController: nil)
    var isDesc : Bool = true
    var filteredSongs = [Song]()
    var isFiltering: Bool {
        let searchController = self.navigationItem.searchController
        let isActive = searchController?.isActive ?? false
        let isSearchBarHasText = searchController?.searchBar.text?.isEmpty == false
        return isActive && isSearchBarHasText
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupSearchController()
        fetchData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @IBAction func sortSongByRank(_ sender: Any) {
        songs = songs.reversed()
        melonTableView.reloadData()
        if isDesc {
            isDesc = false
        } else {
            isDesc = true
        }

    }
    
    private func setupUI() {
        melonTableView.delegate = self
        melonTableView.dataSource = self
        melonTableView.register(UINib(nibName: "SongTableViewCell", bundle: nil), forCellReuseIdentifier: "songCell")
        melonTableView.register(UINib(nibName: "EventBannerTableViewCell", bundle: nil), forCellReuseIdentifier: "EventBannerTableViewCell")
        let headerNib = UINib.init(nibName: "MainHeader", bundle: Bundle.main)
        melonTableView.register(headerNib, forHeaderFooterViewReuseIdentifier: "MainHeader")
    }
    
    private func setupSearchController() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "곡 제목 검색"
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchResultsUpdater = self
        self.navigationItem.searchController = searchController
        self.navigationItem.title = "검색"
        self.navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }

    func fetchData()  {
        let docRef = Firestore.firestore().collection("songs")
        docRef.whereField("from", isEqualTo: "Melon").getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    var count : Int = 0
                    for document in querySnapshot!.documents {
                        guard let title = document.data()["title"] as? String else {return}
                        guard let artist = document.data()["artist"] as? String else {return}
                        guard let url = document.data()["url"] as? String else {return}
                        guard let rank = document.data()["rank"] as? Int else {return}
                        guard let from = document.data()["from"] as? String else {return}
                        let song : Song = Song(title : title, artist : artist, url : url,
                            rank: rank, from : from)
                        
                        self.songs.append(song)
                        count += 1
                        if count == 100 {
                            break
                        }
                }
                    self.melonTableView.reloadData()
            }
        }
    }

}

extension MelonViewController : UITableViewDelegate, UITableViewDataSource {
    // MARK: TableView General Setting
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return self.isFiltering ? self.filteredSongs.count : self.songs.count
        }
    }

    // MARK: TableView Header Setting
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "MainHeader") as? MainHeader else { return  UITableViewHeaderFooterView() }
        if section == 0 {
            headerView.updatedTimeLabel.text = "TODAY'S ARTIST"
            return headerView
        } else {
            headerView.updatedTimeLabel.text = "Charts"
            return headerView
        }
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        view.tintColor = .systemBackground
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
          return 40
    }
    
    // MARK: TableView Cell Setting
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 && indexPath.section == 0 {
            let tableViewCellHeight = tableView.frame.width / 2
            return tableViewCellHeight
        } else {
            let tableViewCellHeight = tableView.frame.width / 4
            return tableViewCellHeight
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let bannerCell = tableView.dequeueReusableCell(withIdentifier: "EventBannerTableViewCell", for: indexPath) as? EventBannerTableViewCell
                else { return UITableViewCell() }
           return bannerCell
       } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "songCell", for: indexPath) as? SongTableViewCell
                else { return UITableViewCell() }
            if self.isFiltering {
                if isDesc {
                    filteredSongs = filteredSongs.sorted(by: {$0.rank < $1.rank})
                } else {
                    filteredSongs = filteredSongs.sorted(by: {$0.rank > $1.rank})
                }
                cell.titleLabel.text = filteredSongs[indexPath.row].title
                cell.artistLabel.text = filteredSongs[indexPath.row].artist
                cell.rankLabel.text = "\(filteredSongs[indexPath.row].rank)"
                let alubartImageUrlData = String().getDataFromStringUrl(urlString: filteredSongs[indexPath.row].url)
                cell.albumartImageView.image = UIImage(data: alubartImageUrlData)
            } else {
                if isDesc {
                    songs = songs.sorted(by: {$0.rank < $1.rank})
                } else {
                    songs = songs.sorted(by: {$0.rank > $1.rank})
                }
                cell.titleLabel.text = songs[indexPath.row].title
                cell.artistLabel.text = songs[indexPath.row].artist
                cell.rankLabel.text = "\(songs[indexPath.row].rank)"
                let alubartImageUrlData = String().getDataFromStringUrl(urlString: songs[indexPath.row].url)
                cell.albumartImageView.image = UIImage(data: alubartImageUrlData)
            }
            return cell
       }
    }
}

// MARK: SearchController Setting
extension MelonViewController : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        self.filteredSongs = self.songs.filter { $0.title.lowercased().hasPrefix(text) }
        self.melonTableView.reloadData()
    }
    
    func searchBarIsEmpty() -> Bool {
      // Returns true if the text is empty or nil
      return searchController.searchBar.text?.isEmpty ?? true
    }
      
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        songs = songs.filter({( song : Song) -> Bool in
        return song.title.lowercased().contains(searchText.lowercased())
      })
    }
}

