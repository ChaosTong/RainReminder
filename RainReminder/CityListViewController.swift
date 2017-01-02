//
//  CityListViewController.swift
//  RainReminder
//
//  Created by 童超 on 16/4/11.
//  Copyright © 2016年 ChaosTong. All rights reserved.
//

import UIKit

protocol CityListViewControllerDelegate: class{
    func cityListViewControolerDidSelectCity(_ controller: CityListViewController, didSelectCity city: City)
    func cityListViewControllerCancel(_ controller: CityListViewController)
    
    func cityListViewControllerDeleteCity(_ controller: CityListViewController, currentCities cities: [City])
    
}

class CityListViewController: UIViewController {

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerYConstraion: NSLayoutConstraint!
    
    weak var delegate: CityListViewControllerDelegate?
    
    var cities = [City]()
    var filteredCities = [City]()
    var parserCities = [City]()
    var parserXML:ParserXML!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
        headerYConstraion.constant -= view.bounds.height - 60
        
        let cellNib = UINib(nibName: "CityListCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "CityListCell")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        headerView.isHidden = false
        headerYConstraion.constant = 0
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: { () -> Void in
            self.view.layoutIfNeeded()
            }, completion: nil)
        
    }
    
    func filterControllerForSearchText(_ searchText: String, scope: String = "ALL"){
        filteredCities = parserCities.filter({ (city) -> Bool in
            return city.cityCN.lowercased().contains(searchText.lowercased())
        })
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit{
        parserXML = nil
        filteredCities = []
        searchBar.delegate = nil
    }
}

//MARK: - 获取总代理
func appCloud() -> AppDelegate {
    return UIApplication.shared.delegate as! AppDelegate
}

extension CityListViewController: UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        filterControllerForSearchText(searchBar.text!)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if parserCities.isEmpty{
            parserXML = ParserXML()
            parserCities = parserXML.cities
        }
        
        filterControllerForSearchText(searchText)
    }
}

extension CityListViewController : UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let delegate = delegate{
            let city: City
            
            if !filteredCities.isEmpty{
                city = filteredCities[indexPath.row]
            }else{
                city = cities[indexPath.row]
            }
            delegate.cityListViewControolerDidSelectCity(self, didSelectCity: city)
        }
        searchBar.resignFirstResponder()
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if searchBar.text != ""{
            return false
        }else{
            return true
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        cities.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
        delegate?.cityListViewControllerDeleteCity(self, currentCities: cities)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offSetY = scrollView.contentOffset.y
        searchBar.resignFirstResponder()
        
        if offSetY < -64{
            headerYConstraion.constant = -(abs(offSetY) - 64)
        }else{
            headerYConstraion.constant = 0
        }
        
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        let offSetY = scrollView.contentOffset.y
        
        if decelerate && offSetY < -110{
            
            headerView.isHidden = true
            delegate?.cityListViewControllerCancel(self)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
}

extension CityListViewController: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let city: City
        if searchBar.text != ""{
            let cell = tableView.dequeueReusableCell(withIdentifier: "CityCell", for: indexPath)
            cell.textLabel?.textColor = UIColor.white
            city = filteredCities[indexPath.row]
            cell.textLabel?.text = city.cityCN
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "CityListCell", for: indexPath) as! CityListCell
            city = cities[indexPath.row]
            cell.addCityName(city)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if  !filteredCities.isEmpty || searchBar.text != ""{
            return filteredCities.count
        }
        return cities.count
    }
    
}
