//
//  ViewController.swift
//  StoreSearch
//
//  Created by mac on 7/25/20.
//  Copyright © 2020 M.gamal. All rights reserved.
//

import UIKit


//Using a constant for table cell identifier

struct TableView {
        struct CellIdentifiers {
        static let searchResultCell = "SearchResultCell"
        static let nothingFoundCell = "NothingFoundCell"
        }
    }


class SearchViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!

    var searchResults = [SearchResult]()
    
    var hasSearched = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var cellNib  = UINib(nibName: TableView.CellIdentifiers.searchResultCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "SearchResultCell")
       
        cellNib = UINib(nibName: TableView.CellIdentifiers.nothingFoundCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifiers.nothingFoundCell)
        
        searchBar.becomeFirstResponder()
        // Do any additional setup after loading the view.
     
    }
    
    
    
    // MARK:- Helper Methods
    //Creating the URL for the request

    
    func iTunesURL(searchText : String) -> URL
    {
        let encodedText = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let urlString = String(format: "https://itunes.apple.com/search?term=%@", encodedText)
        let url = URL(string : urlString)
        return url!
    }

    // De ely bt3ml el conection
    func performStoreRequest(with url : URL) -> Data?
    {
        do
        {
            return try Data(contentsOf: url)
        } catch
        {
            print("Download Error \(error.localizedDescription)")
            showNetworkError()
            return nil
        }
     }
    
    
    //Parsing the JSON data
    
    func parse (data : Data) -> [SearchResult]
    {
        do
        {
            let decoder = JSONDecoder()
            let result = try decoder.decode(ResultsArray.self, from: data)
            return result.results
        }
        catch
        {
            print("JSON Error : \(error)")
            return []
        }
    }
    
    
    // Error Handling
    func showNetworkError()
    {
        let alert = UIAlertController(title: "Whoops...", message: "There was an error accessing the iTunes Store." + " Please try again.", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
}

extension SearchViewController : UISearchBarDelegate
{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

        
        if !searchBar.text!.isEmpty
        {
            searchBar.resignFirstResponder()
            hasSearched = true
            searchResults = []
            
            let url = iTunesURL(searchText: searchBar.text!)
            print("URl : \(url)")
            
            if let data = performStoreRequest(with: url)
            {
            searchResults = parse(data: data)
                
                //Sorting The results
//            searchResults.sort(by:
//                { result1, result2 in
//                    return result1.name.localizedStandardCompare(result2.name) == .orderedAscending})
            searchResults.sort { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
            
            }
            tableView.reloadData()
        }
    }

}

extension SearchViewController : UITableViewDelegate , UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
            if !hasSearched {
            return 0
            } else if searchResults.count == 0 {
            return 1
            } else {
            return searchResults.count
            }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
               
        let cell = tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.searchResultCell , for: indexPath) as! SearchResultCell
        
        
       if searchResults.count == 0
       {
            return tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.nothingFoundCell, for: indexPath)
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.searchResultCell, for: indexPath) as! SearchResultCell
        
        
        let searchResult = searchResults[indexPath.row]
        cell.nameLabel.text = searchResult.name
        if searchResult.artist.isEmpty
        {
        cell.artistNameLabel.text = "Unknown"
        } else {
            cell.artistNameLabel.text = String(format: "%@ (%@)",
            searchResult.artist, searchResult.type)
        }

        return cell
        }
        
    }
  
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if searchResults.count == 0
        {return nil}
        else
        {return indexPath}
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}
