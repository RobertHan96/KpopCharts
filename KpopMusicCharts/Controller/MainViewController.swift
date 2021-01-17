//
//  MainViewController.swift
//  KpopMusicCharts
//
//  Created by HanaHan on 2021/01/13.
//
import UIKit
import Firebase
import FirebaseFirestore

class MainViewController: UIViewController {
    @IBOutlet weak var mainTableView: UITableView!
    let searchController = UISearchController(searchResultsController: nil)
    let sections = ["Melon", "Bugs", "Genie"]
    var songs : [Song] = []
    var filteredSongs = [Song]()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        DispatchQueue.main.async {
            if cehckNetworkConect() == true {
                self.fetchData()
            } else {
                DispatchQueue.main.async {
                    popupError(currentView: self)
                }
            }
            checkDataChanging(currentView: self)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    
    private func setupUI() {
        mainTableView.delegate = self
        mainTableView.dataSource = self
        mainTableView.register(UINib(nibName: "SongTableViewCell", bundle: nil), forCellReuseIdentifier: "songCell")
    }
    
    // url스트링을 기반으로 이미지 Data를 생성하는 함수, 각 사이트에 맞게 뿌려줘야 하므로 별도로 함수로 구현
    func makeImageUrl(url : String) -> Data  {
        var albumUrlData : Data = Data()
        do {
            let urlString = URL(string: url)
            let data = try Data(contentsOf: urlString!)
            albumUrlData = data
        }catch {
            popupError(currentView: self)
        }
        return albumUrlData
    }

    func fetchData()  {
        let docRef = Firestore.firestore().collection("songs")
        docRef.whereField("rank", isLessThan: 4).getDocuments() { (querySnapshot, err) in
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
                       if count == 9 {
                            break
                        }
                }
                self.mainTableView.reloadData()
            }
        }
    }
}

extension MainViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count/3
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let tableViewCellHeight = tableView.frame.width / 5
        return tableViewCellHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let songCell = tableView.dequeueReusableCell(withIdentifier: "songCell", for: indexPath) as? SongTableViewCell
            else { return UITableViewCell() }
        let melonTop3 : [Song] =
            songs.filter { (song) -> Bool in
                return song.from == "Melon"}
        let bugsTop3 : [Song] =
            songs.filter { (song) -> Bool in
                return song.from == "Bugs"}
        let genieTop3 : [Song] =
            songs.filter { (song) -> Bool in
                return song.from == "Genie"}

        if indexPath.section == 0 {
            songCell.titleLabel.text = melonTop3[indexPath.row].title
            songCell.artistLabel.text = melonTop3[indexPath.row].artist
            songCell.albumartImageView.image = UIImage(data: makeImageUrl(url: melonTop3[indexPath.row].url))
            songCell.rankLabel.text = "\(melonTop3[indexPath.row].rank)"
        } else if indexPath.section == 1 {
            songCell.titleLabel.text = bugsTop3[indexPath.row].title
            songCell.artistLabel.text = bugsTop3[indexPath.row].artist
            songCell.albumartImageView.image = UIImage(data: makeImageUrl(url: bugsTop3[indexPath.row].url))
            songCell.rankLabel.text = "\(bugsTop3[indexPath.row].rank)"
        } else if indexPath.section == 2 {
            songCell.titleLabel.text = genieTop3[indexPath.row].title
            songCell.artistLabel.text = genieTop3[indexPath.row].artist
            songCell.albumartImageView.image = UIImage(data: makeImageUrl(url: genieTop3[indexPath.row].url))
            songCell.rankLabel.text = "\(genieTop3[indexPath.row].rank)"
        } else {
            print("Log - 메인 랭킹정보 로딩 중 에러 발생")
        }
        return songCell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sections[section]
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.white
        let headerTitle = view as! UITableViewHeaderFooterView
        headerTitle.textLabel?.font = UIFont.systemFont(ofSize: 15)
    }

}
